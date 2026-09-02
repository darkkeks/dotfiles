#!/usr/bin/env bash
# Open an iTerm2 tab sitting in this session's working directory.
#
#   /t             -> new tab, cd'd into the session's cwd
#   /t <command>   -> ... and run <command> there
#
# Wired up from the "hooks" block in ~/.claude/settings.json, on two events:
#
#   UserPromptSubmit    fires first, with the raw text ("/t arc status")
#   UserPromptExpansion fires only if the command was allowed to expand
#
# Either one is enough; both are registered so the feature does not depend on
# which of them a given Claude Code version routes a slash command through.
# Both exit 2, which erases the prompt / blocks the expansion -- the point of
# the whole exercise is that opening a terminal costs zero context.
#
# CLAUDE_T_SPLIT=1 opens a vertical split next to Claude instead of a new tab.

set -uo pipefail

input=$(cat)
field() { jq -r "$1 // \"\"" <<<"$input" 2>/dev/null; }

case "$(field .hook_event_name)" in
  UserPromptSubmit)
    # Anything other than a bare /t is a normal prompt: let it through.
    prompt=$(field .prompt)
    [[ "$prompt" =~ ^[[:space:]]*/t([[:space:]]+(.*))?$ ]] || exit 0
    arg="${BASH_REMATCH[2]:-}"
    ;;
  UserPromptExpansion)
    [[ "$(field .command_name)" == "t" ]] || exit 0
    arg=$(field .args)
    ;;
  *) exit 0 ;;
esac

arg="${arg%"${arg##*[![:space:]]}"}"   # trim trailing whitespace

cwd=$(field .cwd)
[[ -d "$cwd" ]] || cwd="$HOME"

# Blocking at UserPromptSubmit already stops the expansion, so the second event
# should never fire for the same keystroke. Guard anyway -- two tabs for one /t
# would be a confusing way to find that out.
guard="${TMPDIR:-/tmp}/claude-open-terminal.$(field .session_id)"
now=$(date +%s)
if [[ -r "$guard" ]] && read -r last <"$guard" 2>/dev/null && [[ "$last" =~ ^[0-9]+$ ]] &&
   (( now - last < 3 )); then
  exit 2
fi
printf '%s\n' "$now" >"$guard" 2>/dev/null

# Hand the command over in the environment rather than interpolating it into
# the AppleScript, so a path or an argument with quotes in it cannot break out.
T_CMD="cd $(printf %q "$cwd")"
[[ -n "$arg" ]] && T_CMD="$T_CMD && $arg"
T_SPLIT="${CLAUDE_T_SPLIT:-0}"
export T_CMD T_SPLIT

err=$(osascript 2>&1 <<'APPLESCRIPT'
set theCmd to system attribute "T_CMD"
set wantSplit to (system attribute "T_SPLIT") is "1"
tell application "iTerm2"
  if (count of windows) is 0 then
    create window with default profile
  else if wantSplit then
    tell current session of current window to split vertically with default profile
  else
    tell current window to create tab with default profile
  end if
  tell current session of current window to write text theCmd
  activate
end tell
APPLESCRIPT
)
rc=$?

# The turn never happens, so the Stop hook never fires and the tab would be
# left painted "busy" by the UserPromptSubmit colour hook. Repaint it after
# that hook has had its moment.
( sleep 0.4; "$HOME/.claude/hooks/iterm-tab-color.sh" done ) </dev/null >/dev/null 2>&1 &

if (( rc == 0 )); then
  printf '→ iTerm: %s%s\n' "$cwd" "${arg:+  ($arg)}" >&2
else
  printf 'не смог открыть вкладку iTerm: %s\n' "${err:-osascript rc=$rc}" >&2
fi
exit 2
