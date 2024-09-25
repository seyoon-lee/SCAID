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


## CellBender Wrapper

The **CellBender Wrapper** (`Wrapper_CellBender.sh`) automates the ambient RNA removal process using **CellBender v0.3.0** for specific disease codes from the **SCAID** dataset. This script filters CellRanger output files based on a disease code and runs **CellBender** on the `raw_feature_bc_matrix.h5` files, removing ambient RNA contamination to enhance the quality of downstream single-cell data analysis.

### Usage

This script requires a disease code as input. It automatically identifies the relevant `raw_feature_bc_matrix.h5` files, processes them with **CellBender**, and stores the cleaned data in the same directory.

```bash
bash Wrapper_CellBender.sh <disease_code>
```

#### Parameters
<disease_code>: The code associated with the disease or dataset of interest (e.g., "ILD"). This code is used to filter the files before running CellBender.

#### Workflow
1. Activate the CellBender Environment: The script begins by activating the CellBender v0.3.0 environment. You may replace the default environment path with your own if necessary.

```bash
source activate cellbender
```
2. Find CellRanger Output Files: It searches for raw_feature_bc_matrix.h5 files in the specified CellRanger output directory (/02.CellRanger_output).

3. Filter by Disease Code: The script filters the list of raw_feature_bc_matrix.h5 files based on the specified disease code (from the 7th layer of the file path). Only files located in the "outs" directory are considered for processing.

4. Run CellBender: For each filtered file, the script checks whether CellBender has already been run (i.e., if a CellBender_Done file exists). If not, CellBender is executed to remove ambient RNA contamination using the following parameters:

- input: The path to the raw_feature_bc_matrix.h5 file.
- output: The cleaned file is saved as <cellranger_id>_cellbender_output.h5.
- cuda: Enables GPU acceleration for faster processing.
- fpr: Sets the false positive rate threshold for ambient RNA (default: 0.01, 0.05, 0.1).
- epochs: Number of training epochs (default: 150).
- low-count-threshold: Sets the threshold for low counts (default: 5).
- projected-ambient-count-threshold: Sets the projected ambient count threshold (default: 0.1; may need adjustment for scATAC-seq data).

5. Mark Completion: Once CellBender has successfully processed a sample, a CellBender_Done file is created in the sample directory to avoid redundant reprocessing.

#### Notes
The script prevents reprocessing by checking for the presence of a CellBender_Done file.
You can modify the CellBender parameters (e.g., fpr, epochs, etc.) depending on your data requirements, such as using different thresholds for scATAC-seq data.

