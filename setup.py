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
    author="DeTree Contributors",
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
        "Topic :: System :: Filesystems",
    ],
    python_requires=">=3.6",
    entry_points={
        "console_scripts": [
            "detree=d2c2_cli:main",  # Creates `detree` command
        ],
    },
    include_package_data=True,
    install_requires=[],  # No external dependencies
)
