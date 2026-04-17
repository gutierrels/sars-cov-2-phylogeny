# --- Pipeline configuration ---
# Number of threads for MAFFT
THREADS = 16

# --- Main rule ---
# Snakemake checks this rule first to determine the final target.
rule all:
    input:
        "results/alignment/aligned.fasta"

# --- Phase 2: Rust-based filtering ---
rule filter_sequences:
    input:
        raw="data/dataset_poc.fasta"
    output:
        filtered="data/filtered_poc.fasta"
    shell:
        """
        ./filter/target/release/filter --input {input.raw} --output {output.filtered} --min-len 29000 --max-len 30500
        """

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
        """
        # Use --auto so MAFFT picks the best algorithm (FFT-NS-2 or similar)
        # stdout goes to the output file, stderr/info goes to the log
        mafft --auto --thread {threads} {input} > {output} 2> {log}
        """
