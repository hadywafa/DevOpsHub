# Vim Plugins

## [`identline`](https://github.com/Yggdroot/indentLine)

## [`vim-surround`](https://github.com/tpope/vim-surround)

**To surround selected text with quotes, brackets, or braces using `vim-surround`, you use Visual mode + `S` followed by the character you want.**

---

### 🔑 How to Surround Selected Text (from vim‑surround docs)

1. Enter **Visual mode** (`v` for characterwise, `V` for linewise, or `Ctrl+v` for blockwise).
2. Select the text you want to wrap.
3. Press **`S`** followed by the surrounding character:
   - `S"` → `"selected"`
   - `S'` → `'selected'`
   - `S(` → `(selected)`
   - `S{` → `{selected}`
   - `S<p>` → `<p>selected</p>`

👉 The plugin automatically inserts both opening and closing delimiters around your selection.

---

### 🧠 Other Useful Surround Commands

- **Add surround without Visual mode**:

  - `ysiw"` → surround _inner word_ with quotes → `"word"`
  - `yss)` → surround _entire line_ with parentheses → `(line)`

- **Delete surround**:

  - `ds"` → remove surrounding quotes
  - `ds(` → remove surrounding parentheses

- **Change surround**:
  - `cs"'` → change quotes `"` to `'`
  - `cs([` → change parentheses `()` to brackets `[]`

---

### ✅ Summary

- Use **Visual mode + `S<char>`** to wrap a selection.
- Use **`ys`** for adding, **`ds`** for deleting, and **`cs`** for changing surrounds.
- Works with quotes, brackets, braces, XML/HTML tags, and more.
