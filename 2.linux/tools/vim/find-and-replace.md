# Find and Replace in Vim

In Vim, **find and replace** is done with the `:substitute` command. Here’s the breakdown:

---

## 🔍 Basic Syntax

```vim
:[range]s/{pattern}/{replacement}/[flags]
```

- `range` → where to apply (line numbers, `%` for whole file, `'<,'>` for visual selection)
- `pattern` → what to search for
- `replacement` → what to replace it with
- `flags` → extra behavior (global, confirm, case-insensitive, etc.)

---

## ✅ Common Examples

### 1. Replace in Current Line

```vim
:s/foo/bar/
```

👉 Replace first occurrence of `foo` with `bar` in the current line.

### 2. Replace All in Current Line

```vim
:s/foo/bar/g
```

👉 Replace **all occurrences** of `foo` with `bar` in the current line.

### 3. Replace in Whole File

```vim
:%s/foo/bar/g
```

👉 Replace all `foo` with `bar` everywhere in the file.

### 4. Confirm Each Replacement

```vim
:%s/foo/bar/gc
```

👉 Vim will ask `replace with bar? (y/n/a/q/l)` for each match.

### 5. Case-Insensitive Search

```vim
:%s/foo/bar/gi
```

👉 Replace all `foo` or `Foo` or `FOO` with `bar`.

---

## 🧠 Advanced Tricks

- Replace only in a **range of lines**:

  ```vim
  :10,20s/foo/bar/g
  ```

  👉 Lines 10–20 only.

- Replace in a **visual selection**:

  1. Select text with `V` or `Ctrl+v`.
  2. Type `:s/foo/bar/g`.

- Use **regex groups**:

  ```vim
  :%s/\(foo\)\(bar\)/\2\1/g
  ```

  👉 Swap `foobar` → `barfoo`.

---

## ⚡ Quick Workflow

- Search first: `/foo`
- Then replace globally: `:%s//bar/g`  
  👉 The `//` reuses the last search pattern.

---

Would you like me to also show you a **cheat sheet table** (patterns, flags, examples) that you can drop straight into your onboarding docs for Vim?
