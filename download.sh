#!/usr/bin/env bash
set -euo pipefail

# Available lineages (Pango nomenclature):
#   B.1.1.7   - Alpha   (UK)          — First variant of concern
#   B.1.351   - Beta    (South Africa)
#   P.1       - Gamma   (Brazil)       — Alias for B.1.1.28.1 (>3 dots rule)
#   B.1.617.2 - Delta   (India)        — Globally dominant during most of 2021
#   B.1.1.529 - Omicron (South Africa)  — Unprecedented Spike mutations, spawned BA.1, BA.2, etc.
DEFAULT_LINEAGES="B.1.1.7 B.1.351 P.1 B.1.617.2 B.1.1.529"

usage() {
    echo "Usage: $0 [-l \"LINEAGE1 LINEAGE2 ...\"]"
    echo ""
    echo "Options:"
    echo "  -l    Lineages to download (space-separated, in quotes)"
    echo "        Default: $DEFAULT_LINEAGES"
    echo "  -h    Show this help message"
    echo ""
    echo "Available variants:"
    echo "  B.1.1.7   Alpha   (UK)"
    echo "  B.1.351   Beta    (South Africa)"
    echo "  P.1       Gamma   (Brazil)        Alias for B.1.1.28.1"
    echo "  B.1.617.2 Delta   (India)          Dominant worldwide mid-2021"
    echo "  B.1.1.529 Omicron (South Africa)   Unprecedented Spike mutations"
    exit 0
}

LINEAGES="$DEFAULT_LINEAGES"

while getopts ":l:h" opt; do
    case $opt in
        l) LINEAGES="$OPTARG" ;;
        h) usage ;;
        *) echo "Unknown option: -$OPTARG" >&2; usage ;;
    esac
done

mkdir -p data/raw

# Download genomes for each lineage
for lineage in $LINEAGES; do
    echo "Downloading $lineage..."
    ./bin/datasets download virus genome taxon SARS-CoV-2 \
        --lineage $lineage \
        --complete-only \
        --filename data/raw/${lineage}.zip
done

# Extract FASTA from each ZIP

for zip in data/raw/*.zip; do
    lineage=$(basename "$zip" .zip)
    echo "Extracting $lineage..."
    unzip -p "$zip" ncbi_dataset/data/genomic.fna > data/raw/${lineage}.fasta
done

# Discard ZIPs
rm -f data/raw/*.zip

# Merge all into a single master file
cat data/raw/*.fasta > data/dataset_poc.fasta

echo "Download and merge completed!"
