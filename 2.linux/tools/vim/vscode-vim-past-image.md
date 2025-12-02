# 🧩 Restore auto-ID and nested folder behavior in VS Code

Before you installed the Vim extension, VS Code’s **Paste Image** workflow was doing two things automatically when you pasted from clipboard:

1. **Generated a random ID for the image filename** (e.g. `20251202-abc123.png`).
2. **Nested the image inside a folder named after the current file** (e.g. if editing `notes.md`, the image went into `notes/20251202-abc123.png`).

After enabling the Vim extension, you restored paste functionality with `editor.action.clipboardPasteAction`, but you lost those custom behaviors because those come from the **Paste Image extension’s configuration**, not from VS Code core.

---

## 🔧 How to restore auto‑ID and nested folder behavior

1. Open **VS Code Settings** (`Ctrl+,`).
2. Search for **Paste Image** (extension settings).
3. Configure these keys in your `settings.json`:

```json
"pasteImage.path": "${currentFileDir}/${currentFileNameWithoutExt}",
"pasteImage.namePrefix": "",
"pasteImage.nameSuffix": "",
"pasteImage.nameFormat": "YYYYMMDD-HHmmss-${rand}",
```

- `pasteImage.path` → puts images in a folder named after the current file.
- `pasteImage.nameFormat` → generates timestamp + random ID for filenames.
- `${currentFileNameWithoutExt}` → automatically creates a nested folder matching the file name.

---

## ✅ Example

Editing `report.md` and pasting an image:

- Saved to: `report/20251202-150455-xyz.png`
- Markdown link auto‑inserted:

  ```markdown
  ![image](report/20251202-150455-xyz.png)
  ```

---

## 🧩 Why it broke

- The Vim extension intercepted `Ctrl+V`.
- You remapped paste back to VS Code, but only the **raw paste command**.
- The **Paste Image extension** needs its own command (`pasteImage`) to run so it can apply naming rules.

---

👉 Fix: bind a shortcut (e.g. `Ctrl+Alt+V`) to the `pasteImage` command, while keeping `Ctrl+V` for Visual Block. That way you get both Vim block mode and the full image‑paste workflow with auto IDs and nested folders.
