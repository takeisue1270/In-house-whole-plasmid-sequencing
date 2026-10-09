# In-house deviations from the ONT protocol

This workflow departs from the controlled Oxford Nanopore Technologies (ONT)
plasmid protocol in four places. Each one is listed here with what it changes,
what it may cost, and what you have to establish locally before you rely on it.
None of them is an ONT-validated substitute, and none should be described in a
publication as an ONT kit-specific procedure.

## The ONT sources this workflow was written against

| Source | Revision used |
| --- | --- |
| Plasmid library preparation and MinION/GridION loading (SQK-RBK114) | `PRB_9188_v114_revK_07Apr2026` |
| Generic PromethION priming, port handling, 200 µL Kit 14 loading volume | `PFC_9097_v1_revN_29Jan2025` |
| Flow Cell Wash Kit | `WFC_9120_v1_revS_25Jul2025` |

The live ONT page is authoritative, not this table. Recheck the workflow
whenever a source revision changes, and before every run.

## 1. Miniaturized barcoding

The ONT plasmid protocol specifies approximately 50 ng plasmid DNA in 9 µL plus
1 µL Rapid Barcode per sample. This workflow uses **2.0 µL purified plasmid DNA
plus 0.2 µL Rapid Barcode**, a five-fold reduction in volume.

Because input mass is no longer fixed by the volume, you must measure and
record the concentration and the calculated mass of every sample, normalize to
an input range you have validated locally, and dispense 0.2 µL by a calibrated
method capable of that volume accurately.

## 2. AMPure XP cleanup bypass

The ONT plasmid protocol requires an equal-volume AXP cleanup after pooling.
This workflow instead transfers 33 µL of the thoroughly mixed direct pool
straight to adapter attachment.

Removing the bead incubation, magnetic separation, ethanol washes, elution and
post-cleanup quantification saves substantial handling time. It may also change
library purity, recovery, barcode balance, adapter attachment, sequencing yield
and run-to-run reproducibility.

Validate the bypass against the complete ONT workflow on representative
plasmids, with acceptance criteria defined in advance, and record for each run
that the deviation was used. If performance falls short, return to the complete
current ONT cleanup rather than adjusting unvalidated reagent ratios.

## 3. Adapter attachment ratio

Adapter attachment here combines 33 µL direct pooled library, **0.3 µL RA and
2.7 µL ADB** to produce 36 µL prepared library. This differs from the current
ONT plasmid adapter-dilution procedure and is not validated against it.

## 4. Experimental PromethION loading

The PromethION loading mix combines **100 µL SB, 64 µL LIB and the full 36 µL
prepared library**. The 200 µL total agrees with the generic ONT Kit 14
PromethION guide, but that guide delegates the component composition to the
relevant kit-specific protocol, and the current SQK-RBK114 plasmid protocol
defines only a MinION/GridION branch. The ratio above is therefore an in-house
value with no ONT counterpart to check it against.

Before routine use, compare it locally against predefined yield,
pore-retention, barcode-balance, assembly and reproducibility criteria.

## Settings that follow current ONT guidance

These are not deviations. They are listed because older plasmid protocols
specify something different, and a reader comparing documents will notice:

- The MinION/GridION priming branch is the current BSA-containing one.
- Basecalling uses the HAC model specified by the controlled ONT plasmid revision.
- The run uses the controlled 12-hour setting, with study-specific monitoring.
- The wash reagent is named DIL, delivered in the current two stages of 200 µL.
