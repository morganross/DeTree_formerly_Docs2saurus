# DeTree - Repository Cleanup for Publishing

## Current State Analysis

### Files to KEEP (Essential for publishing):
- `d2c2_cli.py` - Main CLI tool (the primary deliverable)
- `README.md` - User documentation
- `ISSUE_LOG.md` - Bug tracking (optional, can be removed)
- `ITERATIVE_TESTING_PLAN.md` - Testing documentation (optional)
- Test files (12 files) - For validation
- `.git/` - Version control

### Files to ARCHIVE (Development history):
- `ALL_FIXES_IMPLEMENTED_ARCHIVED.md`
- `ANALYSIS_REPORT_ARCHIVED.md`
- `COMPLETE_ANALYSIS_ARCHIVED.md`
- `IMPROVEMENT_REPORT_ARCHIVED.md`
- `INDENT_LOGIC_REPORT_ARCHIVED.md`
- `LOGIC_ISSUES_REPORT_ARCHIVED.md`
- `README_LOGIC_TRACE_ARCHIVED.md`
- `SOLUTION_PROPOSALS_ARCHIVED.md`
- `DE_TREE_FULL_PROJECT_KNOWLEDGE.md`
- `SESSION_2_PROGRESS_REPORT.md`
- `FINAL_SESSION_SUMMARY.md`
- `REVIEW_OF_CHANGES.md`

### Files to REMOVE (Old/unused versions):
- `d2c2.py` - Old GUI version (superseded by CLI)
- `d2cgood.py` - Alternative GUI (unused)
- `docgui.py` - Another GUI version (unused)

### Directories to REMOVE (Test outputs):
- `output_t/` and all `output_t01` through `output_t12`
- `output_test_01` through `output_test_13`
- `__pycache__/`

---

## Cleanup Commands (PowerShell)

### Step 1: Remove old/unused Python files
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus
Remove-Item d2c2.py, d2cgood.py, docgui.py -Force
Write-Host "Removed old Python files" -ForegroundColor Green
```

### Step 2: Remove test output directories
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus
Get-ChildItem -Directory output_* | Remove-Item -Recurse -Force
Remove-Item __pycache__ -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Removed test output directories" -ForegroundColor Green
```

### Step 3: Archive development history (optional)
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus
New-Item -ItemType Directory -Name "dev_history" -ErrorAction SilentlyContinue
$archiveFiles = @(
    "ALL_FIXES_IMPLEMENTED_ARCHIVED.md",
    "ANALYSIS_REPORT_ARCHIVED.md",
    "COMPLETE_ANALYSIS_ARCHIVED.md",
    "IMPROVEMENT_REPORT_ARCHIVED.md",
    "INDENT_LOGIC_REPORT_ARCHIVED.md",
    "LOGIC_ISSUES_REPORT_ARCHIVED.md",
    "README_LOGIC_TRACE_ARCHIVED.md",
    "SOLUTION_PROPOSALS_ARCHIVED.md",
    "DE_TREE_FULL_PROJECT_KNOWLEDGE.md",
    "SESSION_2_PROGRESS_REPORT.md",
    "FINAL_SESSION_SUMMARY.md",
    "REVIEW_OF_CHANGES.md"
)
foreach ($file in $archiveFiles) {
    if (Test-Path $file) {
        Move-Item $file "dev_history\" -Force
    }
}
Write-Host "Archived development history" -ForegroundColor Green
```

### Step 4: Create a clean README.md (if needed)
The current README.md should be checked and updated to reflect:
- Tool name: DeTree (formerly Docs2saurus)
- Primary tool: `d2c2_cli.py`
- Body content requires `**` markers
- All 12 tests pass

### Step 5: Verify clean state
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus
Get-ChildItem | Select-Object Name, PSIsContainer
```

---

## Minimal Publishing Package

For a minimal publish (just the essentials):

### Keep:
1. `d2c2_cli.py` - The main tool
2. `README.md` - Documentation
3. Test files (12 `.txt` files) - For validation
4. `.git/` - Version control

### Remove everything else:
```powershell
cd c:\dev\DeTree_formerly_Docs2saurus

# Remove all .md files except README.md
Get-ChildItem *.md | Where-Object { $_.Name -ne "README.md" } | Remove-Item -Force

# Remove old Python files
Remove-Item *.py -Exclude d2c2_cli.py -Force

# Remove test outputs
Get-ChildItem -Directory output_* | Remove-Item -Recurse -Force
Remove-Item __pycache__ -Recurse -Force -ErrorAction SilentlyContinue

# Remove test files (optional - keep if you want to distribute tests)
# Remove-Item test_*.txt -Force
```

---

## Recommended Clean Structure for Publishing

```
DeTree_formerly_Docs2saurus/
├── d2c2_cli.py              # Main CLI tool
├── README.md                 # Documentation
├── ISSUE_LOG.md              # Bug tracking (optional)
├── ITERATIVE_TESTING_PLAN.md # Testing docs (optional)
├── test_simple_flat.txt     # Test files (12 files)
├── test_simple_nested.txt
├── ... (other test files)
└── .git/                    # Version control
```

---

## Quick Cleanup Script

Save this as `cleanup_for_publish.ps1`:

```powershell
# cleanup_for_publish.ps1
# Run from: c:\dev\DeTree_formerly_Docs2saurus

Write-Host "Starting cleanup for publishing..." -ForegroundColor Cyan

# 1. Remove old Python files
$oldFiles = @("d2c2.py", "d2cgood.py", "docgui.py")
foreach ($file in $oldFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  Removed: $file" -ForegroundColor Yellow
    }
}

# 2. Remove test output directories
Get-ChildItem -Directory output_* | ForEach-Object {
    Remove-Item $_ -Recurse -Force
    Write-Host "  Removed directory: $_" -ForegroundColor Yellow
}

# 3. Remove __pycache__
if (Test-Path "__pycache__") {
    Remove-Item __pycache__ -Recurse -Force
    Write-Host "  Removed: __pycache__" -ForegroundColor Yellow
}

# 4. Archive development history (optional - comment out if you want to delete instead)
New-Item -ItemType Directory -Name "dev_history" -ErrorAction SilentlyContinue | Out-Null
$archiveFiles = @(
    "ALL_FIXES_IMPLEMENTED_ARCHIVED.md",
    "ANALYSIS_REPORT_ARCHIVED.md",
    "COMPLETE_ANALYSIS_ARCHIVED.md",
    "IMPROVEMENT_REPORT_ARCHIVED.md",
    "INDENT_LOGIC_REPORT_ARCHIVED.md",
    "LOGIC_ISSUES_REPORT_ARCHIVED.md",
    "README_LOGIC_TRACE_ARCHIVED.md",
    "SOLUTION_PROPOSALS_ARCHIVED.md",
    "DE_TREE_FULL_PROJECT_KNOWLEDGE.md",
    "SESSION_2_PROGRESS_REPORT.md",
    "FINAL_SESSION_SUMMARY.md",
    "REVIEW_OF_CHANGES.md"
)
foreach ($file in $archiveFiles) {
    if (Test-Path $file) {
        Move-Item $file "dev_history\" -Force
        Write-Host "  Archived: $file" -ForegroundColor Cyan
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "`nCurrent directory contents:" -ForegroundColor Cyan
Get-ChildItem | Select-Object Name, PSIsContainer, Length | Format-Table -AutoSize
```

Run with: `.\cleanup_for_publish.ps1`

---

## Final Checklist Before Publishing

- [ ] `d2c2_cli.py` is the primary tool
- [ ] `README.md` is up-to-date with `**` marker requirement
- [ ] All 12 tests pass
- [ ] No test output directories remain
- [ ] No old/unused Python files remain
- [ ] Development history archived (or deleted)
- [ ] `.gitignore` includes `output_*` and `__pycache__/`
- [ ] Ready to push to GitHub!

---

**Recommendation**: Archive the development history in a `dev_history/` folder rather than deleting it. This preserves the work done while keeping the main repo clean.
