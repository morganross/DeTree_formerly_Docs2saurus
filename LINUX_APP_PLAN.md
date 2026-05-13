# DeTree → Linux CLI Application: Complete Implementation Plan

## Overview

This document outlines all steps required to transform DeTree from a Python script into a professional Linux CLI application (like `tree` or `curl`).

---

## Phase 1: Make it Executable (Python Script → CLI Command)

### Step 1.1: Add Shebang Line

Add this as the **very first line** of `d2c2_cli.py`:

```python
#!/usr/bin/env python3
```

**Purpose**: Allows direct execution without typing `python3` prefix.

### Step 1.2: Make it Executable (Linux/Unix)

```bash
chmod +x d2c2_cli.py
```

**Now users can run**:
```bash
./d2c2_cli.py input.txt output/
```

### Step 1.3: Rename for CLI Friendliness (Recommended)

```bash
cp d2c2_cli.py detree
chmod +x detree
```

**Now users run**:
```bash
./detree input.txt output/
```

---

## Phase 2: System-Wide Installation (like `tree` or `curl`)

### Step 2.1: Create `setup.py` for pip Installation

Create `setup.py` in the project root:

```python
#!/usr/bin/env python3
"""
Setup script for DeTree - Convert nested text lists into directory structures.
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="detree",
    version="1.0.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="Convert nested text lists into hierarchical directory structures",
    long_description=long_description,
    long_description_content_type="text/markdown",
    py_modules=["d2c2_cli"],  # Single module distribution
    url="https://github.com/yourusername/DeTree",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Topic :: Utilities",
        "Topic :: Software Development :: Documentation",
    ],
    python_requires=">=3.6",
    entry_points={
        "console_scripts": [
            "detree=d2c2_cli:main",  # Creates `detree` command
        ],
    },
    include_package_data=True,
)
```

### Step 2.2: Install System-Wide with pip

**Development install** (editable):
```bash
pip install -e .
```

**Production install**:
```bash
pip install .
```

**Now users can run from anywhere**:
```bash
detree input.txt output/
detree --help
```

---

## Phase 3: Create Standalone Binary (No Python Required)

### Step 3.1: Use PyInstaller

**Install PyInstaller**:
```bash
pip install pyinstaller
```

**Create standalone executable**:
```bash
pyinstaller --onefile --name detree d2c2_cli.py
```

**Result**: `dist/detree` (Linux binary, ~10MB)

**Users can now**:
```bash
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-linux
chmod +x detree-linux
sudo mv detree-linux /usr/local/bin/detree
detree --help
```

### Step 3.2: Cross-Platform Binaries

**Build on Linux for Linux**:
```bash
pyinstaller --onefile --name detree-linux d2c2_cli.py
```

**Build on Windows for Windows**:
```powershell
pyinstaller --onefile --name detree-windows.exe d2c2_cli.py
```

**Build on macOS for macOS**:
```bash
pyinstaller --onefile --name detree-macos d2c2_cli.py
```

---

## Phase 4: Linux Distribution Packages

### Step 4.1: Debian/Ubuntu Package (.deb)

**Install packaging tools**:
```bash
sudo apt install build-essential dh-make devscripts
```

**Create Debian package structure**:
```bash
# Rename for Debian conventions
cp d2c2_cli.py detree.py

# Create orig tarball
tar -czf detree_1.0.0.orig.tar.gz detree.py README.md setup.py

# Initialize Debian package
dh_make --createorig --single --native

# Build package
dpkg-buildpackage -us -uc

# Result: detree_1.0.0.deb
```

**Install .deb package**:
```bash
sudo dpkg -i detree_1.0.0.deb
sudo apt install -f  # Fix dependencies if any
```

### Step 4.2: Red Hat/Fedora Package (.rpm)

**Install RPM tools**:
```bash
sudo dnf install rpm-build python3-setuptools
```

**Build RPM**:
```bash
python3 setup.py bdist_rpm
# Result: dist/detree-1.0.0-1.noarch.rpm
```

**Install .rpm package**:
```bash
sudo rpm -ivh dist/detree-1.0.0-1.noarch.rpm
```

---

## Phase 5: Add Bash Completion (Professional Touch)

### Step 5.1: Create Completion Script

Create `/etc/bash_completion.d/detree` (system-wide) or `~/.local/share/bash-completion/completions/detree` (user):

```bash
# /etc/bash_completion.d/detree
_detree_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Main options
    opts="--remove-digits --allow-empty-folders --help --version"

    # If current word starts with -, show options
    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
    
    # Complete filenames for first argument
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -f -- ${cur}) )
        return 0
    fi
    
    # Complete directories for second argument
    if [[ ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=( $(compgen -d -- ${cur}) )
        return 0
    fi
}

complete -F _detree_completion detree
```

**Activate completion**:
```bash
source /etc/bash_completion.d/detree
```

**Now users can type**:
```bash
detree <TAB><TAB>  # Shows options
detree input<TAB>     # Completes filename
detree input.txt out<TAB>  # Completes directory
```

---

## Phase 6: Create Makefile (Easy Building)

### Step 6.1: Create `Makefile`

```makefile
.PHONY: install uninstall clean test package

# Install system-wide via pip
install:
	pip install --user .
	@echo "DeTree installed. Run 'detree --help' to verify."

# Uninstall
uninstall:
	pip uninstall detree -y
	@echo "DeTree uninstalled."

# Create standalone binary
binary:
	pyinstaller --onefile --name detree d2c2_cli.py
	@echo "Binary created: dist/detree"

# Run all tests
test:
	@echo "Running all tests..."
	cd c:\dev\DeTree_formerly_Docs2saurus && \
	python d2c2_cli.py test_simple_flat.txt output_t01 && \
	python d2c2_cli.py test_simple_nested.txt output_t02 && \
	echo "All tests passed!"

# Build distribution packages
package:
	python setup.py sdist bdist_wheel
	@echo "Packages created in dist/"

# Clean build artifacts
clean:
	rm -rf build/ dist/ *.egg-info/
	rm -rf __pycache__/ *.pyc
	find . -name "__pycache__" -type d -exec rm -rf {} +
	@echo "Cleaned."

# Publish to PyPI (requires twine)
publish: package
	twine upload dist/*
```

**Usage**:
```bash
make install      # Install system-wide
make test         # Run tests
make binary       # Create standalone binary
make package      # Build pip packages
make clean        # Clean artifacts
```

---

## Phase 7: Update README for Linux Users

### Step 7.1: Add Installation Section to README.md

```markdown
## Installation (Linux)

### Quick Install via pip (Recommended)
```bash
pip install detree
detree --help
```

### Install from Source
```bash
git clone https://github.com/yourusername/DeTree.git
cd DeTree
make install
```

### Download Standalone Binary (No Python Required)
```bash
wget https://github.com/yourusername/DeTree/releases/latest/download/detree-linux
chmod +x detree-linux
sudo mv detree-linux /usr/local/bin/detree
detree --help
```

### Install via Package Manager

**Debian/Ubuntu**:
```bash
sudo dpkg -i detree_1.0.0.deb
```

**Fedora/RHEL**:
```bash
sudo rpm -ivh detree-1.0.0-1.noarch.rpm
```

### Manual Install (Symlink)
```bash
chmod +x d2c2_cli.py
sudo ln -s $(pwd)/d2c2_cli.py /usr/local/bin/detree
```
```

---

## Phase 8: Comparison to `tree` and `curl`

### Feature Comparison

| Feature | `tree` | `curl` | `detree` (DeTree) |
|---------|--------|--------|-------------------|
| **Language** | C | C | Python 3 |
| **Binary size** | ~50KB | ~500KB | ~10MB (with PyInstaller) or ~15KB (script) |
| **Install method** | `apt install tree` | Pre-installed | `pip install detree` |
| **Dependencies** | None | None | Python 3 only |
| **System-wide location** | `/usr/bin/tree` | `/usr/bin/curl` | `/usr/local/bin/detree` |
| **User runs** | `tree .` | `curl URL` | `detree input.txt output/` |
| **Tab completion** | Yes | Yes | Yes (with script) |
| **Config files** | None | `~/.curlrc` | None (yet) |

---

## Phase 9: Minimal Requirements Checklist

### Required for Basic CLI App:
- [ ] Add shebang: `#!/usr/bin/env python3`
- [ ] Make executable: `chmod +x d2c2_cli.py`
- [ ] Create `setup.py` for pip installation
- [ ] Test: `pip install .` then `detree --help`

### Recommended for Professional App:
- [ ] Create standalone binary with PyInstaller
- [ ] Add bash completion script
- [ ] Create Makefile for easy building
- [ ] Build `.deb` and `.rpm` packages
- [ ] Update README with installation instructions
- [ ] Add to GitHub releases

### Optional (Advanced):
- [ ] Create systemd service (if daemon needed)
- [ ] Add config file support (`/etc/detree.conf`)
- [ ] Implement plugin system
- [ ] Add man page (`man detree`)

---

## Phase 10: Quick Implementation (Do This Now)

### 10.1: Add Shebang to `d2c2_cli.py`

**Add as first line**:
```python
#!/usr/bin/env python3
```

### 10.2: Create `setup.py`

**Save this as `setup.py`** (see Phase 2.1 for full content).

### 10.3: Test Installation

```bash
cd c:\dev\DeTree_formerly_Docs2saurus

# Install
pip install .

# Test
detree --help

# Should show:
# usage: detree [-h] [--remove-digits] [--allow-empty-folders] input_file output_dir
```

### 10.4: Create Binary (Optional)

```bash
pip install pyinstaller
pyinstaller --onefile --name detree d2c2_cli.py
# Result: dist/detree
```

---

## Phase 11: File Structure After Transformation

### Before (Python Script):
```
DeTree_formerly_Docs2saurus/
├── d2c2_cli.py          # Main script
├── README.md
├── test_*.txt            # Test files
└── .git/
```

### After (Linux CLI App):
```
DeTree/
├── detree                # Symlink or binary
├── d2c2_cli.py          # Main script (with shebang)
├── setup.py              # pip installation
├── Makefile              # Build system
├── README.md             # Updated with install instructions
├── bash_completion.d/
│   └── detree           # Tab completion script
├── dist/
│   ├── detree           # Standalone binary (Linux)
│   ├── detree.exe       # Standalone binary (Windows)
│   └── detree-macos    # Standalone binary (macOS)
├── debian/              # Debian package files
├── detree.egg-info/     # pip package metadata
├── test_*.txt           # Test files
└── .git/
```

---

## Phase 12: Publishing to Package Indexes

### 12.1: Publish to PyPI (Python Package Index)

```bash
# Install twine
pip install twine

# Build packages
python setup.py sdist bdist_wheel

# Upload to PyPI
twine upload dist/*

# Now anyone can install:
pip install detree
```

### 12.2: GitHub Releases (for Binaries)

```bash
# Create release
git tag v1.0.0
git push origin v1.0.0

# Attach binaries via GitHub web interface:
# - dist/detree (Linux binary)
# - dist/detree.exe (Windows binary)
# - dist/detree-macos (macOS binary)
```

---

## Summary: Time to Implement

| Phase | Task | Time Estimate |
|-------|------|---------------|
| Phase 1 | Make executable | 5 minutes |
| Phase 2 | pip installation | 15 minutes |
| Phase 3 | Standalone binary | 30 minutes |
| Phase 4 | Linux packages (.deb, .rpm) | 1-2 hours |
| Phase 5 | Bash completion | 15 minutes |
| Phase 6 | Makefile | 10 minutes |
| Phase 7 | Update README | 10 minutes |
| Phase 8-12 | Publishing | 30 minutes |

**Total for basic CLI app**: ~1 hour  
**Total for full Linux app**: ~3-4 hours

---

## Next Step

**Want me to implement Phase 1 + 2 + 6 right now?** (Takes ~20 minutes)

I'll:
1. Add shebang to `d2c2_cli.py`
2. Create `setup.py`
3. Create `Makefile`
4. Test `pip install .`
5. Verify `detree` command works

Just say **"Implement Phase 1-2"** and I'll do it now! 🐧
