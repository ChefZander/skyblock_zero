#!/usr/bin/env python3
"""Optimizes PNGs involved between commits."""

# Copyright (C) 2026 corpserot. MIT license.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import subprocess
import sys
import argparse
from pathlib import Path

def get_images_paths(commit_range: str):
    """Get list of PNG files changed in the given commit range or single commit"""
    try:
        if '..' in commit_range:
            result = subprocess.run(
                ['git', 'rev-list', '--reverse', commit_range],
                capture_output=True,
                text=True,
                check=True
            )
            commits = result.stdout.strip().split('\n')
        else:
            commits = [commit_range]

        image_paths = set[Path]()
        for commit in commits:
            # Get files changed in each commit
            result = subprocess.run(
                ['git', 'show', '--name-only', '--pretty=format:', commit, '--', '*.png'],
                capture_output=True,
                text=True,
                check=True
            )
            image_paths.update([Path(p) for p in result.stdout.strip().split('\n') if p.endswith('.png')])

        return list(image_paths)
    except subprocess.CalledProcessError as e:
        print(f"Error getting PNG files: {e}")
        sys.exit(1)

def optimize_png(file_path):
    """Optimize a PNG file using optipng"""
    try:
        subprocess.run(
            ['optipng', '-o7', '-zm1-9', '-nc', '-strip', 'all', '-clobber', file_path],
            check=True
        )
        print(f"Optimized: {file_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error optimizing {file_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description='Optimize PNG files between git commit ranges')
    parser.add_argument('commit_ranges', nargs='+', help='Git commit ranges or single commits (e.g., aaaaaaaa~1..bbbbbbbb or cccccccc)')
    args = parser.parse_args()

    commit_ranges = args.commit_ranges

    image_paths = set[Path]()
    for commit_range in commit_ranges:
        image_paths.update(get_images_paths(commit_range))
    image_paths = list(image_paths)
    if not image_paths:
        print("No PNG files found in the specified commit range.")
        return

    for p in image_paths:
        if p.exists():
            optimize_png(p)

if __name__ == "__main__":
    main()