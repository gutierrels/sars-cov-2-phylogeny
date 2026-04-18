#!/usr/bin/env python3
import argparse
import numpy as np
from Bio import AlignIO, SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import matplotlib.pyplot as plt

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    parser.add_argument("-o", "--out-fasta", required=True)
    parser.add_argument("-p", "--out-plot", required=True)
    parser.add_argument("--max-seq-gaps", type=float, default=0.05)
    parser.add_argument("--max-col-gaps", type=float, default=0.99)
    return parser.parse_args()

def main():
    args = parse_args()
    alignment = AlignIO.read(args.input, "fasta")
    mat = np.array([list(rec.seq) for rec in alignment], dtype='U1')
    
    valid_rows = np.mean(mat == '-', axis=1) <= args.max_seq_gaps
    mat_filtered = mat[valid_rows]
    
    valid_cols = np.mean(mat_filtered == '-', axis=0) <= args.max_col_gaps
    clean_mat = mat_filtered[:, valid_cols]
    
    changes_per_col = []
    for i in range(clean_mat.shape[1]):
        col = clean_mat[:, i]
        col_no_gaps = col[col != '-']
        if len(col_no_gaps) == 0:
            changes_per_col.append(0)
            continue
        _, counts = np.unique(col_no_gaps, return_counts=True)
        changes_per_col.append(len(col_no_gaps) - counts.max())
        
    plt.figure(figsize=(10, 6))
    plt.hist(changes_per_col, bins=50, color='skyblue', edgecolor='black', log=True)
    plt.title('Distribución de Variabilidad SARS-CoV-2')
    plt.savefig(args.out_plot, dpi=300)
    plt.close()

    valid_ids = np.array([rec.id for rec in alignment])[valid_rows]
    clean_records = [SeqRecord(Seq("".join(seq)), id=vid, description="") for seq, vid in zip(clean_mat, valid_ids)]
    SeqIO.write(clean_records, args.out_fasta, "fasta")

if __name__ == "__main__":
    main()
