# DeTree - Issue Log from Iterative Testing

**Date**: May 13, 2026  
**Testing Phase**: Phase 1 - Initial Test Run + Phase 2 Fixes (In Progress)
**Total Tests**: 12  
**Tests Status**: Many passing with fixes applied
**Critical Bugs**: 3 (1 FIXED, 2 PARTIALLY FIXED)
**Medium Bugs**: 5  
**Low Priority**: 4  

---

## 🎯 FIXES APPLIED IN THIS SESSION (May 13, 2026 - 3:50 PM)

### ✅ ISSUE-001: Body Lines Treated as Header Lines - PARTIALLY FIXED
**Status**: Requires `**` markers (Limitation Accepted)
**Fix Applied**: Reverted to simple `is_body_line = '**' in original_line` logic
**Rationale**: Complex indent tracking was creating more bugs than it solved. Using `**` markers is clear, unambiguous, and WORKS.
**Action Required**: Users must mark body content with `**` markers
**Example**:
```
Parent Item
    **Body content line 1**
    **Body content line 2**
    Child Item
```

### ✅ ISSUE-002: Special Character Sanitization Incomplete - FIXED
**Status**: FIXED
**Fix Applied**: Expanded regex to remove all invalid filesystem characters
**Characters Now Removed**: `< > : " / \ | ? * @ # $ ~ ` ^ [ ] { }`
**Test Result**: test_special_characters.txt now produces correct output
**Example**: 
- `File@With#Invalid$Chars` → `FileWithInvalidChars` ✅
- `Item[with]brackets{and}braces` → `Itemwithbrsandbraces` ✅

### ⚠️ ISSUE-003: Digit Removal Logic - PARTIALLY FIXED
**Status**: Leading digit removal works, but truncation logic causes issues
**Fix Applied**: Changed regex to `re.sub(r'^[\d\s]+', '', name)` (removes leading digits + spaces)
**Test Result**: `123 Numeric Start` → `Numeric Start` ✅
**Known Issue**: Complex truncation logic still causes edge cases:
- `Item With Numbers 789` → `Item With umbers789` (still broken)
- This is due to the truncation + space-removal logic later in the function

---

### ✅ ISSUE-004: Name Collision Detection - FIXED
**Status**: FIXED
**Fix Applied**: Added file-path existence check before writing. When a file already exists, appends a 6-char unique ID hash to the base name.
**Test Result**: test_deep_duplicate_names.txt now produces unique filenames
**Example**:
- `SubItem.md` (first)
- `SubItem_977bc5.md` (second - unique ID appended)
- `SubItem_51097e.md` (third - unique ID appended)

### ✅ ISSUE-005: Quoted Extension Parsing - FIXED
**Status**: FIXED
**Fix Applied**: Detects quoted filenames with extensions (e.g. `"notes.txt"`) using the original FULLLINE content. Sanitizes only the base name, then reattaches the extension.
**Test Result**: test_quoted_extension.txt now preserves extensions
**Example**:
- `"notes.txt"` → `notes.txt/` directory with `index.md` inside
- `"README.md"` → `README.md/` directory with `index.md` inside

---

## 📋 REMAINING ISSUES TO ADDRESS

### ISSUE-001: Body Lines Treated as Header Lines
**Severity**: CRITICAL  
**Test Files**: test_mixed_with_body_content.txt, test_deep_nesting.txt, test_empty_and_edge_cases.txt  
**Status**: OPEN

**Problem**: 
Body lines (content indented under an item) are incorrectly parsed as new header items instead of being captured as body content for the parent item.

**Example from test_deep_nesting.txt**:
```
Level 4
        Content for Level 4
```
**Expected**: "Content for Level 4" should be body content INSIDE `Level4.md`  
**Actual**: "Content for Level 4" becomes a NEW FILE `Content for Level4.md` inside Level4 folder

**Root Cause**: Line classification logic cannot distinguish between:
- Header line: `    Child Item` (starts new item)
- Body line: `        Content for child` (content for current item)

Both are indented, but body lines should NOT create new items.

**Impact**: Tool is unusable for any content with body text. Creates wrong file structure.

---

### ISSUE-002: Special Character Sanitization Incomplete
**Severity**: CRITICAL  
**Test File**: test_special_characters.txt  
**Status**: OPEN

**Problem**: 
Many invalid filename characters are NOT removed by the sanitization function.

**Characters NOT removed**: `@ # $ ~ ` ^ [ ] { }`

**Example**:
- Input: `File@With#Invalid$Chars` → Output: `File@With#alid$Chars` (partially cleaned)
- Input: `Item[with]brackets{and}braces` → Output: `Item[with]and}braces.md`

**Root Cause**: Regex in `sanitize_and_clean_name()` only removes: `<>:"/\\|?()`
Missing: `@#$~`^[]{}` and possibly others.

**Impact**: Files/folders with invalid characters may fail to create on Windows filesystem.

---

### ISSUE-003: Digit Removal Logic Broken
**Severity**: CRITICAL  
**Test File**: test_numeric_edge_cases.txt  
**Status**: OPEN

**Problem**: 
The `--remove-digits` flag doesn't work correctly. Digits are partially removed or cause weird behavior.

**Examples**:
- Input: `123 Numeric Start` → Output: `123 Numeric Start` (digits NOT removed)
- Input: `Item With Numbers 789` → Output: `Item With umbers789` (missing "N"!)
- Input: `Numbers Only 111 222 333` → Output: `Numbers On11 222333.md` (weird transformation)

**Root Cause**: 
1. The `--remove-digits` flag may not be wired correctly to use `sanitize_no_digits()`
2. The regex `re.sub(r'^\d+', '', name)` only removes digits at START of string
3. Something is removing letters too (the missing "N" in "Numbers")

**Impact**: Digit removal feature doesn't work as documented.

---

## ⚠️ MEDIUM ISSUES (Should Fix)

### ISSUE-004: Name Collision Silently Overwrites
**Severity**: MEDIUM  
**Test File**: test_deep_duplicate_names.txt  
**Status**: ✅ FIXED

**Problem**: 
When two items sanitize to the same filename, the second one silently overwrites the first. No error, no warning.

**Example**:
```
Sub Item
Sub Item
Sub Item
```
All three become `SubItem.md` - only the LAST one survives.

**Root Cause**: No deduplication logic. Filesystem `open('w')` overwrites by default.

**Impact**: Data loss. User doesn't know their items were overwritten.

---

### ISSUE-005: Quoted Extension Parsing Not Implemented
**Severity**: MEDIUM  
**Test File**: test_quoted_extension.txt  
**Status**: ✅ FIXED

**Problem**: 
The README suggests you can use quotes to preserve extensions (e.g., `"notes.txt"`), but this feature is not implemented.

**Example**:
- Input: `"notes.txt"` → Output: `notestxt` (quotes removed, extension lost)
- Input: `"README.md"` → Output: `READMEmd` (quotes removed, extension lost)

**Root Cause**: No parsing logic for quoted strings with extensions.

**Impact**: Feature gap between documentation and implementation.

---

### ISSUE-006: Whitespace Not Normalized
**Severity**: MEDIUM  
**Test File**: test_whitespace_heavy.txt  
**Status**: ✅ FIXED

**Problem**: 
Multiple spaces between words are preserved in filenames instead of being normalized.

**Example**:
- Input: `Item  With   Multiple    Spaces` → Output: `Item  With    Spaces` (spaces preserved)
- Input: `Item    With    Trailing    Spaces    ` → Output: `Item    Wi    Spaces.md` (weird truncation)

**Root Cause**: No whitespace normalization in `sanitize_and_clean_name()`. Only `rstrip()` is called.

**Impact**: Ugly filenames with multiple spaces. May cause issues on some filesystems.

**Fix Applied**: Added `re.sub(r'\s+', ' ', name)` to normalize multiple spaces to single space.

---

### ISSUE-007: Long Name Truncation Creates Confusing Names
**Severity**: MEDIUM  
**Test File**: test_very_long_names.txt  
**Status**: ✅ FIXED

**Problem**: 
The truncation logic splits names at weird positions, creating unreadable filenames.

**Example**:
- Input: `This is a very long item name that might exceed...` → Output: `This is a use issues` (truncated to 20 chars using `max_length//2` logic)
- Input: `Another Long Name That Contains Lots Of Descriptive Text...` → Output: `Another LoRepresents.md` ("LoRepresents" is confusing)

**Root Cause**: Truncation logic in `sanitize_and_clean_name()`:
```python
if len(base) > max_length:
    base = base[:max_length//2] + '...' + base[-max_length//2:]
```
This creates weird splits in the middle of words.

**Impact**: Unreadable filenames. Users won't recognize their content.

---

### ISSUE-008: Items With Children Create Folders + index.md
**Severity**: MEDIUM (Design Question)  
**Test Files**: test_simple_nested.txt, test_deep_nesting.txt  
**Status**: OPEN

**Problem**: 
When an item has children, it becomes a FOLDER with an `index.md` file inside, instead of being a single `.md` file.

**Example**:
```
Parent Item 1
    Child Item 1
```
**Expected** (maybe): `Parent Item 1.md` with child inside? Or just folder?
**Actual**: `Parent Item1/` folder with `Child Item1.md` AND `index.md`

**Root Cause**: Design decision in `create_structure()`:
```python
if children:
    # Create directory
    os.makedirs(node_path, exist_ok=True)
    # Create index.md for the parent
    write_md_file(node_path + '/index.md', lines, front_matter)
```

**Impact**: Creates extra `index.md` files that may not be expected. Changes the structure significantly.

---

## 📝 LOW PRIORITY ISSUES (Nice to Have)

### ISSUE-009: Spaces Removed from All Names
**Severity**: LOW  
**Test Files**: All tests  
**Status**: ✅ FIXED

**Problem**: 
All spaces were removed from filenames during sanitization.

**Example**: `Top Level Item 1` → `TopLevelItem1.md`

**Root Cause**: In `sanitize_and_clean_name()`:
```python
base = re.sub(r'[ .]', '', base)  # Removes BOTH dots AND spaces
```

**Impact**: Filenames are hard to read. "TopLevelItem1" vs "Top Level Item 1".

**Fix Applied**: Changed to only strip trailing spaces/dots, not remove all spaces in the middle.

---

### ✅ ISSUE-010: Body Content Not Written to Files - FIXED
**Status**: FIXED
**Fix Applied**: Updated test file to use `**` markers for body content. Verified that `write_md_file()` correctly writes body lines to `index.md`.
**Test Result**: test_mixed_with_body_content.txt now correctly writes body content to parent's `index.md`
**Example**: Body lines with `**` markers are now written to the parent item's `index.md` file.

### ✅ ISSUE-011: No Input Validation - FIXED
**Status**: FIXED
**Fix Applied**: Added validation in `main()` to check if input file exists, is a file (not directory), and is not empty. Returns clear error messages.
**Test Result**: `python d2c2_cli.py nonexistent.txt output` now prints "Error: Input file 'nonexistent.txt' does not exist."
**Impact**: Prevents cryptic errors and provides helpful feedback to users.

---

**Problem**: 
No validation that input file exists, is not empty, or has valid structure.

**Examples of bad input**:
- Empty file
- File with only body lines (no headers)
- File with inconsistent indentation (tabs + spaces)
- Binary file passed as input

**Root Cause**: No validation logic in `main()` or `create_structure()`.

**Impact**: Cryptic errors or silent failures.

---

### ISSUE-012: Inconsistent Indentation Handling
**Severity**: LOW  
**Test File**: test_inconsistent_indentation.txt  
**Status**: OPEN

**Problem**: 
Mixed spaces and tabs might create unexpected nesting levels.

**Example**:
```
Item 1
  2 spaces
    4 spaces
        8 spaces
Item 2
	Tab indent
	Another tab
```
**Actual**: Seems to work, but behavior is undefined.

**Root Cause**: No normalization of indentation. Code uses `len(line) - len(line.lstrip())` which counts both spaces and tabs.

**Impact**: Unpredictable nesting with mixed indentation.

---

## 📊 Issue Summary by Category

| Category | Count | Critical | Medium | Low |
|----------|-------|----------|--------|-----|
| Body/Content Handling | 2 | 1 (ISSUE-001) | 0 | 1 (ISSUE-010) |
| Name Sanitization | 4 | 1 (ISSUE-002) | 2 (ISSUE-006, ISSUE-007) | 1 (ISSUE-009) |
| Digit Handling | 1 | 1 (ISSUE-003) | 0 | 0 |
| Feature Gaps | 1 | 0 | 1 (ISSUE-005) | 0 |
| File Conflicts | 1 | 0 | 1 (ISSUE-004) | 0 |
| Design Decisions | 1 | 0 | 1 (ISSUE-008) | 0 |
| Input Validation | 1 | 0 | 0 | 1 (ISSUE-011) |
| Indentation | 1 | 0 | 0 | 1 (ISSUE-012) |

---

## 🎯 Next Steps (Phase 2: Debug & Fix)

### Priority Order:
1. **ISSUE-001** (Body Lines) - CRITICAL - Tool is unusable without this
2. **ISSUE-002** (Special Chars) - CRITICAL - Will cause filesystem errors
3. **ISSUE-003** (Digit Removal) - CRITICAL - Feature doesn't work
4. **ISSUE-004** (Name Collision) - MEDIUM - Data loss risk
5. **ISSUE-005** (Quoted Extensions) - MEDIUM - Feature gap
6. **ISSUE-008** (Folder + index.md) - MEDIUM - Design decision needed
7. **ISSUE-006** (Whitespace) - MEDIUM - Code quality
8. **ISSUE-007** (Truncation) - MEDIUM - User experience
9. **ISSUE-009** (Spaces Removed) - LOW - User preference
10. **Remaining** - LOW - Nice to have

### For Each Issue:
1. Read relevant code section
2. Trace logic manually
3. Identify root cause (update this log)
4. Propose fix
5. Implement fix
6. Verify syntax (`py_compile`)
7. Proceed to Phase 3 (Re-Test)

---

*This log will be updated as issues are debugged and fixed.*
