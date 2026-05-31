# Linux Basics - Day 01

## 1. Print Username, Hostname, and Current Directory

```bash
echo "User: $(whoami) | Machine: $(hostname) | Location: $(pwd)"
```

---

## 2. Create Folder Structure

Create the following structure:

```text
day01/
├── notes/
├── scripts/
└── practice/
```

Command:

```bash
mkdir -p day01/{notes,scripts,practice}
```

---

## 3. Create `myinfo.txt`

Create a file containing your name and today's date:

```bash
echo "Name: Anand" > day01/notes/myinfo.txt
echo "Date: $(date)" >> day01/notes/myinfo.txt
```

---

## 4. Verify File Contents

```bash
cat day01/notes/myinfo.txt
```

---

## 5. Copy and Rename the File

Copy `myinfo.txt` to the practice folder and rename it to `backup.txt`.

```bash
cp day01/notes/myinfo.txt day01/practice/backup.txt
```

---

## 6. List All Files Including Subfolders

```bash
ls -R day01
```

Alternative:

```bash
find day01 -type f
```

---

## 7. Count Lines in `backup.txt`

```bash
wc -l day01/practice/backup.txt
```

Or:

```bash
cat day01/practice/backup.txt | wc -l
```

---

## 8. Append a Third Line

Add the text without overwriting existing content:

```bash
echo "This is my backup file" >> day01/practice/backup.txt
```

### Redirection Operators

| Operator | Description    |
| -------- | -------------- |
| `>`      | Overwrite file |
| `>>`     | Append to file |

---

## 9. Create `secret.txt`

```bash
touch day01/secret.txt
```

---

## 10. Restrict Permissions

Allow only the owner to read and write:

```bash
chmod 600 day01/secret.txt
```

Permission meaning:

```text
-rw-------
```

---

## 11. Verify Permissions

```bash
ls -l day01/secret.txt
```

Expected output:

```text
-rw-------
```

---

## 12. Create `script.sh`

```bash
touch day01/script.sh
```

Give execute permission to everyone:

```bash
chmod 755 day01/script.sh
```

---

## 13. Verify Script Permissions

```bash
ls -l day01/script.sh
```

Expected output:

```text
-rwxr-xr-x
```

### Permission Breakdown

| Permission | Meaning |
| ---------- | ------- |
| `r`        | Read    |
| `w`        | Write   |
| `x`        | Execute |

Example:

```text
-rwxr-xr-x
```

* Owner: Read, Write, Execute
* Group: Read, Execute
* Others: Read, Execute
