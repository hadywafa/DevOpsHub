# 📋 Using Clipboard in Vim inside VS Code

Great catch, Hady — this is a classic limitation of Vim emulation inside VS Code. When you use `y` (yank) in VSCodeVim or `vscode-neovim`, it **copies to Vim's internal register**, not the system clipboard — so you can't paste into external apps like Notepad.

---

## ✅ Solution: Use the System Clipboard Register

### 🔼 Yank to SystemClipboard

In Vim, use the `"+` register to yank to the system clipboard:

```vim
"+y
```

Examples:

- Yank current line: `"+yy`
- Yank selection in Visual mode: `"+y`

Now you can paste into Notepad, browser, etc.

---

### 🔽 Paste from Clipboard into Vim

To paste from system clipboard into Vim:

```vim
"+p
```

Or map it:

```vim
nnoremap <C-v> "+p
```

## 🔴 If Not Working

If you're using **`vscode-neovim`**, make sure:

1. **Neovim is compiled with clipboard support**  
   Run:

   ```bash
   nvim --version | grep clipboard
   ```

   You should see `+clipboard`. If not, reinstall Neovim with clipboard support.

2. **VS Code settings.json** includes:

   ```json
   "vscode-neovim.neovimExecutablePaths.win32": "C:\\Program Files\\Neovim\\bin\\nvim.exe"
   ```

3. **Use system clipboard mappings** in your `.vimrc` or `init.vim`:

   ```vim
   " Map Ctrl+c to yank to system clipboard in Visual mode
   vnoremap <C-c> "+y
   ```
