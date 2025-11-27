# ✍️ Insert at Many Places with Visual Block

## 1. **Insert at the Start of the Block**

- Press `Ctrl+v` → select the block (move with arrow keys or `hjkl`).
- Press `I` (capital i).
- Type your text.
- Press `Esc`.  
  👉 Vim will insert that text at the start of **every selected line**.

---

## 2. **Append at the End of the Block**

- Press `Ctrl+v` → select the block.
- Press `A` (capital a).
- Type your text.
- Press `Esc`.  
  👉 Text gets appended at the end of **every selected line**.

---

## 3. **Replace or Type in the Block**

- Press `Ctrl+v` → select the block.
- Just start typing — Vim will replace the block with what you type.
- Press `Esc` when done.

---

## 4. **Practical Example**

Say you want to comment out multiple lines with `//`:

```vim
Ctrl+v   (select first column across lines)
I//      (insert // at start)
Esc
```

Result:

```c
//line1
//line2
//line3
```

Or add a semicolon at the end of multiple lines:

```vim
Ctrl+v   (select last column across lines)
A;       (append ;)
Esc
```

---

## 🧠 Pro Tip

- `Ctrl+v` + `r<char>` → replaces the block with `<char>` (e.g., `r#` makes a column of `#`).
- Works beautifully for aligning code, bulk commenting, or editing config files.
