#!/usr/bin/env bash
set -euo pipefail

echo "Restaurando entorno de dependencias..."
uv sync

echo "Asegurando permisos de los binarios..."
chmod +x bin/sars_filter bin/iqtree3 bin/datasets

echo "Lanzando el pipeline de Snakemake..."
uv run snakemake -c 16 --rerun-incomplete
