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
