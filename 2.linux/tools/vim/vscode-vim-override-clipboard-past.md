# Override Paste in VS Code

Ah, that explains the confusion, Hady. In VS Code the command name for paste isn’t `editor.action.clipboardPaste` — that’s why you’re seeing _command not found_. The correct built‑in command is:

```ini
editor.action.clipboardPasteAction
```

---

## ✅ How to remap paste while keeping Vim’s `<C-v>` for Visual Block

1. In your VS Code `settings.json`, keep Vim handling `<C-v>`:

   ```json
   "vim.handleKeys": {
       "<C-v>": true
   }
   ```

   → This ensures `<C-v>` stays as Visual Block mode inside the Vim extension.

2. Add a new keybinding for paste using the correct command:

   ```json
   {
     "key": "ctrl+shift+v",
     "command": "editor.action.clipboardPasteAction",
     "when": "editorTextFocus"
   }
   ```

   → Now `Ctrl+Shift+V` pastes from clipboard, while `Ctrl+V` stays Visual Block.

---

## 🔍 Other useful commands

- Copy: `editor.action.clipboardCopyAction`
- Cut: `editor.action.clipboardCutAction`

These can also be remapped if you want to separate Vim motions from VS Code’s native clipboard behavior.
