---
description: Открыть вкладку iTerm в рабочей директории этой сессии
argument-hint: "[команда]"
---

This command never reaches the model: the `open-terminal.sh` hook intercepts it
at `UserPromptSubmit` / `UserPromptExpansion` and blocks it. It exists so that
`/t` autocompletes in the slash menu and is a recognised command rather than a
typo.

If you are reading this, the hook did not fire. Say so and stop — do not try to
open a terminal yourself.
