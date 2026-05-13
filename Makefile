.PHONY: install uninstall clean test binary package publish

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
	python d2c2_cli.py test_deep_nesting.txt output_t03 && \
	python d2c2_cli.py test_mixed_with_body_content.txt output_t04 && \
	python d2c2_cli.py test_special_characters.txt output_t05 && \
	python d2c2_cli.py test_numeric_edge_cases.txt output_t06 --remove-digits && \
	python d2c2_cli.py test_empty_and_edge_cases.txt output_t07 && \
	python d2c2_cli.py test_quoted_extension.txt output_t08 && \
	python d2c2_cli.py test_inconsistent_indentation.txt output_t09 && \
	python d2c2_cli.py test_deep_duplicate_names.txt output_t10 && \
	python d2c2_cli.py test_very_long_names.txt output_t11 && \
	python d2c2_cli.py test_whitespace_heavy.txt output_t12 && \
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
