#!/usr/bin/env python3
"""Optimizes audio files involved between commits using FFmpeg."""

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
import json
from pathlib import Path

# Thresholds for audio file candidates to optimize
MIN_BITRATE = 128000  # 128 kbps
MIN_SAMPLERATE = 44100 # 44.1 kHz

# Audio files to keep unoptimized
KEEP = [
    'digistuff_*.ogg'
]

def get_audio_paths(commit_range: str):
    """Get list of audio files changed in the given commit range or single commit"""
    try:
        audio_paths = set[Path]()
        if '..' in commit_range:
            result = subprocess.run(
                ['git', 'diff', '--name-only', '--diff-filter=d', commit_range, '--', '*.ogg'],
                capture_output=True,
                text=True,
                check=True
            )
            audio_paths.update([Path(p) for p in result.stdout.strip().split('\n')])
            result = subprocess.run(
                ['git', 'show', '--name-only', '--format=', commit_range[:commit_range.find('..')], '--', '*.ogg'],
                capture_output=True,
                text=True,
                check=True
            )
            audio_paths.update([Path(p) for p in result.stdout.strip().split('\n')])
        else:
            result = subprocess.run(
                ['git', 'show', '--name-only', '--format=', commit_range, '--', '*.ogg'],
                capture_output=True,
                text=True,
                check=True
            )
            audio_paths.update([Path(p) for p in result.stdout.strip().split('\n')])
        return list(audio_paths)
    except subprocess.CalledProcessError as e:
        print(f"Error getting audio files: {e}")
        sys.exit(1)

def get_audio_info(file_path: Path):
    """Check bitrate and sample rate using ffprobe."""
    try:
        result = subprocess.run(
            ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_streams', '-show_format', str(file_path)],
            capture_output=True,
            text=True,
            check=True)
        data = json.loads(result.stdout)

        # Get stream data (usually index 0 for audio files)
        stream = next((s for s in data['streams'] if s['codec_type'] == 'audio'), None)
        if not stream:
            return None, None

        sample_rate = int(stream.get('sample_rate', 0))
        # Bitrate can be in format or stream depending on container
        bitrate = int(stream.get('bit_rate') or data['format'].get('bit_rate') or 0)

        return sample_rate, bitrate
    except (subprocess.CalledProcessError, ValueError, KeyError):
        return None, None

def process_audio(file_path: Path):
    """Downsample audio if it meets the optimization threshold."""
    sample_rate, bitrate = get_audio_info(file_path)

    if sample_rate is None or bitrate is None:
        print(f"Skipping {file_path}: Could not probe metadata.")
        return

    if sample_rate < MIN_SAMPLERATE or bitrate < MIN_BITRATE:
        print(f"Skipping {file_path}: Already below optimization thresholds.")
        return

    print(f"Processing {file_path} ({sample_rate}Hz, {bitrate//1000}kbps)...")

    # Temporary output to avoid file corruption during overwrite
    temp_file = file_path.with_suffix('.tmp.ogg')
    try:
        subprocess.run([
            'ffmpeg', '-y', '-i', str(file_path),
            '-aq', '1', # audio quality 1
            # sample rate 32KHz instead of 22KHz so probably nobody can hear it
            '-ar', '32000',
            str(temp_file)
        ], check=True, capture_output=True)

        temp_file.replace(file_path.with_suffix('.ogg'))
        if file_path.suffix.lower() != '.ogg':
            file_path.unlink() # Delete old non-ogg file
    except subprocess.CalledProcessError as e:
        print(f"FFmpeg error on {file_path}: {e.stderr.decode()}")
        if temp_file.exists():
            temp_file.unlink()

def main():
    parser = argparse.ArgumentParser(description='Optimize audio files between git commit ranges down to ~22kHz, FFmpeg quality 1')
    parser.add_argument('commit_ranges', nargs='+', help='Git commit ranges (e.g., HEAD~5..HEAD or HEAD)')
    args = parser.parse_args()

    audio_paths = set[Path]()
    for commit_range in args.commit_ranges:
        audio_paths.update(get_audio_paths(commit_range))

    if not audio_paths:
        print("No audio files found in the specified range.")
        return

    for p in audio_paths:
        if p.exists() and all(not p.match(keep) for keep in KEEP):
            process_audio(p)

if __name__ == "__main__":
    main()