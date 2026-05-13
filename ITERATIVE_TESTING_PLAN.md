# DeTree - Iterative Testing Plan
**Date**: May 13, 2026  
**Objective**: Systematically test all features through text inputs, validate output structure, debug issues, and iterate

---

## Testing Strategy

### Core Concept
1. Create test input files covering various scenarios
2. Run CLI command against each test file
3. Verify output folder/file structure matches expectations
4. Document any unexpected behavior or errors
5. Fix issues in scripts
6. Re-run same test file and compare results
7. Iterate until all tests pass

### Tools to Use
- **Input**: Plain text files (`.txt`) with nested list structures
- **Execution**: `d2c2_cli.py` (most controlled interface)
- **Output Inspection**: PowerShell `Get-ChildItem -Recurse` to list structure
- **Cleanup**: PowerShell `Remove-Item -Recurse` to delete test output
- **Comparison**: Manual visual inspection vs. expected structure

---

## Test Cases to Create

### Test File 1: `test_simple_flat.txt`
**Purpose**: Test basic flat list (no nesting)
```
Top Level Item 1
Top Level Item 2
Top Level Item 3
```
**Expected Output**:
```
output/
├── Top Level Item 1.md
├── Top Level Item 2.md
└── Top Level Item 3.md
```
**Tests**: Basic file creation, no nesting logic

---

### Test File 2: `test_simple_nested.txt`
**Purpose**: Test one level of nesting
```
Parent Item 1
    Child Item 1
    Child Item 2
Parent Item 2
    Child Item 3
```
**Expected Output**:
```
output/
├── Parent Item 1/
│   ├── Child Item 1.md
│   └── Child Item 2.md
└── Parent Item 2/
    └── Child Item 3.md
```
**Tests**: Stack-based directory/file logic, indentation parsing

---

### Test File 3: `test_deep_nesting.txt`
**Purpose**: Test multiple levels of nesting
```
Level 1
    Level 2
        Level 3
            Level 4
                Content for Level 4
        Another Level 3
```
**Expected Output**:
```
output/
└── Level 1/
    └── Level 2/
        ├── Level 3/
        │   └── Level 4/
        │       └── Level 4.md (with body content)
        └── Another Level 3.md
```
**Tests**: Deep stack handling, multiple indentation levels

---

### Test File 4: `test_mixed_with_body_content.txt`
**Purpose**: Test body lines attached to items
```
Parent Item
    Body line 1 for parent
    Body line 2 for parent
    Child Item 1
        Body line for child
    Child Item 2
```
**Expected Output**:
```
output/
└── Parent Item.md (contains body lines in content)
    ├── Child Item 1.md (contains body lines)
    └── Child Item 2.md
```
**Tests**: Body line attachment, file content generation

---

### Test File 5: `test_special_characters.txt`
**Purpose**: Test name sanitization
```
File@With#Invalid$Chars
    Child!Name%Test
Another~File`With^Special
Item[with]brackets{and}braces
```
**Expected Output**:
```
output/
├── FileWithInvalidChars/
│   └── ChildNameTest.md
├── AnotherFileWithSpecial.md
└── Itemwithbracketsandbraces.md
```
**Tests**: Character sanitization regex, invalid character removal

---

### Test File 6: `test_numeric_edge_cases.txt`
**Purpose**: Test items with numbers and digit handling
```
123 Numeric Start
    456 Child Number
Item With Numbers 789
    No Numbers Here
Numbers Only 111 222 333
```
**Expected Output** (with digit removal):
```
output/
├──  Numeric Start/
│   └──  Child Number.md
├── Item With Numbers .md
├──  No Numbers Here.md
└── Numbers Only   .md
```
**Tests**: Digit removal logic (if enabled), numeric sanitization

---

### Test File 7: `test_empty_and_edge_cases.txt`
**Purpose**: Test edge cases (empty items, only body content, etc.)
```
Item With Content
    Body content here
    More body content
Empty Item

Item After Empty
    Child 1
    
    Child 2
```
**Expected Output**:
```
output/
├── Item With Content.md
├── Empty Item.md (empty file)
└── Item After Empty/
    ├── Child 1.md
    └── Child 2.md
```
**Tests**: Empty item handling, body line attachment, spacing

---

### Test File 8: `test_quoted_extension.txt`
**Purpose**: Test extension parsing from quotes (if implemented)
```
"notes.txt"
    Child Item
"README.md"
    Documentation content
Plain Item
```
**Expected Output** (if implemented):
```
output/
├── notes.txt (preserves extension)
├── README.md (preserves extension)
└── Plain Item.md (default .md)
```
**Tests**: Quote parsing, extension preservation

---

### Test File 9: `test_inconsistent_indentation.txt`
**Purpose**: Test behavior with mixed spaces/tabs or malformed indentation
```
Item 1
  2 spaces
    4 spaces
        8 spaces
Item 2
	Tab indent
	Another tab
```
**Expected Output**: May vary; tests error handling and indentation detection

---

### Test File 10: `test_deep_duplicate_names.txt`
**Purpose**: Test name collision handling
```
Item Name
    Sub Item
    Sub Item
    Sub Item
Another
    Sub Item
    Sub Item
```
**Expected Output**: Observe how duplicates are handled (overwrite? error? deduplicate?)

---

### Test File 11: `test_very_long_names.txt`
**Purpose**: Test filesystem name length limits
```
This is a very long item name that might exceed Windows filename length limits and could cause issues
    Short child
Another Long Name That Contains Lots Of Descriptive Text About What This Item Represents
```
**Expected Output**: Observe how long names are truncated or handled

---

### Test File 12: `test_whitespace_heavy.txt`
**Purpose**: Test handling of extra whitespace
```
Item  With   Multiple    Spaces
    Child    Item
        Deeply    Nested    Item
Item    With    Trailing    Spaces    
```
**Expected Output**: Observe whitespace normalization

---

## Testing Workflow

### Phase 1: Initial Test Run
1. Create all test files (1-12 above)
2. For each test file:
   ```powershell
   cd c:\dev\DeTree_formerly_Docs2saurus
   python d2c2_cli.py -i test_simple_flat.txt -o output_test_01
   ```
3. Inspect output:
   ```powershell
   Get-ChildItem -Path output_test_01 -Recurse | Format-Table FullName
   ```
4. Compare against expected output
5. Document differences

### Phase 2: Issue Logging
For each test that produces unexpected output:
- **Test File**: `test_simple_flat.txt`
- **Issue ID**: `ISSUE-001`
- **Issue Description**: Behavior vs. Expected
- **Severity**: Critical / High / Medium / Low
- **Steps to Reproduce**: Exact command run
- **Actual Output**: What structure was created
- **Expected Output**: What should have been created
- **Root Cause**: (filled in after debugging)

### Phase 3: Debug & Fix
For each issue:
1. Read relevant code section
2. Trace logic manually
3. Identify root cause
4. Propose fix
5. Implement fix
6. Verify syntax
7. Proceed to Phase 4

### Phase 4: Re-Test
For each fixed issue:
1. Delete old test output folder
2. Re-run exact same command with same input file
3. Compare new output to expected output
4. Document result (PASS / STILL BROKEN)
5. If broken, return to Phase 3

### Phase 5: Regression Testing
Once all issues fixed:
1. Re-run ALL tests (1-12) in sequence
2. Verify no new issues introduced
3. Document final results

---

## Testing Commands Reference

```powershell
# Navigate to project
cd c:\dev\DeTree_formerly_Docs2saurus

# Run CLI command
python d2c2_cli.py -i TEST_FILE.txt -o output_folder

# List output structure with details
Get-ChildItem -Path output_folder -Recurse -File | Format-Table FullName, Length

# List as tree
tree output_folder /f

# Count files created
(Get-ChildItem -Path output_folder -Recurse -File).Count

# Delete test output
Remove-Item -Path output_folder -Recurse -Force

# View file content
Get-Content output_folder\filename.md

# Search for errors in output
Get-ChildItem -Path output_folder -Recurse -File | ForEach-Object { if ((Get-Content $_) -match 'error|exception') { $_ } }
```

---

## Expected Issues to Investigate

Based on code review, we should proactively test for:

1. **Empty Stack on Body Lines**: Do body lines crash if they appear before any header?
2. **Extension Doubling**: Does `Item.md` become `Item.md.md`?
3. **Name Collision**: What happens with duplicate names after sanitization?
4. **Deep Nesting**: Does stack management fail at very deep levels?
5. **Whitespace**: Are multiple spaces in names normalized?
6. **Body Line Content**: Does body content correctly appear in output files?
7. **Empty Files**: Are empty items (no children, no body) created correctly?
8. **Special Characters**: Are all invalid characters properly removed?

---

## Success Criteria

### Test Passing
✅ Output structure matches expected structure exactly  
✅ File contents (if applicable) are correct  
✅ No error messages or crashes  
✅ Performance acceptable (< 5 seconds for any test)

### Test Failing
❌ Missing files or folders  
❌ Extra unexpected files or folders  
❌ Wrong file names (sanitization error)  
❌ Wrong file content  
❌ Script crashes or error message  
❌ Wrong folder structure (directory vs. file confusion)

---

## Iteration Record Template

| Test # | File | Issue Found | Status | Fix Applied | Re-Test Result |
|--------|------|-------------|--------|-------------|-----------------|
| 1 | test_simple_flat.txt | None | ✅ PASS | N/A | N/A |
| 2 | test_simple_nested.txt | ? | ? | ? | ? |
| 3 | test_deep_nesting.txt | ? | ? | ? | ? |
| ... | ... | ... | ... | ... | ... |

---

## Notes

- **Cleanup**: Always delete test output folders between iterations to avoid confusion
- **Isolation**: Run one test at a time, don't accumulate test outputs
- **Reproducibility**: Keep test files; can re-run anytime to verify
- **Documentation**: Record everything; helps identify patterns in failures
- **Patience**: Some issues may require multiple iteration cycles
- **Assumptions**: Remember body line behavior might not be fully correct per earlier review

---

## Next Steps

1. ✅ Create all test files (01-12)
2. ⏳ Run Phase 1 initial tests
3. ⏳ Log all issues found
4. ⏳ Debug and fix each issue
5. ⏳ Re-test fixed issues
6. ⏳ Run full regression test suite
7. ⏳ Document final results

---

*This plan ensures systematic validation of all features before declaring the tool production-ready.*
