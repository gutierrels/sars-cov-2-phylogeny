# --- Configuración del pipeline ---
THREADS = 16

# --- Regla principal (El objetivo final) ---
rule all:
    input:
        "results/tree/sars_cov_2.treefile",
        "results/qc/variability_plot.pdf"

# --- Fase 2: Filtrado en Rust ---
rule filter_sequences:
    input:
        raw="data/dataset_poc.fasta"
    output:
        filtered="data/filtered_poc.fasta"
    shell:
        "./bin/sars_filter --input {input.raw} --output {output.filtered} --min-len 29000 --max-len 30500"

# --- Fase 3: Alineamiento con MAFFT ---
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

# --- Fase 4: Limpieza y Gráfica (Python + NumPy) ---
rule quality_control:
    input:
        "results/alignment/aligned.fasta"
    output:
        clean_aln="results/alignment/aligned_filtered.fasta",
        plot="results/qc/variability_plot.pdf"
    shell:
        "uv run scripts/qc_alignment.py --input {input} --out-fasta {output.clean_aln} --out-plot {output.plot}"

# --- Fase 5: Inferencia Filogenética con IQ-TREE ---
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