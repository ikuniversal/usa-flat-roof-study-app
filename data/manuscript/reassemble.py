"""Reassemble the 3 JSON chunks into extracted-content.json.

Run this AFTER you've written all three chunk files to data/manuscript/.
"""
import json
from pathlib import Path

manuscript_dir = Path('data/manuscript')

chunks = []
for i in range(1, 4):
    path = manuscript_dir / f'chunk_{i}_of_3.json'
    with open(path) as f:
        chunks.append(json.load(f))

# Sort by chunk_number to be safe
chunks.sort(key=lambda c: c['chunk_number'])

# Recover metadata from chunk 1
metadata = chunks[0]['metadata']

# Concatenate rows in order
all_rows = []
for c in chunks:
    all_rows.extend(c['rows'])

assert len(all_rows) == metadata['total_rows'], \
    f"Row count mismatch: got {len(all_rows)}, expected {metadata['total_rows']}"

output = {'metadata': metadata, 'rows': all_rows}
out_path = manuscript_dir / 'extracted-content.json'
with open(out_path, 'w') as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print(f"Wrote {out_path}")
print(f"  Total rows: {len(all_rows)}")
print(f"  Sources: {list(metadata['sources'].keys())}")
print(f"  Instructor-only rows: {metadata['instructor_only_count']}")
