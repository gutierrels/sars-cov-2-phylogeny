import os

# --- Pipeline configuration ---
THREADS = 16

# Fallback logic for input dataset
RAW_DATASET = "data/dataset_poc.fasta"
if not os.path.exists(RAW_DATASET):
    RAW_DATASET = "data/sample/poc_100_genomes.fasta"

# --- Main rule (Final objective) ---
rule all:
    input:
        "results/tree/sars_cov_2.treefile",
        "results/qc/variability_plot.pdf"

# --- Phase 2: Filtering in Rust ---
rule filter_sequences:
    input:
        raw=RAW_DATASET
    output:
        filtered="data/filtered_poc.fasta"
    shell:
        "./bin/sars_filter --input {input.raw} --output {output.filtered} --min-len 29000 --max-len 30500"

# --- Phase 3: Alignment with MAFFT ---
rule align_sequences:
    input:
        "data/filtered_poc.fasta"
    output:
        "results/alignment/aligned.fasta"
    threads: THREADS
    log:
        "results/logs/mafft.log"
    shell:
        "mafft --auto --thread {threads} {input} > {output} 2> {log}"

# --- Phase 4: Cleaning and Plotting (Python + NumPy) ---
rule quality_control:
    input:
        "results/alignment/aligned.fasta"
    output:
        clean_aln="results/alignment/aligned_filtered.fasta",
        plot="results/qc/variability_plot.pdf"
    shell:
        "uv run scripts/qc_alignment.py --input {input} --out-fasta {output.clean_aln} --out-plot {output.plot}"

# --- Phase 5: Phylogenetic Inference with IQ-TREE ---
rule build_tree:
    input:
        "results/alignment/aligned_filtered.fasta"
    output:
        "results/tree/sars_cov_2.treefile"
    threads: THREADS
    log:
        "results/logs/iqtree.log"
    shell:
        "./bin/iqtree3 -s {input} -T {threads} -m TEST -pre results/tree/sars_cov_2 > {log} 2>&1"