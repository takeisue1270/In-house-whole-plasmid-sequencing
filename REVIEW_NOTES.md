# Pre-publication review notes

Review date: 2026-08-14

## Publication status

**Documentation and code packaging: ready for review. The miniaturized barcoding, cleanup bypass, RA/ADB attachment, and PromethION final-library composition are explicitly marked in-house deviations from the controlled ONT sources.**

## Controlled ONT sources

- Plasmid library preparation and MinION/GridION loading: `PRB_9188_v114_revK_07Apr2026`
- Generic PromethION priming, port handling, and 200 µL Kit 14 loading volume: `PFC_9097_v1_revN_29Jan2025`
- Flow Cell Wash Kit: `WFC_9120_v1_revS_25Jul2025`

The live ONT page remains authoritative. A release should be rechecked whenever a source revision changes.

## Wet-lab corrections made during review

1. Retained the in-house miniaturized barcoding scale at the author's request: 2.0 µL purified plasmid DNA plus 0.2 µL Rapid Barcode per sample. The official 9 µL DNA plus 1 µL barcode reaction remains identified as the manufacturer workflow.
2. Replaced the official pooled-library AMPure XP cleanup with a clearly labeled in-house direct-pool branch at the author's request. The omission is disclosed in README.md and PROTOCOL.md and is not represented as ONT-equivalent.
3. Reinstated the in-house 0.3 µL RA + 2.7 µL ADB adapter-attachment mixture at the author's request and labeled it as non-ONT-validated.
4. Added the current MinION/GridION BSA-containing priming branch.
5. Added an experimental in-house PromethION branch using 100 µL SB + 64 µL LIB + 36 µL prepared library. The generic ONT PromethION guide supports the 200 µL Kit 14 total volume but not this SQK-RBK114 plasmid component ratio.
6. Replaced the source SOP's obsolete basecalling selection with the HAC model specified by the controlled ONT plasmid revision.
7. Replaced the local read-count stopping heuristic with the controlled 12-hour run setting plus study-specific monitoring.
8. Corrected wash reagent naming to DIL and documented the current two-stage 200 µL + 200 µL wash delivery.

## AMPure XP cleanup-bypass publication note

The controlled ONT plasmid protocol requires an equal-volume AXP cleanup after pooling. This repository's rapid branch instead transfers 33 µL of the thoroughly mixed direct pool to the in-house RA/ADB attachment step. This reduces handling time by removing bead incubation, magnetic separation, ethanol washes, elution, and post-cleanup quantification, but it may change library purity, recovery, barcode balance, adapter attachment, sequencing yield, and run-to-run reproducibility.

Before routine use, validate the bypass against the complete ONT workflow with representative plasmids and predefined acceptance criteria. Record use of the deviation for each run. If performance is inadequate, use the complete current ONT cleanup rather than altering unvalidated reagent ratios.

## Miniaturized barcoding publication note

The controlled ONT plasmid protocol specifies approximately 50 ng plasmid DNA in 9 µL plus 1 µL Rapid Barcode per sample. The in-house branch uses 2.0 µL purified plasmid DNA plus 0.2 µL Rapid Barcode. Because the DNA concentration is not fixed by volume, users must measure and record concentration and calculated mass, normalize samples to a locally validated input range, and use a calibrated method capable of accurate 0.2 µL dispensing. The miniaturized reaction is not represented as ONT-validated.

## Adapter and PromethION publication note

The in-house adapter attachment uses 33 µL direct pooled library, 0.3 µL RA, and 2.7 µL ADB to produce 36 µL prepared library. This differs from the current ONT plasmid adapter-dilution procedure.

The experimental PromethION loading mix uses 100 µL SB, 64 µL LIB, and the full 36 µL prepared library. The total 200 µL agrees with the generic ONT Kit 14 PromethION guide, but that guide requires compatible component volumes to come from a relevant kit-specific protocol. Because the current SQK-RBK114 plasmid protocol supplies only a MinION/GridION branch, this component ratio is an in-house deviation and requires local comparison against predefined yield, pore-retention, barcode-balance, assembly, and reproducibility criteria.

## Bioinformatics review

- Corrected the usage path from `./NSA/Flye.sh` to `./flye.sh`.
- Standardized final assembly names as `assembly.barcodeNN.fasta`.
- Added validation for barcode order, numeric parameters, genome-size syntax, required programs, input folders, and Flye's `--nano-hq` support.
- Preserved deterministic SeqKit sampling with seed 11.
- Preserved previous work directories and final assemblies under timestamped `.previous.*` names, preventing stale final output names after a failed rerun.
- Return a non-zero status when any requested barcode fails or is skipped.
- The script cannot be end-to-end tested in this workspace because Flye, SeqKit, and representative FASTQ data are not present.

## GitHub packaging review

- The README states scope, dependencies, directory layout, parameters, limitations, provenance, and research-use status.
- Plasmid extraction protocols and extraction-kit recommendations are excluded.
- `.gitignore` blocks common raw sequencing data and generated results.
- Code and documentation have separate licenses.
- Citation metadata identifies the display name as Dant and links it to the GitHub account `takeisue1270`.
- After choosing the final repository name, add `repository-code` and `url` fields to `CITATION.cff` using the final GitHub URL.
