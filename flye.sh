#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage:
  bash ./flye.sh <start_barcode> <end_barcode>

Example:
  bash ./flye.sh 1 12

Run the script from a directory containing demultiplexed reads arranged as:
  ./fastq_pass/barcodeNN/*.fastq[.gz]

Results are written to ./flye_results/ by default. Final assemblies are named:
  ./flye_results/assembly.barcodeNN.fasta

Optional environment variables:
  INPUT_DIR=PATH      Input directory (default: ./fastq_pass)
  OUTPUT_PATH=PATH    Results directory (default: ./flye_results)
  WORK_ROOT=PATH      Flye work directory (default: OUTPUT_PATH/work)
  THREADS=14          Flye threads
  MIN_LENGTH=200      Minimum read length
  SAMPLE_SIZE=1000    Target number of sampled reads
  GENOME_SIZE=7k      Estimated plasmid size
  ASM_COVERAGE=100    Flye initial assembly coverage
  RANDOM_SEED=11      SeqKit sampling seed
  MIN_OVERLAP=4000    Optional manual Flye minimum overlap
EOF
}

die() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

warn() {
    printf '[WARN] %s\n' "$*" >&2
}

require_positive_integer() {
    local name=$1
    local value=$2
    [[ "$value" =~ ^[1-9][0-9]*$ ]] ||
        die "${name} must be a positive integer: ${value}"
}

trap 'printf "[ERROR] Unexpected failure at line %s\n" "$LINENO" >&2' ERR

if (( $# != 2 )); then
    usage >&2
    exit 1
fi

[[ "$1" =~ ^[0-9]+$ && "$2" =~ ^[0-9]+$ ]] ||
    die "Barcode numbers must be non-negative integers."

START=$((10#$1))
END=$((10#$2))
readonly START END

(( START <= END )) ||
    die "start_barcode must be less than or equal to end_barcode."

# Relative paths are resolved from the directory in which the script is run.
readonly CURRENT_DIR="$PWD"
readonly INPUT_DIR="${INPUT_DIR:-${CURRENT_DIR}/fastq_pass}"
readonly OUTPUT_PATH="${OUTPUT_PATH:-${CURRENT_DIR}/flye_results}"
readonly WORK_ROOT="${WORK_ROOT:-${OUTPUT_PATH}/work}"
readonly THREADS="${THREADS:-14}"
readonly MIN_LENGTH="${MIN_LENGTH:-200}"
readonly SAMPLE_SIZE="${SAMPLE_SIZE:-1000}"
readonly GENOME_SIZE="${GENOME_SIZE:-7k}"
readonly ASM_COVERAGE="${ASM_COVERAGE:-100}"
readonly RANDOM_SEED="${RANDOM_SEED:-11}"
readonly MIN_OVERLAP="${MIN_OVERLAP:-}"

require_positive_integer "THREADS" "$THREADS"
require_positive_integer "MIN_LENGTH" "$MIN_LENGTH"
require_positive_integer "SAMPLE_SIZE" "$SAMPLE_SIZE"
require_positive_integer "ASM_COVERAGE" "$ASM_COVERAGE"
[[ "$GENOME_SIZE" =~ ^[1-9][0-9]*([kKmMgG])?$ ]] ||
    die "GENOME_SIZE must be a positive integer with an optional k, m, or g suffix: ${GENOME_SIZE}"
[[ "$RANDOM_SEED" =~ ^[0-9]+$ ]] ||
    die "RANDOM_SEED must be a non-negative integer: ${RANDOM_SEED}"
if [[ -n "$MIN_OVERLAP" ]]; then
    require_positive_integer "MIN_OVERLAP" "$MIN_OVERLAP"
fi

for required_command in seqkit flye; do
    command -v "$required_command" >/dev/null 2>&1 ||
        die "Required command not found: ${required_command}"
done

flye_help=$(flye --help 2>&1 || true)
[[ "$flye_help" == *"--nano-hq"* ]] ||
    die "Installed Flye does not support --nano-hq. Flye 2.9 or later is required."

[[ -d "$INPUT_DIR" ]] ||
    die "Input directory not found: ${INPUT_DIR}"

mkdir -p -- "$OUTPUT_PATH" "$WORK_ROOT"
shopt -s nullglob

success_count=0
failure_count=0

printf '[INFO] Input directory: %s\n' "$INPUT_DIR"
printf '[INFO] Output directory: %s\n' "$OUTPUT_PATH"

for (( barcode_number = START; barcode_number <= END; barcode_number++ )); do
    printf -v barcode 'barcode%02d' "$barcode_number"
    barcode_dir="${INPUT_DIR}/${barcode}"
    final_assembly="${OUTPUT_PATH}/assembly.${barcode}.fasta"

    printf '[INFO] Processing %s\n' "$barcode"

    if [[ -e "$final_assembly" ]]; then
        previous_assembly="${final_assembly}.previous.$(date +%Y%m%d-%H%M%S).$$"
        mv -- "$final_assembly" "$previous_assembly"
        printf '[INFO] Previous final assembly saved as %s\n' "$previous_assembly"
    fi

    if [[ ! -d "$barcode_dir" ]]; then
        warn "Skipping ${barcode}: directory not found: ${barcode_dir}"
        (( failure_count += 1 ))
        continue
    fi

    fastq_files=(
        "$barcode_dir"/*.fastq
        "$barcode_dir"/*.fastq.gz
        "$barcode_dir"/*.fq
        "$barcode_dir"/*.fq.gz
    )

    if (( ${#fastq_files[@]} == 0 )); then
        warn "Skipping ${barcode}: no FASTQ files found."
        (( failure_count += 1 ))
        continue
    fi

    sampled_fastq="${WORK_ROOT}/${barcode}.sampled.fastq"
    sampled_fastq_tmp="${sampled_fastq}.tmp.$$"
    flye_dir="${WORK_ROOT}/${barcode}"
    if ! seqkit seq -m "$MIN_LENGTH" "${fastq_files[@]}" |
        seqkit sample -n "$SAMPLE_SIZE" -s "$RANDOM_SEED" > "$sampled_fastq_tmp"; then
        rm -f -- "$sampled_fastq_tmp"
        warn "Skipping ${barcode}: SeqKit filtering or sampling failed."
        (( failure_count += 1 ))
        continue
    fi

    if [[ ! -s "$sampled_fastq_tmp" ]]; then
        rm -f -- "$sampled_fastq_tmp"
        warn "Skipping ${barcode}: no reads remain after filtering."
        (( failure_count += 1 ))
        continue
    fi

    mv -f -- "$sampled_fastq_tmp" "$sampled_fastq"

    if [[ -e "$flye_dir" ]]; then
        previous_dir="${flye_dir}.previous.$(date +%Y%m%d-%H%M%S).$$"
        mv -- "$flye_dir" "$previous_dir"
        printf '[INFO] Previous Flye work saved as %s\n' "$previous_dir"
    fi

    flye_args=(
        --nano-hq "$sampled_fastq"
        --out-dir "$flye_dir"
        --genome-size "$GENOME_SIZE"
        --threads "$THREADS"
        --asm-coverage "$ASM_COVERAGE"
    )

    if [[ -n "$MIN_OVERLAP" ]]; then
        flye_args+=(--min-overlap "$MIN_OVERLAP")
    fi

    if ! flye "${flye_args[@]}"; then
        warn "Skipping ${barcode}: Flye failed."
        (( failure_count += 1 ))
        continue
    fi

    if [[ ! -s "${flye_dir}/assembly.fasta" ]]; then
        warn "Skipping ${barcode}: Flye did not create assembly.fasta."
        (( failure_count += 1 ))
        continue
    fi

    cp -f -- "${flye_dir}/assembly.fasta" "$final_assembly"
    printf '[INFO] Saved %s\n' "$final_assembly"
    (( success_count += 1 ))
done

printf '[INFO] Completed: %d succeeded, %d failed or skipped.\n' \
    "$success_count" "$failure_count"

(( success_count > 0 )) ||
    die "No assemblies were produced."

if (( failure_count > 0 )); then
    exit 1
fi
