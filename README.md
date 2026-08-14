# Whole Plasmid Sequencing

An end-to-end, research-use workflow linking the current Oxford Nanopore Technologies (ONT) plasmid protocol to per-barcode de novo assembly with Flye.

> [!IMPORTANT]
> ONT documentation is the controlling source except for two explicitly marked in-house deviations: a miniaturized barcoding reaction using 2.0 µL plasmid DNA plus 0.2 µL Rapid Barcode per sample, and omission of the pooled-library AMPure XP cleanup. Check the live ONT protocol before every run and use the complete manufacturer workflow when strict ONT compliance, validated input limits, or maximum library recovery is required.

## Scope

The workflow begins with **purified plasmid DNA**. DNA extraction procedures, kit-specific instructions, and extraction-kit recommendations are intentionally excluded because laboratories may use different validated methods.

The repository covers:

1. in-house miniaturized barcoding and direct adapter attachment using a cleanup bypass;
2. flow-cell priming, loading, run setup, and optional wash/storage notes;
3. demultiplexed FASTQ input preparation; and
4. independent Flye assembly for each barcode.

The supported wet-lab device branch in this release is **MinION/GridION with FLO-MIN114**. PromethION is intentionally excluded until a current ONT kit-specific plasmid protocol explicitly defines SQK-RBK114 compatibility and the final loading composition for FLO-PRO114M.

The English wet-lab document is available as [PROTOCOL.md](PROTOCOL.md) and [Whole_Plasmid_Sequencing_Protocol.docx](Whole_Plasmid_Sequencing_Protocol.docx). Publication checks and unresolved deviations from current ONT guidance are listed in [REVIEW_NOTES.md](REVIEW_NOTES.md).

## A rapid alternative to serial Sanger sequencing

For routine plasmid verification, this workflow can complement or replace a series of Sanger reactions when whole-plasmid coverage, multiplexing, and rapid in-house feedback are useful. Starting with purified plasmid DNA, barcoded ONT sequencing and per-barcode Flye assembly provide a practical route from multiple samples to assembled plasmid sequences without designing a locus-specific sequencing primer for every region.

| Consideration              | Sanger sequencing                                     | This whole-plasmid workflow                                                                          |
| -------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Sequence examined          | A primer-defined region per reaction                  | An assembled sequence spanning the plasmid                                                           |
| Primer planning            | May require multiple primers or primer walking        | Does not require locus-specific sequencing primers                                                   |
| Multiple constructs        | Additional reactions for each sample and region       | Barcodes allow multiple plasmids to be pooled in one run                                             |
| Changes outside the insert | May be missed if they lie outside the targeted region | Insert, backbone, replication origin, selectable marker, and repeat regions can be reviewed together |
| Turnaround                 | Often depends on an external service schedule         | Can support same-day in-house review when local sequencing and analysis capacity are available       |

This approach is particularly useful when several constructs require full-length verification, when repeats or unexpected backbone changes matter, or when an experimental decision is needed quickly. Sanger sequencing remains a simple and effective choice for targeted confirmation of a short, known region in one or a few samples.

To reduce preparation time and reagent use, each in-house barcoding reaction contains **2.0 µL purified plasmid DNA and 0.2 µL Rapid Barcode**. The complete 2.2 µL reactions are pooled, and the rapid branch proceeds from a well-mixed aliquot directly to adapter attachment, omitting the post-barcoding AMPure XP bead incubation, magnetic separation, ethanol washes, and elution. These shortcuts are laboratory-specific deviations rather than ONT-endorsed equivalents; use calibrated low-volume pipetting, record DNA concentration and input mass, and apply locally defined acceptance criteria before routine adoption.

The table is a use-case comparison, not a guaranteed performance or cost benchmark. Actual turnaround, yield, accuracy, and cost per sample depend on batch size, DNA quality, flow-cell condition, run settings, basecalling, analysis resources, and the acceptance criteria used by each laboratory.

## Repository contents

| File                                       | Purpose                                                                    |
| ------------------------------------------ | -------------------------------------------------------------------------- |
| `flye.sh`                                | Filters, reproducibly downsamples, and assembles reads for a barcode range |
| `PROTOCOL.md`                            | English wet-lab protocol beginning with purified plasmid DNA               |
| `Whole_Plasmid_Sequencing_Protocol.docx` | Formatted Word version of the wet-lab protocol                             |
| `REVIEW_NOTES.md`                        | Pre-publication technical review and items requiring local confirmation    |
| `tools/build_protocol_docx.py`           | Rebuilds the Word document from`PROTOCOL.md`                             |
| `CITATION.cff`                           | GitHub citation metadata                                                   |
| `LICENSE` / `LICENSE-DOCS`             | Licenses for code and documentation                                        |

## Requirements

- Bash 4 or later
- [SeqKit](https://bioinf.shenwei.me/seqkit/)
- [Flye](https://github.com/mikolmogorov/Flye) 2.9 or later
- Demultiplexed Oxford Nanopore reads in FASTQ or compressed FASTQ format

## Expected input layout

Run `flye.sh` from a working directory containing:

```text
fastq_pass/
├── barcode01/
│   ├── reads_001.fastq.gz
│   └── reads_002.fastq.gz
├── barcode02/
│   └── reads.fastq.gz
└── barcodeNN/
    └── ...
```

## Quick start

```bash
chmod +x flye.sh
bash ./flye.sh 1 12
```

The default output is:

```text
flye_results/
├── assembly.barcode01.fasta
├── assembly.barcode02.fasta
└── work/
    ├── barcode01.sampled.fastq
    ├── barcode01/
    └── ...
```

## Configuration

Set environment variables before the command to change defaults:

```bash
THREADS=24 GENOME_SIZE=12k SAMPLE_SIZE=2000 bash ./flye.sh 1 24
```

| Variable         |              Default | Meaning                                    |
| ---------------- | -------------------: | ------------------------------------------ |
| `INPUT_DIR`    |     `./fastq_pass` | Directory containing`barcodeNN` folders  |
| `OUTPUT_PATH`  |   `./flye_results` | Results directory                          |
| `WORK_ROOT`    | `OUTPUT_PATH/work` | Intermediate Flye directory                |
| `THREADS`      |               `14` | Flye threads                               |
| `MIN_LENGTH`   |              `200` | Minimum read length retained by SeqKit     |
| `SAMPLE_SIZE`  |             `1000` | Target number of reads sampled per barcode |
| `GENOME_SIZE`  |               `7k` | Estimated plasmid size passed to Flye      |
| `ASM_COVERAGE` |              `100` | Flye initial assembly coverage             |
| `RANDOM_SEED`  |               `11` | SeqKit random seed                         |
| `MIN_OVERLAP`  |                unset | Optional Flye minimum overlap              |

## Interpretation and quality control

- Choose `GENOME_SIZE`, `SAMPLE_SIZE`, and `MIN_OVERLAP` for the expected plasmid and read distribution; the defaults are not universal.
- A Flye assembly is not, by itself, proof of sequence identity, structural correctness, or circularity. Inspect the Flye work directory, assembly graph, read support, expected length, and known reference features where applicable.
- Barcode cross-talk, chimeric reads, low input quality, and uneven read counts can affect results.
- The fixed seed makes sampling repeatable only when the input record order and SeqKit version are also unchanged.
- The script returns a non-zero status if any requested barcode fails or is skipped, even when other barcodes succeed.
- An existing final assembly is moved to a timestamped `.previous.*` file before that barcode is processed, preventing a failed rerun from leaving a stale file under the current output name.
- Do not commit raw FASTQ, POD5, BAM, or sample-identifying data. The included `.gitignore` excludes common large sequencing outputs.

## Protocol provenance

The wet-lab section began as an English edition of an internal protocol dated 2025-02-11. The miniaturized **2.0 µL DNA + 0.2 µL barcode** reaction and post-barcoding AMPure XP cleanup bypass are intentionally retained as clearly labeled in-house rapid deviations; all other listed reagent quantities remain tied to the controlled ONT sources. Because the controlled ONT plasmid protocol explicitly documents the MinION/GridION branch but not a complete SQK-RBK114 PromethION branch, PromethION instructions were removed. Plasmid extraction content remains excluded.

Before bench use, compare this repository with the current [ONT plasmid sequencing protocol for SQK-RBK114](https://nanoporetech.com/resources/technique/assembly/document/rapid-sequencing-v14-plasmid-sequencing-sqk-rbk114-96) and the applicable device and flow-cell documentation.

## Citation

Use the repository's **Cite this repository** function or the metadata in [CITATION.cff](CITATION.cff).

## Rebuilding the Word document

The checked-in DOCX can be regenerated from `PROTOCOL.md` with Python 3 and `python-docx`:

```bash
python -m pip install python-docx
python tools/build_protocol_docx.py
```

After rebuilding, visually inspect every page in Word or LibreOffice and remove personal document metadata before release.

## License

Source code is released under the [MIT License](LICENSE). Documentation is released under [CC BY 4.0](LICENSE-DOCS). ONT product names and trademarks belong to their respective owner; this project is not affiliated with or endorsed by ONT.

## Research-use disclaimer

For research use only. This workflow is not intended for diagnostic, therapeutic, or clinical decision-making.
