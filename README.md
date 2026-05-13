# DeTree (Formerly Docs2saurus)
Create files and folder structure using a text editor.

Example use case: Convert a text document to files for Docusaurus.


# DeTree

Write a nested list and DeTree will convert it to a hierarchy directory structure, files and their content.

* Use a numbered list to organize for docusaurus. This tool preserves number prefixes in filenames.
* Docusaurus will remove the number prefix from the doc id, title, label, and URL paths (not handled by this tool).

## Directory Structure

- This line becomes a directory named after this very line
  - This becomes a directory (has children) or file (no children)
  - File here or folder. If a line has no children, it becomes a file., unless you check allow empty folders
  - Another folder, under /This line becomes/
    - This line becomes a file. The lines on the last layer become files.
    - What Really Files and folders are named after the line they represent, in this case, **What Really Files.md**
    - Unless specified, files are `.md`
  - Back to file, it has no children and is therefore a leaf
- New Folder!
  - Look At all these folders
  - I love sub folders
    - Files are good too
    - 1234 You can have digits in your titles! this is a file @#$%^&*()<>? are okay
    - By default files are .md
  - Wow sub folder
    - Files are good too, this file will end up something Files_are_good.md 
    - Here is a a file called “hiworld.txt” it will have content written in it.
    - **Lets write in this file**
    - **HELLO WORLD**
    - **All 4 of these bold lines are INSIDE the file. Anything bold gets written INSIDE the file. Bold on the list is Content in the file.**
    - What a time to be alive! This is a new empty file!
    - So long as it's a line in the list
   
      
-------------------------------------------------------------------------------




  Bullet Points, Numbers, !Letters, !Roman Numbers, Tabs, spaces, or indent. 

## Terminology

node = a line in the list

leaf = file = a node with no children

branch = directory = folder

parent

child

children

sibling

deepest layer = no other lines have greater indent

deepest level

hierarchy

folder structure

nested list

root = top-level node in input list

base_dir = output directory where files are created

indent = number of leading characters (spaces, tabs, etc.) = leading whitespace










## Headers

will show up on the table of contents on the upper right



## Uxd h2 and h3 headings syntax in your bolded text, and it will be in the Docusaurous TOC by default.
internal links for indivual pages, a table of contents for that file will be generated on the top right and the **internal links can be nested too!** we love nests! use markdown syntax for h1 and h2 headers

---

## Complete Technical Documentation

### Overview

DeTree is a command-line tool that parses indented text files and converts them into a hierarchical directory structure with Markdown files. It supports multiple features including body content detection, quoted extensions, name deduplication, and various sanitization options.

### Installation

#### 🚀 One-Click Install (Linux/macOS/ARM64)
Copy-paste this single command:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/DeTree/main/install.sh | bash
```
Or for wget:
```bash
wget -qO- https://raw.githubusercontent.com/yourusername/DeTree/main/install.sh | bash
```

**Supported Architectures:**
- ✅ Linux x86_64 (Intel/AMD)
- ✅ Linux ARM64 (aarch64) - Raspberry Pi, ARM servers
- ✅ macOS (Intel & Apple Silicon)
- ✅ Windows (via WSL or native .exe)

#### Building Binaries

**On Linux (builds for native + ARM64 via Docker):**
```bash
chmod +x build_linux_binaries.sh
./build_linux_binaries.sh
# Creates: dist/detree-linux-x86_64, dist/detree-linux-arm64
```

**On macOS (builds for Intel + Apple Silicon):**
```bash
chmod +x build_macos.sh
./build_macos.sh
# Creates: dist/detree-macos-intel, dist/detree-macos-arm64
```

**On Windows (native .exe):**
```powershell
pyinstaller --onefile --name detree-windows.exe d2c2_cli.py
# Creates: dist/detree-windows.exe
```

**Cross-compilation:**
- Use Docker: `docker run --rm -v "$(pwd):/src" -w /src python:3.11-slim bash -c "pip install pyinstaller && pyinstaller --onefile --name detree-linux-arm64 d2c2_cli.py"`
- Or use GitHub Actions (automatic on tag push)

#### Option 1: Quick Install via pip (Recommended)
```bash
pip install detree
detree --help
```

#### Option 2: Install from Source
```bash
git clone https://github.com/yourusername/DeTree.git
cd DeTree
pip install .
detree --help
```

#### Option 3: Download Standalone Binary (No Python Required)
```bash
# Linux x86_64 (Intel/AMD)
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-linux-x86_64
chmod +x detree-linux-x86_64
sudo mv detree-linux-x86_64 /usr/local/bin/detree

# Linux ARM64 (Raspberry Pi, ARM servers)
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-linux-arm64
chmod +x detree-linux-arm64
sudo mv detree-linux-arm64 /usr/local/bin/detree

# macOS (Intel)
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-macos-intel

# macOS (Apple Silicon M1/M2/M3)
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-macos-arm64
```

**Verify architecture:**
```bash
uname -m  # x86_64 = Intel/AMD, aarch64 = ARM64
```

#### Option 4: Install via Package Manager

**Debian/Ubuntu:**
```bash
sudo dpkg -i detree_1.0.0.deb
```

**Fedora/RHEL:**
```bash
sudo rpm -ivh detree-1.0.0-1.noarch.rpm
```

#### Option 5: Manual Install (Symlink)
```bash
chmod +x d2c2_cli.py
sudo ln -s $(pwd)/d2c2_cli.py /usr/local/bin/detree
detree --help
```

#### Requirements:
- Python 3.6+ (for Options 1, 2, 5)
- No external dependencies!

### Basic Usage

```bash
python d2c2_cli.py <input_file> <output_directory> [options]
```

**Positional Arguments:**
- `input_file` - Path to the input text file containing the nested list
- `output_dir` - Path to the output base directory where the structure will be created

**Optional Arguments:**
- `--remove-digits` - Use alternative sanitization to remove leading digits from filenames
- `--allow-empty-folders` - Create directories for leaf nodes (normally leaf nodes become files)

### Input File Format

DeTree supports **two input formats**:

#### 1. Text Format (Default)
The input file should contain a nested list where:
- **Indentation** determines hierarchy (spaces or tabs)
- **Lines** become either files or directories
- **Body content** must be marked with `**` (double asterisks) on the same line

**Example Input:**
```
Parent Item
    **Body content for parent**
    Child Item 1
        **Body content for child**
    Child Item 2
```

#### 2. JSON Format (New!)
Structured JSON file with explicit type definitions (no parsing ambiguity!):

**Example `structure.json`:**
```json
{
  "name": "Project Documentation",
  "type": "directory",
  "body": "Optional body content for this item",
  "children": [
    {
      "name": "Getting Started.md",
      "type": "file",
      "body": "## Welcome\nThis is the content."
    },
    {
      "name": "API Reference",
      "type": "directory",
      "children": [
        {"name": "endpoints.json", "type": "file", "body": "{\"version\": \"1.0\"}"}
      ]
    }
  ]
}
```

**JSON Fields:**
- `"name"` (required): The filename or directory name
- `"type"` (optional): `"file"` or `"directory"` (auto-detected from children if omitted)
- `"body"` (optional): Body content (supports newlines with `\n`)
- `"children"` (optional): Array of child items (makes it a directory)

**Usage:**
```bash
# Auto-detect format (by file content)
detree input.txt output/
detree structure.json output/

# Explicit format
detree --format json structure.json output/
detree --format text input.txt output/
```

#### Key Rules:
1. **Indentation**: Lines with more leading whitespace are children of the nearest parent with less indentation
2. **Body Lines**: Lines containing `**` are attached as body content to the current parent node
3. **Quoted Extensions**: Lines like `"notes.txt"` preserve the extension in the filename
4. **Children**: If a line has children, it becomes a directory with an `index.md` file
5. **Leaf Nodes**: Lines without children become `.md` files (or other extension if quoted)

### Features

#### 1. Body Content Detection (ISSUE-001)
Body content is detected using `**` markers. Any line containing `**` is treated as body content and attached to the current parent node.

**Input:**
```
Parent Item
    **This is body content**
    **More body content**
    Child Item
```

**Output:**
- `Parent Item/index.md` will contain:
  ```markdown
  ---
  title: "Parent Item"
  ---
  
      This is body content
      More body content
  ```

#### 2. Special Character Sanitization (ISSUE-002)
Invalid filesystem characters are automatically removed from filenames:
- Removed characters: `< > : " / \ | ? * ! % @ # $ ~ ` ^ [ ] { }`
- Example: `File@With#Invalid$Chars` → `FileWithInvalidChars`

#### 3. Digit Removal (ISSUE-003)
When `--remove-digits` flag is used, leading digits and spaces are removed:
- Example: `123 Numeric Start` → `Numeric Start`
- Note: This feature has some edge cases with truncation

#### 4. Name Collision Detection (ISSUE-004)
When duplicate filenames are detected, a 6-character unique ID is appended:
- `SubItem.md` (first occurrence)
- `SubItem_977bc5.md` (second occurrence)
- `SubItem_51097e.md` (third occurrence)

#### 5. Quoted Extension Parsing (ISSUE-005)
Files can preserve custom extensions using quotes:
- Input: `"notes.txt"` → Output: `notes.txt/` directory with `index.md`
- Input: `"README.md"` → Output: `README.md/` directory with `index.md`

#### 6. Whitespace Normalization (ISSUE-006)
Multiple spaces are normalized to single spaces:
- Input: `Item  With   Multiple    Spaces` → Output: `Item With Multiple Spaces`

#### 7. Smart Truncation (ISSUE-007)
Long filenames are truncated intelligently, preferring word boundaries:
- If a space exists in the truncated portion, the name is cut at the last space
- Ellipsis (`...`) is appended to indicate truncation
- Example: `This is a very long item name that exceeds...`

#### 8. Space Preservation (ISSUE-009)
Spaces are preserved in the middle of filenames (not removed entirely):
- Input: `Top Level Item 1` → Output: `Top Level Item 1.md`

#### 9. Input Validation (ISSUE-011)
The tool validates input before processing:
- Checks if input file exists
- Verifies it's a file (not a directory)
- Ensures the file is not empty
- Provides clear error messages

#### 10. JSON Input Mode (New!)
Process structured JSON files with explicit type definitions:
- **No parsing ambiguity** - Clear parent-child relationships via `"children"` array
- **Explicit types** - `"type": "file"` or `"type": "directory"`
- **Body content** - `"body"` field supports newlines (`\n`)
- **Any extension** - Specify exact filename in `"name"` field

**Example:**
```json
{
  "name": "Project",
  "type": "directory",
  "body": "Optional body content",
  "children": [
    {"name": "README.md", "type": "file", "body": "# Title\nContent here"}
  ]
}
```

**Usage:**
```bash
detree --format json structure.json output/
# Or auto-detect: detree structure.json output/
```

### Output Structure

#### Files (Leaf Nodes)
Lines without children become Markdown files:
```
Top Level Item.md
```

#### Directories (Branch Nodes)
Lines with children become directories with an `index.md`:
```
Parent Item/
├── index.md          # Contains body content for "Parent Item"
├── Child Item 1.md
└── Child Item 2.md
```

#### Quoted Extensions
Special handling for quoted filenames:
```
"notes.txt"/
├── index.md          # Contains body content for "notes.txt"
└── Child Item.md
```

### Sanitization Functions

#### Default: `sanitize_and_clean_name()`
- Removes invalid filesystem characters
- Normalizes whitespace (multiple spaces → single space)
- Truncates long names at word boundaries
- Preserves spaces in the middle of names
- Default max length: 20 characters

#### Alternative: `sanitize_no_digits()`
- All of the above PLUS
- Removes leading digits and spaces
- Activated with `--remove-digits` flag

### Processing Pipeline

1. **Read Input**: Read the input file and strip trailing whitespace from each line
2. **Categorize Lines**: Parse lines into a hierarchical tree structure
   - Track indentation levels using a stack
   - Detect body lines (containing `**`)
   - Build parent-child relationships
3. **Create Structure**: Recursively create directories and files
   - Leaf nodes → `.md` files (or quoted extension)
   - Branch nodes → directories with `index.md`
   - Handle name collisions with unique IDs
4. **Write Content**: Write body content to `index.md` files with YAML front matter

### YAML Front Matter

Each generated file includes YAML front matter:
```markdown
---
title: "Original Line Content"
---
```

The title is properly escaped (double quotes are escaped with backslash).

### Testing

The tool includes 12 comprehensive test files covering:
1. `test_simple_flat.txt` - Basic flat list
2. `test_simple_nested.txt` - One level of nesting
3. `test_deep_nesting.txt` - Multiple nesting levels
4. `test_mixed_with_body_content.txt` - Items with body lines (`**` markers)
5. `test_special_characters.txt` - Invalid filesystem characters
6. `test_numeric_edge_cases.txt` - Numbers and digit removal
7. `test_empty_and_edge_cases.txt` - Empty items and spacing
8. `test_quoted_extension.txt` - Quoted extensions like `"file.txt"`
9. `test_inconsistent_indentation.txt` - Mixed spaces/tabs
10. `test_deep_duplicate_names.txt` - Name collision handling
11. `test_very_long_names.txt` - Filename length limits
12. `test_whitespace_heavy.txt` - Multiple spaces between words

Run all tests:
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus
$tests = @("test_simple_flat.txt", "test_simple_nested.txt", ...)
$dirs = @("output_t01", "output_t02", ...)
for ($i = 0; $i -lt $tests.Length; $i++) { 
    python d2c2_cli.py $tests[$i] $dirs[$i] 2>&1 | Select-String "completed"
}
```

### Error Handling

- **Invalid Path Detection**: Prevents directory traversal attacks
- **Input Validation**: Clear error messages for missing/invalid input files
- **Name Collision**: Automatic deduplication with unique IDs
- **Graceful Degradation**: Continues processing even if some lines fail

### Limitations

1. **Body Content**: Requires `**` markers (indent-based detection not implemented)
2. **Digit Removal**: Has edge cases with truncation logic
3. **Folder Design**: Items with children always create directories (not configurable)
4. **Extension Doubling**: Be careful with extensions in non-quoted items

### Examples

#### Example 1: Simple Documentation Structure
Input (`docs.txt`):
```
Getting Started
    **Welcome to our documentation**
    Installation
        **Step 1: Download the installer**
        **Step 2: Run the setup**
    Configuration
        Basic Settings
        Advanced Settings
```

Command:
```bash
python d2c2_cli.py docs.txt ./output
```

Output:
```
output/
├── Getting Started/
│   ├── index.md          # Contains "Welcome to our documentation"
│   ├── Installation/
│   │   ├── index.md      # Contains installation steps
│   │   └── ...
│   └── Configuration/
│       ├── index.md
│       ├── Basic Settings.md
│       └── Advanced Settings.md
```

#### Example 2: Using Quoted Extensions
Input (`files.txt`):
```
"README.md"
    **Main readme file**
    Introduction
"notes.txt"
    **Text file with notes**
    Chapter 1
```

Command:
```bash
python d2c2_cli.py files.txt ./project
```

Output:
```
project/
├── README.md/
│   ├── index.md          # Contains "Main readme file"
│   └── Introduction.md
└── notes.txt/
    ├── index.md          # Contains "Text file with notes"
    └── Chapter 1.md
```

### Contributing

When contributing to DeTree:
1. Run all 12 tests before submitting changes
2. Update `ISSUE_LOG.md` with any new issues found
3. Follow the existing code style (PEP 8)
4. Add test cases for new features

### License

[Add your license here]

---

**DeTree** - Transform your nested lists into structured documentation effortlessly!

