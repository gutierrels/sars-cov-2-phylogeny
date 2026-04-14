mkdir -p data/raw

for lineage in B.1.1.7 B.1.351 P.1 B.1.617.2 B.1.1.529; do
    echo "Descargando linaje $lineage..."
    ./datasets download virus genome taxon SARS-CoV-2 \
        --lineage $lineage \
        --complete-only \
        --filename data/raw/${lineage}.zip
done
