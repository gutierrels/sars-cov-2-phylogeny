# SARS-CoV-2 Phylogenetic Inference Pipeline

High-performance automated pipeline orchestrated with Snakemake. It combines low-level processing in Rust for sequence filtering, vectorized analysis in Python (NumPy/Biopython) for quality control, and Maximum Likelihood inference. The entire execution environment is guaranteed and isolated using uv.

## System Requirements (Dependencies)

> **Important:** This project is exclusively designed for **Linux (x86_64)** environments.

To execute the pipeline, the following dependencies must be installed on your system:

* **uv**: Package manager (pip/venv replacement).
* **mafft**: Multiple Sequence Alignment tool (must be in the system PATH).
* **NCBI Datasets CLI and unzip**: Required only if executing `download.sh`.

> **Note:** To guarantee portability without requiring local compilers, the fast quality control filter (`sars_filter`) and the phylogenetic inference engine (`iqtree3`) are provided as pre-compiled binaries in the `bin/` folder.

## Pipeline Phases

The Snakemake Directed Acyclic Graph (DAG) workflow is divided into:

* **Phase 1 (Bash)**: Download variant sequences (VOCs) from NCBI.
* **Phase 2 (Rust)**: O(n) length-based filtering using the native binary.
* **Phase 3 (MAFFT)**: Parallelized Multiple Sequence Alignment.
* **Phase 4 (Python/NumPy)**: Matrix-based gap cleaning and positional variability histogram generation.
* **Phase 5 (IQ-TREE)**: Phylogenetic tree construction (Maximum Likelihood) with automatic evolutionary model selection.

## Execution Instructions

> **Note on Data:** The repository includes a *Toy Dataset* of 100 genomes from the **Omicron (B.1.1.529)** variant in `data/sample/` for quick testing. Snakemake will automatically use it by default unless the NCBI download script is manually executed.

```bash
# 1. Clone the repository
git clone https://github.com/gutierrels/sars-cov-2-phylogeny.git
cd sars-cov-2-phylogeny

# 2. Synchronize the Python environment using uv.lock
uv sync

# 3. Grant permissions to local binaries
chmod +x bin/sars_filter bin/iqtree3 bin/datasets

# 4. Execute the orchestrator (using 16 threads)
uv run snakemake -c 16
```

## Output Structure (Outputs)

Upon completion, a `results/` folder (ignored by Git) will be generated containing:

* `results/tree/sars_cov_2.treefile`: Tree in Newick format.
* `results/qc/variability_plot.pdf`: Mutation/gap histogram.
* `results/logs/`: Standard and error logs for each rule.

## Expected Results (Proof of Concept - Omicron Variant)
Running the pipeline with the included *Toy Dataset* will automatically generate the following analyses:

![Phylogenetic Tree](doc/assets/arbol_circular.svg)
![Mutation Distribution](doc/assets/histograma.png)
