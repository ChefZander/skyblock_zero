#!/usr/bin/env python3
"""Generate commit log history for files or directories in a git repository."""

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

import argparse
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, Optional, List

LogMode = Literal["log", "authors"]

@dataclass
class Config:
    """Configuration for git log execution and path processing."""
    dirlevel: bool = False
    authors_only: bool = False

    mode: LogMode = "log"
    follow: bool = False
    git_args: List[str] | None = None

    def __post_init__(self):
        if self.git_args is None:
            self.git_args = []


@dataclass
class PathInfo:
    """Information about a path to process."""
    path: Path
    rel_path: Path
    is_dir: bool
    path_label: str
    follow: bool


class GitRepository:
    """Wrapper for git repository operations."""

    def __init__(self):
        self.repo_root = self.find_root()

    @staticmethod
    def find_root() -> Path:
        """Find the git repository root."""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                cwd=Path.cwd(),
                capture_output=True,
                text=True,
                check=True
            )
            return Path(result.stdout.strip())
        except subprocess.CalledProcessError:
            print("Error: Not in a git repository")
            sys.exit(1)

    def run_git_command(self, args: list[str]) -> subprocess.CompletedProcess:
        """Run a git command in the repository root."""
        return subprocess.run(
            ["git", *args],
            cwd=self.repo_root,
            capture_output=True,
            text=True,
            check=True
        )

    def get_git_log(self, path: Path, config: Config) -> Optional[str]:
        """Get git log or authors for a path."""
        try:
            cmd_args = ["log"]

            if config.follow:
                cmd_args.append("--follow")

            if config.mode == "log":
                cmd_args.append("--pretty=format:%h (%as) %s -- %an <%ae>")
            else: # authors
                cmd_args.append("--pretty=format:%an <%ae>")

            if config.git_args:
                cmd_args.extend(config.git_args)

            cmd_args.extend(["--", str(path)])

            result = self.run_git_command(cmd_args)
            output = result.stdout.strip()

            if not output:
                return None

            if config.mode == "authors":
                authors = {line for line in output.split('\n') if line}
                return '\n'.join(sorted(authors)) if authors else None

            return output

        except subprocess.CalledProcessError as e:
            print(f"Error getting git log for {path}: {e}")
            return None


class OutputWriter:
    """Handles writing output to file."""

    def __init__(self, output_file: Path):
        self.output_file = output_file

    def clear(self) -> None:
        """Clear the output file."""
        self.output_file.write_text("", encoding='utf-8')

    def write_section(self, path_label: str, content: str) -> None:
        """Write a section to the output file."""
        with open(self.output_file, 'a', encoding='utf-8') as f:
            f.write(f"{path_label}\n")
            f.write(f"{content}\n\n")


class PathProcessor:
    """Handles processing paths and generating commit logs."""

    def __init__(self, repo: GitRepository, writer: OutputWriter, config: Config):
        self.repo = repo
        self.writer = writer
        self.config = config

    def make_path_info(self, path: Path) -> PathInfo:
        """Makes PathInfo for a given path."""
        is_dir = path.is_dir()
        rel_path: Path
        try:
            rel_path = path.relative_to(self.repo.repo_root)
        except ValueError:
            rel_path = path

        if is_dir:
            path_label = f"{rel_path}/"
            follow = False
        else:
            path_label = str(rel_path)
            follow = True

        path_label = path_label.replace("\\", "/")

        return PathInfo(
            path=path,
            rel_path=rel_path,
            is_dir=is_dir,
            path_label=path_label,
            follow=follow
        )

    def process_path(self, path_info: PathInfo) -> None:
        """Process a single file or directory."""
        mode: LogMode = "authors" if self.config.authors_only else "log"

        # Update mode and follow based on current path.
        git_config = Config(
            mode=mode,
            follow=path_info.follow,
            git_args=self.config.git_args,
            dirlevel=self.config.dirlevel,
            authors_only=self.config.authors_only
        )

        # Get content based on directory level setting
        if path_info.is_dir and self.config.dirlevel:
            content = self.repo.get_git_log(path_info.path, git_config)
        elif path_info.is_dir and not self.config.dirlevel:
            # Recursively process contents for directories
            for item in sorted(path_info.path.rglob('*')):
                if item.is_file():
                    item_info = self.make_path_info(item)
                    self.process_path(item_info)
                elif item.is_dir() and item != path_info.path:
                    item_info = self.make_path_info(item)
                    self.process_path(item_info)
            return
        else: # file
            content = self.repo.get_git_log(path_info.path, git_config)

        if content:
            self.writer.write_section(path_info.path_label, content)

    def process_paths(self, input_paths: List[Path]) -> None:
        """Process multiple input paths."""
        for input_path_str in input_paths:
            input_path = Path(input_path_str).resolve()

            if not input_path.exists():
                print(f"Error: Path {input_path} does not exist. Skipping...")
                continue

            path_info = self.make_path_info(input_path)
            self.process_path(path_info)


def main():
    parser = argparse.ArgumentParser(
        description='Generate commit log history for files or directories'
    )
    parser.add_argument(
        'input_paths',
        nargs='+',
        help='Input file(s) or directory(ies)'
    )
    parser.add_argument(
        '-o', '--output',
        default='\x00',
        help='Output file path (default: commit_log_output.txt in script directory)'
    )
    parser.add_argument(
        '-d', '--directory-level',
        action='store_true',
        help='Run git log on directories themselves instead of traversing inside them'
    )
    parser.add_argument(
        '-a', '--authors-only',
        action='store_true',
        help='Output only unique authors instead of full commit history'
    )
    parser.add_argument(
        'git_args',
        nargs='*',
        help='Additional arguments to pass to git log (after --)'
    )

    args = parser.parse_args()

    repo = GitRepository()

    output_file = Path(args.output)
    if args.output == "\x00":
        script_dir = Path(__file__).parent
        output_file = script_dir / "commit_log_output.txt"

    writer = OutputWriter(output_file)

    # Filter out empty strings.
    git_args = [arg for arg in args.git_args if arg.strip()]

    config = Config(
        dirlevel=args.directory_level,
        authors_only=args.authors_only,
        git_args=git_args
    )

    processor = PathProcessor(repo, writer, config)
    writer.clear()
    processor.process_paths(args.input_paths)

    print(f"Commit logs written to {output_file}")


if __name__ == "__main__":
    main()