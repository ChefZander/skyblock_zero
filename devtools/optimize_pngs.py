#!/usr/bin/env python3
"""Optimizes PNGs involved between commits."""

# Copyright (C) 2026 corpserot. 0BSD.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

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