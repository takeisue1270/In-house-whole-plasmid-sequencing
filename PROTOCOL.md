# Whole Plasmid Sequencing

**ONT-referenced, in-house miniaturized rapid workflow | English edition | For research use only**

**Starting material:** purified plasmid DNA  
**Library kit:** Rapid Barcoding Kit 24 or 96 V14 (SQK-RBK114.24 or SQK-RBK114.96)  
**Primary source:** ONT protocol PRB_9188_v114_revK_07Apr2026  
**English repository edition:** 2026-08-14

> [!IMPORTANT]
> Oxford Nanopore Technologies (ONT) documentation is the controlling source except for two explicitly marked in-house deviations: **the miniaturized 2.0 µL DNA + 0.2 µL barcode reaction in Section 4.2 and the pooled-library AMPure XP cleanup bypass in Section 4.3**. Check the linked ONT pages immediately before use and follow the complete manufacturer workflow whenever strict ONT compliance, validated input limits, or maximum library recovery is required.

## 1. Scope and exclusions

This workflow begins with purified plasmid DNA and covers library preparation, sequencing, demultiplexed FASTQ handling, and per-barcode Flye assembly. It deliberately excludes plasmid extraction procedures, extraction-kit instructions, and extraction-kit recommendations.

The complete wet-lab method should be performed only by trained personnel familiar with the current ONT protocol for the exact kit, device, and flow cell. The concise checklist below connects an in-house rapid library-preparation variant to the repository's Flye analysis; it is not intended to duplicate the full manufacturer protocol.

## 2. Controlled source documents

Check these pages before every run:

1. [ONT plasmid sequencing from DNA using SQK-RBK114](https://nanoporetech.com/document/rapid-sequencing-v14-plasmid-sequencing-sqk-rbk114-96) - plasmid input, barcoding, the manufacturer-required cleanup, adapter attachment, and the MinION/GridION branch.
2. [ONT Flow Cell Wash Kit EXP-WSH004/EXP-WSH004-XL](https://nanoporetech.com/document/flow-cell-wash-kit-exp-wsh004) - current MinION/GridION wash and post-wash options.

If these documents conflict with any value below, use the current ONT document and update this repository before the next release. The intentional exceptions in this edition are the miniaturized barcoding reaction in Section 4.2 and cleanup bypass in Section 4.3.

## 3. Starting material and preparation

- Begin with purified, high-molecular-weight plasmid DNA.
- The in-house miniaturized branch uses **2.0 µL purified plasmid DNA per sample**. Measure and record the DNA concentration and calculated mass for every sample; the volume alone does not define a universal input mass.
- Normalize samples to a locally validated concentration so that 2.0 µL supplies the intended, comparable DNA mass across barcodes.
- Assess quantity and quality using the current ONT input-QC guidance. Extraction itself is outside this repository's scope.
- Use one unique Rapid Barcode per sample and maintain a sample-to-barcode map.
- Program a thermal cycler for **30°C for 2 minutes, followed by 80°C for 2 minutes**.
- Perform the recommended flow-cell check before starting library preparation.

## 4. Rapid plasmid library preparation

### 4.1 Reagent handling

Follow the current ONT reagent-handling table. In the controlled revision, Rapid Barcodes and RA are not thawed; EB and ADB are thawed at room temperature; ADB is mixed by vortexing; and all specified reagents are briefly spun down and mixed as directed. Barcode wells are single-use. AXP is not used in the rapid cleanup-bypass branch.

### 4.2 Barcoding reaction

Prepare one in-house miniaturized reaction per sample:

> [!IMPORTANT]
> The current ONT plasmid protocol uses approximately 50 ng plasmid DNA in 9 µL plus 1 µL Rapid Barcode. The five-fold miniaturized volumes below are a laboratory-specific deviation and are not an ONT-validated substitute. Accurate 0.2 µL dispensing requires a calibrated low-volume pipetting method. Validate acceptable DNA concentration, input mass, barcode balance, and sequencing performance locally.

| Component | Volume per sample |
| --- | ---: |
| Purified plasmid DNA | 2.0 µL |
| One unique Rapid Barcode (RB01-RB96) | 0.2 µL |
| **Total** | **2.2 µL** |

1. Mix thoroughly by pipetting and briefly spin down.
2. Incubate at 30°C for 2 minutes and then at 80°C for 2 minutes.
3. Briefly cool on ice and spin down.
4. Pool the complete **2.2 µL** barcoding reaction from every sample in a clean 1.5 or 2 mL DNA LoBind tube and record the total volume.

### 4.3 In-house rapid cleanup bypass

> [!IMPORTANT]
> This is a deliberate deviation from the current ONT plasmid protocol, which specifies equal-volume AMPure XP bead cleanup, two ethanol washes, elution, and quantification after pooling. The bypass has not been established by ONT as an equivalent replacement. Validate it locally with appropriate controls and revert to the complete current ONT cleanup if sequencing yield, barcode balance, assembly quality, or reproducibility is inadequate.

1. After pooling the complete miniaturized barcoding reactions, mix the pool thoroughly by gentle pipetting and briefly spin down. Equal input mass and complete transfer of each 2.2 µL reaction are important for representation in the direct-pool aliquot.
2. Transfer **11 µL** of the well-mixed pooled barcoded library to a clean 1.5 mL DNA LoBind tube. If the total pooled volume is less than 11 µL, make up to 11 µL with EB.
3. Do **not** add AXP, perform magnetic separation or ethanol washes, or carry out the bead-elution step.
4. Proceed immediately to rapid-adapter attachment.

### 4.4 Rapid-adapter attachment

1. Use the **11 µL direct pooled library** prepared in Section 4.3. Do not exceed the current ONT maximum library input; if the starting DNA amount differs from Section 3, quantify the pool and follow the current ONT mass limit.
2. Prepare diluted Rapid Adapter:

| Component | Volume |
| --- | ---: |
| Rapid Adapter (RA) | 1.5 µL |
| Adapter Buffer (ADB) | 3.5 µL |
| **Total** | **5 µL** |

3. Add **1 µL** of diluted RA to the 11 µL direct pooled library.
4. Mix gently, briefly spin down, and incubate for **5 minutes at room temperature**.
5. Keep the prepared library on ice until loading and sequence it promptly.

## 5. Flow-cell priming and loading

### 5.1 MinION/GridION branch (FLO-MIN114)

The controlled ONT plasmid protocol specifies the following priming mix:

| Component | Volume per flow cell |
| --- | ---: |
| Flow Cell Flush (FCF) | 1,170 µL |
| BSA, 50 mg/mL | 5 µL |
| Flow Cell Tether (FCT) | 30 µL |
| **Total** | **1,205 µL** |

1. Bring the flow cell to room temperature for 20 minutes and follow the current insertion and flow-cell-check instructions.
2. Open the priming port and draw back only 20-30 µL as directed, keeping the array covered with buffer and avoiding air bubbles.
3. Load **800 µL** priming mix and wait 5 minutes.
4. Immediately before loading, prepare:

| Component | Volume per flow cell |
| --- | ---: |
| Sequencing Buffer (SB) | 37.5 µL |
| Thoroughly resuspended Library Beads (LIB), or LIS where applicable | 25.5 µL |
| Prepared DNA library | 12 µL |
| **Total** | **75 µL** |

5. Complete priming with **200 µL** additional priming mix through the priming port.
6. Gently mix the 75 µL library and load it through the SpotON sample port dropwise, following the current ONT illustrations and port-closing sequence.

### 5.2 PromethION status

**PromethION is not supported by this repository release.** The controlled ONT plasmid protocol lists FLO-MIN114 and provides MinION/GridION loading instructions. ONT's generic PromethION loading guide requires the final library composition to come from the relevant kit-specific protocol and does not, by itself, establish an SQK-RBK114 plasmid workflow for FLO-PRO114M.

Do not scale or adapt the MinION/GridION volumes in this document for PromethION. Add a PromethION branch only after a current ONT kit-specific plasmid protocol explicitly confirms compatibility and all final library, priming, loading, run, wash, and storage settings.

## 6. Data acquisition and basecalling

For the controlled plasmid protocol revision:

1. Select the correct flow cell and Rapid Barcoding Kit in MinKNOW.
2. Set a 12-hour run limit unless a validated study design specifies otherwise.
3. Enable basecalling and select the **high-accuracy (HAC)** model.
4. Enable barcoding.
5. Select POD5 output, retain FASTQ basecalled reads, enable filtering, and enable read splitting.
6. Start the run and monitor read yield and barcode balance.

MinKNOW interfaces and model names change over time. Follow the current ONT screen sequence if it differs.

## 7. Flow-cell washing and storage

Use the current Flow Cell Wash Kit document for the MinION/GridION branch. In the controlled revision, the wash mix per flow cell is:

| Component | Volume per flow cell |
| --- | ---: |
| Wash Mix (WMX) | 2 µL |
| Wash Diluent (DIL) | 398 µL |
| **Total** | **400 µL** |

Prepare the mix fresh, keep WMX on ice, do not vortex WMX or the completed wash mix, and stop or pause acquisition before manipulating the flow cell. The controlled procedure delivers the wash as **two 200 µL additions separated by 5 minutes**, followed by a **1-hour incubation** with the relevant port closed. Follow the current device-specific waste-removal, post-wash reload, or storage sequence. Do not store a flow cell with wash mix on the array.

## 8. Flye analysis

Arrange demultiplexed FASTQ files under `fastq_pass/barcodeNN/`, then run:

```bash
bash ./flye.sh 1 12
```

The script filters reads by minimum length, uses a fixed random seed for repeatable SeqKit downsampling when input order and SeqKit version are also held constant, and runs one Flye assembly per barcode. See [README.md](README.md) for parameters, outputs, and interpretation limits.

## 9. Run records and acceptance checks

- Record the ONT document revision, kit lot, flow-cell ID, device, MinKNOW version, basecalling model, barcode map, and run date.
- Record that the in-house cleanup bypass was used; do not describe the resulting library as prepared fully according to the ONT protocol.
- Record DNA concentration and the approved purity/integrity checks without adding an extraction-kit protocol to this repository.
- Confirm that each requested barcode has reads and an assembly output.
- Review assembly length, contig count, graph/circularity evidence, read support, and expected plasmid features.
- Investigate barcode imbalance, cross-talk, chimeras, unexpected contigs, and large deviations from expected plasmid size.
- During local validation, compare representative samples with the complete ONT cleanup workflow and predefine acceptable read count, barcode balance, assembly completeness, and consensus-quality criteria.

## 10. References

- Oxford Nanopore Technologies. [Plasmid sequencing from DNA using SQK-RBK114 (.24 or .96)](https://nanoporetech.com/document/rapid-sequencing-v14-plasmid-sequencing-sqk-rbk114-96). Controlled revision at preparation: PRB_9188_v114_revK_07Apr2026.
- Oxford Nanopore Technologies. [Loading multiple PromethION Flow Cells](https://nanoporetech.com/document/running-multiple-promethion-flow-cells). Consulted only to assess the compatibility limitation: PFC_9097_v1_revN_29Jan2025.
- Oxford Nanopore Technologies. [Flow Cell Wash Kit EXP-WSH004/EXP-WSH004-XL](https://nanoporetech.com/document/flow-cell-wash-kit-exp-wsh004). Controlled revision at preparation: WFC_9120_v1_revS_25Jul2025.
- Kolmogorov M, Yuan J, Lin Y, Pevzner PA. Assembly of long, error-prone reads using repeat graphs. *Nature Biotechnology*. 2019;37:540-546.
- Shen W, Le S, Li Y, Hu F. SeqKit: a cross-platform and ultrafast toolkit for FASTA/Q file manipulation. *PLOS ONE*. 2016;11:e0163962.
