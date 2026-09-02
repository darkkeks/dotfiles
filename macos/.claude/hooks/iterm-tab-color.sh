#!/usr/bin/env bash
# Paint the iTerm2 tab according to what Claude Code is doing.
#
#   usage: iterm-tab-color.sh <busy|waiting|done|error|reset>
#
# Wired up from the "hooks" block in ~/.claude/settings.json. Hook JSON arrives
# on stdin and is ignored -- the status comes from the argument. Always exits 0
# so a hook can never interfere with the session.
#
# Colours are RRGGBB hex, overridable via CLAUDE_TAB_COLOR_{BUSY,WAITING,DONE,ERROR}.
# CLAUDE_TAB_COLOR_TTY redirects the output to one file and skips pane lookup
# (used by the tests). CLAUDE_TAB_COLOR_FORCE=1 skips the "am I in iTerm2?"
# check. CLAUDE_TAB_COLOR_STATE_DIR moves the "last colour painted" cache.

set -uo pipefail

status="${1:-reset}"

COLOR_BUSY="${CLAUDE_TAB_COLOR_BUSY:-1F3F73}"    # blue   - working
COLOR_WAITING="${CLAUDE_TAB_COLOR_WAITING:-8A5A00}" # amber  - wants you
COLOR_DONE="${CLAUDE_TAB_COLOR_DONE:-1B5E32}"    # green  - finished
COLOR_ERROR="${CLAUDE_TAB_COLOR_ERROR:-7A1F1F}"  # red    - something failed

case "$status" in
  busy)    hex="$COLOR_BUSY" ;;
  waiting) hex="$COLOR_WAITING" ;;
  done)    hex="$COLOR_DONE" ;;
  error)   hex="$COLOR_ERROR" ;;
  reset)   hex="" ;;
  notify)
    # Notification fires for a whole family of events, keyed by
    # notification_type in the payload. Most of them must NOT touch the colour:
    # in particular "idle_prompt" ("Claude is waiting for your input") is a
    # timer that goes off ~60s after a turn ends and would repaint a freshly
    # finished green tab amber. So whitelist the ones that genuinely mean
    # "a human is needed" and leave the tab alone for everything else.
    payload=$(cat 2>/dev/null || true)
    payload="${payload//[[:space:]]/}"
    case "$payload" in
      *'"notification_type":"agent_needs_input"'*|*'"notification_type":"worker_permission_prompt"'*)
        hex="$COLOR_WAITING" ;;
      *) exit 0 ;;
    esac
    ;;
  *)       exit 0 ;;
esac

# Only iTerm2 understands OSC 6, and only a session attached to a real terminal
# has a tab to paint. Background agents, `claude -p` in a pipeline and every
# other terminal emulator fall out here.
if [[ -z "${CLAUDE_TAB_COLOR_FORCE:-}" ]]; then
  [[ "${TERM_PROGRAM:-}" == "iTerm.app" || "${LC_TERMINAL:-}" == "iTerm2" || -n "${ITERM_SESSION_ID:-}" ]] || exit 0
fi

# Claude Code spawns hooks detached, so /dev/tty is usually unavailable to us.
# The terminal we want belongs to the claude process itself, which CLAUDE_PID
# points at. Only ever consult that process (or our direct parent, which is the
# same process) -- walking further up the tree can land on an unrelated ancestor
# session and repaint somebody else's tab.
tty_of() {
  local t
  t=$(ps -o tty= -p "$1" 2>/dev/null | tr -d '[:space:]')
  [[ -n "$t" && "$t" != "??" && "$t" != "-" ]] && printf '/dev/%s' "$t"
}

tty_path="${CLAUDE_TAB_COLOR_TTY:-}"
[[ -z "$tty_path" && -n "${CLAUDE_PID:-}" ]] && tty_path=$(tty_of "$CLAUDE_PID")
[[ -z "$tty_path" ]] && tty_path=$(tty_of "$PPID")
[[ -z "$tty_path" && -e /dev/tty ]] && { : >/dev/tty; } 2>/dev/null && tty_path=/dev/tty
[[ -n "$tty_path" ]] || exit 0

if [[ -n "$hex" ]]; then
  # Never let a mistyped override put junk on the terminal.
  [[ "$hex" =~ ^[0-9A-Fa-f]{6}$ ]] || exit 0
  esc=$(printf '\033]6;1;bg;red;brightness;%d\a\033]6;1;bg;green;brightness;%d\a\033]6;1;bg;blue;brightness;%d\a' \
    "$((16#${hex:0:2}))" "$((16#${hex:2:2}))" "$((16#${hex:4:2}))")
else
  esc=$(printf '\033]6;1;bg;*;default\a')
fi

# tmux swallows unknown escapes, so wrap them in a passthrough (needs
# `set -g allow-passthrough on` in tmux.conf).
if [[ -n "${TMUX:-}" ]]; then
  esc=$(printf '\033Ptmux;%s\033\\' "${esc//$'\033'/$'\033\033'}")
fi

# In iTerm2 the tab colour belongs to the *session* (pane), and the tab renders
# whichever pane is focused. Split a shell next to Claude and that new pane
# copies the colour once, then never updates -- so focusing it shows a stale
# colour. Painting every pane in the tab sidesteps the question of which pane
# the tab takes its colour from.
#
# The grouping has to come from iTerm2 itself: ITERM_SESSION_ID looks like
# "w0t3p0" but is frozen at session start, so after reordering or closing tabs
# its t-index no longer says which panes share a tab.
panes_in_same_tab() {
  osascript - "$1" 2>/dev/null <<'APPLESCRIPT'
on run argv
  set target to item 1 of argv
  tell application "iTerm2"
    repeat with w in windows
      repeat with t in tabs of w
        repeat with s in sessions of t
          if (tty of s) is target then
            set out to ""
            repeat with s2 in sessions of t
              set out to out & (tty of s2) & linefeed
            end repeat
            return out
          end if
        end repeat
      end repeat
    end repeat
  end tell
  return ""
end run
APPLESCRIPT
}

# Asking iTerm2 costs ~175ms, and PostToolUse fires on every single tool call,
# so remember what this session was last painted and do nothing when the colour
# would not change. A pane created after this point simply inherits the current
# colour on split, which is already correct.
state_dir="${CLAUDE_TAB_COLOR_STATE_DIR:-${TMPDIR:-/tmp}/claude-tab-color}"
state_file="$state_dir/${tty_path##*/}"
want="${hex:-reset}"
if [[ -r "$state_file" ]] && read -r prev <"$state_file" 2>/dev/null && [[ "$prev" == "$want" ]]; then
  exit 0
fi

targets="$tty_path"
# CLAUDE_TAB_COLOR_TTY means a test is pointing us at a plain file, not a pane.
if [[ -z "${CLAUDE_TAB_COLOR_TTY:-}" ]]; then
  siblings=$(panes_in_same_tab "$tty_path")
  [[ -n "$siblings" ]] && targets="$siblings"
fi

# One write per pane, so a concurrent TUI redraw cannot tear an escape in half.
# The braces put the redirection failure itself (vanished pane) on /dev/null.
while IFS= read -r dev; do
  [[ -n "$dev" ]] || continue
  { printf '%s' "$esc" >"$dev"; } 2>/dev/null || true
done <<<"$targets"

mkdir -p "$state_dir" 2>/dev/null && printf '%s\n' "$want" >"$state_file" 2>/dev/null
exit 0
