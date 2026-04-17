#!/usr/bin/env bash
set -euo pipefail

echo "Restaurando entorno de dependencias..."
uv sync

echo "Asegurando permisos del binario de Rust..."
chmod +x bin/sars_filter

echo "Lanzando el pipeline de Snakemake..."
uv run snakemake -c 16 --rerun-incomplete
