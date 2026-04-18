use clap::Parser;
use needletail::parse_fastx_file;
use anyhow::{Context, Result};
use std::fs::File;
use std::io::{BufWriter, Write};
use std::time::Instant;

/// Ultra-fast tool for filtering viral sequences in FASTA format
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Path to the input FASTA file (supports .gz compression)
    #[arg(short, long)]
    input: String,

    /// Path to the output FASTA file
    #[arg(short, long)]
    output: String,

    /// Minimum allowed length (bp)
    #[arg(long, default_value_t = 29000)]
    min_len: usize,

    /// Maximum allowed length (bp)
    #[arg(long, default_value_t = 30500)]
    max_len: usize,
}

fn main() -> Result<()> {
    let args = Args::parse();
    let start_time = Instant::now();

    println!("Starting filtering...");
    println!("Input:  {}", args.input);
    println!("Output: {}", args.output);
    println!("Allowed range: {} - {} bp\n", args.min_len, args.max_len);

    let mut reader = parse_fastx_file(&args.input)
        .with_context(|| format!("Failed to open input file: {}", args.input))?;

    // BufWriter avoids a slow syscall per write; essential for byte-level output
    let out_file = File::create(&args.output)
        .with_context(|| format!("Failed to create output file: {}", args.output))?;
    let mut writer = BufWriter::new(out_file);

    let mut total_seqs = 0;
    let mut kept_seqs = 0;

    while let Some(record) = reader.next() {
        let seqrec = record.context("Error reading a sequence from the FASTA file")?;
        total_seqs += 1;
        
        let seq_len = seqrec.seq().len();

        // Keep only sequences within the valid complete-genome length range
        if seq_len >= args.min_len && seq_len <= args.max_len {
            writer.write_all(b">")?;
            writer.write_all(seqrec.id())?;
            writer.write_all(b"\n")?;
            writer.write_all(&seqrec.seq())?;
            writer.write_all(b"\n")?;
            
            kept_seqs += 1;
        }
    }

    writer.flush()?;

    let duration = start_time.elapsed();

    println!("--- FILTERING REPORT ---");
    println!("Total sequences analyzed: {}", total_seqs);
    println!("Sequences kept:           {}", kept_seqs);
    println!("Sequences discarded:      {}", total_seqs - kept_seqs);
    println!("Execution time:           {:.2?}", duration);

    Ok(())
}