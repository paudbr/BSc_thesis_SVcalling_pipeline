#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_directory>"
    exit 1
fi

# Input directory
input_dir="$1"

# Verify that the input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Directory $input_dir does not exist."
    exit 1
fi

# Input directory
input_dir="$1"

/mnt/tblab/paula/scripts_pipe/procesado/procesado_inicial.sh "$input_dir"

echo "Files separated into PASS and non-PASS"

manta_bed_dir="$input_dir/Manta/Manta_PASS"

python3 /mnt/tblab/paula/scripts_pipe/procesado/separar_portiposM.py -i "$manta_bed_dir"

echo "Manta files separated by SV type"

/mnt/tblab/paula/scripts_pipe/procesado/vcf2bed.sh "$input_dir"

echo "Files successfully converted to .bed format"

delly_bed_dir="$input_dir/delly/delly_PASS"

python3 /mnt/tblab/paula/scripts_pipe/procesado/delly_processing.py -p "$delly_bed_dir"

manta_bed_dir2="$input_dir/Manta/Manta_PASS/"
python3 /mnt/tblab/paula/scripts_pipe/procesado/separar_BND_Manta.py -p "$manta_bed_dir2"

python3 /mnt/tblab/paula/scripts_pipe/procesado/pre_processing_Manta2.py -p "$manta_bed_dir"

gridss_bed_dir="$input_dir/GRIDSS/GRIDSS_PASS/"

vcf_file=$(find "$gridss_bed_dir" -type f -name "*.vcf")
original_bed_file=$(find "$gridss_bed_dir" -type f -name "*.bed")

sed -i '1i##fileformat=VCFv4.2' "$vcf_file"

Rscript /mnt/tblab/paula/scripts_pipe/procesado/script_GridssVariantAnnotation.R "$vcf_file"

new_bed_file=$(find "$gridss_bed_dir" -type f -name "*_portipos.bed")

python3 /mnt/tblab/paula/scripts_pipe/procesado/pre_procesado_GRIDSS.py -o "$original_bed_file" -n "$new_bed_file"

python3 /mnt/tblab/paula/scripts_pipe/procesado/separar_portiposG.py -i "$original_bed_file" -o "$gridss_bed_dir"


/mnt/tblab/paula/scripts_pipe/merge/merge.sh "$input_dir"
