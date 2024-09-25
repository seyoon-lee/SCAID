![220720_91_scaid_최종-02](https://github.com/user-attachments/assets/460f0e95-6170-4eed-8a0a-5e5550531145)

# SCAID Data Preprocessing Pipeline Ver.1.0

**SCAID** - *Single Cell Atlas of Immune Diseases*

This repository contains a data preprocessing pipeline for the **Single Cell Atlas of Immune Diseases (SCAID)** project. The pipeline automates the preprocessing of single-cell RNA-sequencing (scRNA-seq) data, from raw fastq files to a ready-to-analyze dataset, focusing on immune-related diseases.

## Table of Contents

1. [Creating Input Config file](#creating-input-config-file)
2. [CellRanger Wrapper](#cellranger-wrapper)
3. [CellBender Wrapper](#cellbender-wrapper)
4. [Demultiplexing](#demultiplexing)
5. [Preprocessing](#preprocessing)
6. [Integration](#integration)

---

## Introduction

**SCAID** aims to generate a comprehensive single-cell atlas for immune diseases, providing a detailed cellular landscape and facilitating novel insights into immune cell heterogeneity across diseases. The **SCAID Data Preprocessing Pipeline Ver.1.0** standardizes and streamlines the data preprocessing for single-cell RNA sequencing datasets, supporting various chemistries and preprocessing techniques like ambient RNA removal and demultiplexing.

The pipeline supports multi-modal data types (e.g., 3' GEX, 5' GEX, ATAC, VDJ, and Multiome) and automates the process of data input, preprocessing, and integration for further downstream analysis.

## Creating Input Config file

The first step in the pipeline is generating a configuration file that defines your dataset’s structure. This file should be in CSV format and contain information on raw fastq files and the associated metadata for each sample.

### Example:

The CSV should contain the following columns:
- `Sample_ID`: Unique identifier for each sample
- `Path`: Path to the fastq files
- `Chemistry`: Specifies the sequencing chemistry (e.g., 3' GEX, 5' GEX, VDJ, etc.)
- `Additional_Metadata`: Any additional relevant information

You can customize the fields based on your requirements.



## CellRanger Wrapper

The **CellRanger Wrapper** (`Wrapper_CellRanger.sh`) script automates the execution of various CellRanger workflows for different types of single-cell data and sequencing chemistries. This script supports both single and multiplexed data, with options for SNP or hashtag-based demultiplexing. It handles multiple sequencing technologies such as 3' GEX, 5' GEX, VDJ, ATAC, and Multiome.

### Usage

You can run the `Wrapper_CellRanger.sh` script with the following options:

```bash
bash Wrapper_CellRanger.sh \
    --plex [Single | Multi_SNP | Multi_CSP] \ 
    --chemistry [3 | 5 | ATAC | Multiome] \
    --id [cellranger_id] \
    --fastq_name [fastq prefix name] \
    --fastq_path [directory path where fastqs are located] \
    --config [config csv file]
```

### Supported Chemistries:
- **3' GEX**
- **5' GEX**
- **VDJ**
- **ATAC**
- **Multiome**

This ensures that the appropriate CellRanger commands and parameters are applied to each dataset, simplifying the management of large, complex data repositories.

### Example 1: Running for a Single Plex 3' GEX Sample
```bash
bash Wrapper_CellRanger.sh \
    --plex Single \
    --chemistry 3 \
    --id Sample_001 \
    --fastq_name Sample_001 \
    --fastq_path /path/to/fastq
```

### Example 2: Running for a Multi Plex 5' GEX Sample with SNP Demultiplexing
```bash
bash Wrapper_CellRanger.sh \
    --plex Multi_SNP \
    --chemistry 5 \
    --id Sample_002 \
    --config config_file.csv
```

### Example 3: Running for a Multi Plex 5' GEX Sample with CSP Demultiplexing
```bash
bash Wrapper_CellRanger.sh \
    --plex Multi_CSP \
    --chemistry 5 \
    --id Sample_003 \
    --config config_file.csv
```
