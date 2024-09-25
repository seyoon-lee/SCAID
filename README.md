![220720_91_scaid_최종-02](https://github.com/user-attachments/assets/460f0e95-6170-4eed-8a0a-5e5550531145)

# SCAID Data Preprocessing Pipeline Ver.1.0

**SCAID** - *Single Cell Atlas of Immune Diseases*

This repository contains a data preprocessing pipeline for the **Single Cell Atlas of Immune Diseases (SCAID)** project. The pipeline automates the preprocessing of single-cell RNA-sequencing (scRNA-seq) data, from raw fastq files to a ready-to-analyze dataset, focusing on immune-related diseases.

## Table of Contents

1. [Creating Input Config file](#creating-input-config-file)
2. [CellRanger Wrapper](#cellranger-wrapper)
3. [CellBender Wrapper](#cellbender-wrapper)
4. [CSP Demultiplexing](#CSP-Demultiplexing---Hashtag_demulti)
5. [SNP Demultiplexing](#SNP-Demultiplexing---SoupOrCell)
6. [Preprocessing](#preprocessing)
7. [Integration](#integration)

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
**1. Activate the CellBender Environment**: The script begins by activating the CellBender v0.3.0 environment. You may replace the default environment path with your own if necessary.

```bash
source activate cellbender
```
**2. Find CellRanger Output Files**: It searches for raw_feature_bc_matrix.h5 files in the specified CellRanger output directory (/02.CellRanger_output).

**3. Filter by Disease Code**: The script filters the list of raw_feature_bc_matrix.h5 files based on the specified disease code (from the 7th layer of the file path). Only files located in the "outs" directory are considered for processing.

**4. Run CellBender**: For each filtered file, the script checks whether CellBender has already been run (i.e., if a CellBender_Done file exists). If not, CellBender is executed to remove ambient RNA contamination using the following parameters:

    - input: The path to the raw_feature_bc_matrix.h5 file.
    - output: The cleaned file is saved as <cellranger_id>_cellbender_output.h5.
    - cuda: Enables GPU acceleration for faster processing.
    - fpr: Sets the false positive rate threshold for ambient RNA (default: 0.01, 0.05, 0.1).
    - epochs: Number of training epochs (default: 150).
    - low-count-threshold: Sets the threshold for low counts (default: 5).
    - projected-ambient-count-threshold: Sets the projected ambient count threshold (default: 0.1; may need adjustment for scATAC-seq data).

**5. Mark Completion**: Once CellBender has successfully processed a sample, a CellBender_Done file is created in the sample directory to avoid redundant reprocessing.

#### Notes
The script prevents reprocessing by checking for the presence of a CellBender_Done file.


## CSP Demultiplexing - Hashtag_demulti

The **CSP Demultiplexing** (`Hashtag_demulti.sh`) script is designed to automate the post-CellRanger multi-step demultiplexing process for hashtag-labeled (CSP) single-cell RNA-seq data. The script processes CellRanger outputs by extracting and formatting the necessary data for downstream analyses, and it converts BAM files into FASTQ files using **bamtofastq**.

#### Usage

This script processes all the sample outputs from a CellRanger multi-step run, extracts key metrics (such as the number of reads and cells), rounds up the number of reads, and runs **bamtofastq** on the corresponding BAM files.

```bash
bash Hashtag_demulti.sh -p <absolute_path> -f <folder_id>
```

#### Parameters

- **-p, --path**: Specify the absolute path to the base directory where the CellRanger output folder is located.
- **-f, --folder**: Specify the folder identifier for the CellRanger run to process.

#### Example

```bash
bash Hashtag_demulti.sh -p /mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output -f sample_001
```

#### Workflow

1. **Activate CellRanger Tools**:  
   The script begins by sourcing the bundled tools with **CellRanger** to ensure **bamtofastq** and other required tools are available in the path.

   ```bash
   source /mnt/gmi-l1/_90.User_Data/Shared_SCAID/Programs/cellranger-7.2.0/sourceme.bash
   ```

2. **Round Up Function**:  
   The script includes a custom function to round up the number of reads extracted from the metrics file to the nearest significant digit. This ensures optimal splitting of FASTQ files during the bamtofastq step.

3. **Identify Subfolders**:  
   The script searches for all subfolders within the `outs/per_sample_outs` directory for each sample in the specified `folder_id`.

4. **Extract and Process Metrics**:  
   For each subfolder, the script extracts the number of reads and the number of cells from the `metrics_summary.csv` file. It then rounds up the number of reads and prepares to process the BAM files.

5. **Run bamtofastq**:  
   The **bamtofastq** tool is run on the BAM file for each subfolder, using the rounded number of reads to split the files appropriately.

   ```bash
   bamtofastq --reads-per-fastq=<rounded_number_of_reads> <input_bam_file> <output_fastq_directory>
   ```

6. **Create Per-Sample CSV**:  
   After converting the BAM to FASTQ, the script generates a configuration CSV file for each sample. This file includes:
   
   - **Gene Expression** library configuration.
   - **VDJ** library configuration.
   - A **library list** that points to the generated FASTQ files for each sample.

   The CSV is created in the base path and is used for downstream processing.

7. **Important Considerations**:  
   The script assumes that the first `bamtofastq` folder created for each sample is for **Gene Expression (GEX)**. It is important to ensure that the **GEX** library comes before the **CMO** library in the original CellRanger config file.

#### Example Output

For each sample processed, the script generates:
- A folder containing the **FASTQ** files split from the BAM file.
- A per-sample **CSV** file that specifies the libraries and references for the subsequent CellRanger or downstream analysis.

#### Notes

- **Custom BAM and FASTQ Processing**: The script extracts the number of reads and cells from the CellRanger output metrics, rounds the reads, and splits the BAM files into FASTQ files for further analysis.
- **CSV Creation**: After processing, a CSV file is generated for each sample, specifying the reference data, the number of cells, and the libraries to be used in future analyses.
- **Ensure Proper GEX and CMO Configuration**: The script assumes that **GEX** appears before **CMO** in the original configuration file. This should be verified manually in cases where **TCR/BCR** information is included.


## SNP Demultiplexing - SoupOrCell

The **SNP Demultiplexing** (`souporcell.sh`) script is designed to handle the SNP-based demultiplexing of multiplexed single-cell RNA-seq data. It uses the **SoupOrCell** algorithm to demultiplex cells based on genetic variation (SNPs) between individuals. This script processes **CellRanger** outputs and uses **CellBender**-filtered barcodes to accurately assign cells to their respective donors.

#### Usage

This script processes all multiplexed sample outputs from **CellRanger**, identifies SNP clusters, and assigns cells to individual donors. It requires **CellBender**-processed barcode files and corresponding BAM files.

```bash
bash souporcell.sh
```

#### Parameters

This script iterates through a predefined list of sample-multiplex_k pairs, where:

- `sample`: The name of the sample processed by **CellRanger**.
- `multiplex_k`: The number of multiplexed individuals (donors) in the sample.

#### Workflow

1. **Activate the SoupOrCell Environment**: The script activates the `souporcell` environment to run the **SoupOrCell** pipeline.
    ```bash
    source activate souporcell
    ```
   
2. **Process CellRanger Outputs**: For each sample, the script uses the BAM file generated by **CellRanger** and the cell barcodes processed by **CellBender** to perform SNP-based demultiplexing.

3. **Run SoupOrCell**: The script runs **SoupOrCell** on the BAM and barcode files, specifying the number of donors (`multiplex_k`) and outputs the demultiplexing results, including cell assignments and SNP clusters.

#### Output Files
- `clusters.tsv`: SNP-based clusters that identify cells belonging to different donors.
- `genotype.vcf`: SNP genotype information for each donor.
- `assignment.tsv`: A file linking each cell barcode to its respective donor.


# Acknowledgements:
**Developers**
[https://x.com/Seyoon_L]

**Research Funding**
This research was supported by the Bio & Medical Technology Development Program of the National Research Foundation (NRF) funded by the Korean government (MSIT) (No. 2022M3A9D3016848). 
![image](https://github.com/user-attachments/assets/a6eac0c1-1745-4f8b-84b7-6024374036d9)
