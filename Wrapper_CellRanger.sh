#!/bin/bash
#### Seyoon 240429 Update ####
#1. Single Plex and 3'GEX -> cellranger count
#2. Single Plex and 5'GEX -> cellranger multi
#3. Single Plex and 5'GEX and VDJ  -> cellranger multi

#4. Multi Plex - SNP and 3'GEX -> cellranger count -> souporcell
#5. Multi Plex - SNP and 5'GEX -> cellranger multi -> souporcell
#6. Multi Plex - SNP and 5'GEX and VDJ -> cellranger multi -> souporcell

#7. Multi Plex - CSP and 3'GEX -> cellranger multi
#8. Multi Plex - CSP and 5'GEX -> cellranger multi
#9. Multi Plex - CSP and 5'GEX and VDJ -> cellranger multi

#10. Single Plex and snATAC -> cellranger atac
#11. Multi Plex - SNP and snATAC -> cellranger-atac count -> souporcell
#12. Multi Plex - CSP and snATAC -> cellranger-atac count

#13. Single Plex and Multiome -> cellranger arc
#14. Multi Plex - SNP and Multiome -> cellranger-arc count -> souporcell
#15. Multi Plex - CSP and Multiome -> cellranger-arc count 

# Default values
### fixed directories
s_path="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/01.Script"
output_directory="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output"

### Required input values
plex_info=""
chemistry=""
cellranger_id=""
### Optional input values
fastq_name=""
fastq_path=""
config=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --plex | -p )
            plex_info="$2"
            shift 2
            ;;
        --chemistry | -c )
            chemistry="$2"
            shift 2
            ;;
        --id | -i )
            cellranger_id="$2"
            shift 2
            ;;
        --fastq_name )
            fastq_name="$2"
            shift 2
            ;;
        --fastq_path )
            fastq_path="$2"
            shift 2
            ;;
        --config )
            config="$2"
            shift 2
            ;;
        --csp_config )
            csp_config="$2"
            shift 2
            ;;
        * )
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Check if required options are provided
if [ -z "$plex_info" ] || [ -z "$chemistry" ] || [ -z "$cellranger_id" ]; then
    echo "Usage: $0 --plex|-p <plex_info> --chemistry|-c <chemistry> --id|-i <cellranger_id> [--fastq_name <fastq_name> --fastq_path <fastq_path> --config <config>]"
    exit 1
fi

# Check if fastq_path and fastq_name are required
if [ "$plex_info" != "Multi_CSP" ]; then
    if [ "$chemistry" = "3" ] || [ "$chemistry" = "ATAC" ]; then
        if [ -z "$fastq_name" ] || [ -z "$fastq_path" ]; then
            echo "Error: Both --fastq_name and --fastq_path must be provided when --chemistry is 3 or ATAC"
            exit 1
        fi
    fi
fi

# Check if config is required
if [ "$chemistry" != "3" ] && [ "$chemistry" != "ATAC" ] && [ -z "$config" ]; then
    echo "Error: --config must be provided when --chemistry 5 or Multiome or ATAC is selected"
    exit 1
fi

# Check if config is required
if [ "$plex_info" = "Multi_CSP" ] && [ -z "$config" ]; then
    echo "Error: --config must be provided when --plex Multi_CSP is selected"
    exit 1
fi

# Check if plex_info is one of the allowed values
allowed_values=("Single" "Multi_SNP" "Multi_CSP")
if [[ ! " ${allowed_values[@]} " =~ " $plex_info " ]]; then
    echo "Error: Plex Information must be one of Single, Multi_SNP, or Multi_CSP"
    exit 1
fi

# Check if chemistry is one of the allowed values
allowed_values=("3" "5" "Multiome" "ATAC")
if [[ ! " ${allowed_values[@]} " =~ " $chemistry " ]]; then
    echo "Error: 10X chemistry information must be one of 3, 5, Multiome, or ATAC"
    exit 1
fi


# Check if config csv file has the word "VDJ-B" and/or "VDJ-T" in it. 
VDJ_variable="Not Present"
if [ -n "$config" ]; then
    if grep -q "VDJ-B" "$config" && grep -q "VDJ-T" "$config"; then
        echo "The config csv file contains both 'VDJ-B' and 'VDJ-T'. Running CellRanger Multi with VDJ"
        VDJ_variable="V"
    elif grep -q "VDJ-B" "$config"; then
        echo "The config csv file contains 'VDJ-B'. Running CellRanger Multi with VDJ-B"
        VDJ_variable="B"
    elif grep -q "VDJ-T" "$config"; then
        echo "The config csv file contains 'VDJ-T'. Running CellRanger Multi with VDJ-T"
        VDJ_variable="T"
    else
        echo "The config csv file does not contain 'VDJ-B' or 'VDJ-T'. Running CellRanger Multi without VDJ"
    fi
fi


# Main script logic
echo "chemistry: $chemistry"
echo "plex_info: $plex_info"
echo "cellranger_id: $cellranger_id"

echo "Optional fastq name: $fastq_name"
echo "Optional fastq path directory: $fastq_path"
echo "Optional config file: $config"
echo "Does it also have immune profiling data?: VDJ is $VDJ_variable"

######################### CellRanger Run #################################

### 1. CellRanger Count - 3' GEX and Single Plex
if [ "$plex_info" = "Single" ] && [ "$chemistry" = "3" ]; then
    echo "Running cellranger count script for Single Plex and Chemistry 3 prime..."
    cellranger_id="$cellranger_id"_3G   ## update user set cellranger_id with run option.    
    bash ${s_path}/01.CellRanger_count.sh $cellranger_id $fastq_name $fastq_path > cellranger_count_"$cellranger_id".log
    exit 0
fi

if [ "$plex_info" = "Multi_SNP" ] && [ "$chemistry" = "3" ]; then
    echo "Running cellranger count script for Single Plex and Chemistry 3 prime..."
    cellranger_id="$cellranger_id"_3GS
    bash ${s_path}/01.CellRanger_count.sh $cellranger_id $fastq_name $fastq_path > cellranger_count_"$cellranger_id".log
    exit 0
fi

### 2. CellRanger Multi - 5' GEX (and|or VDJ)
if [ "$plex_info" = "Single" ] && [ "$chemistry" = "5" ]; then
    echo "Running cellranger multi script for Single Plex and Chemistry 5 prime..."
    if [ "$VDJ_variable" = "V" ]; then
        cellranger_id="$cellranger_id"_5GV
    elif [ "$VDJ_variable" = "B" ]; then
        cellranger_id="$cellranger_id"_5GB
    elif [ "$VDJ_variable" = "T" ]; then
        cellranger_id="$cellranger_id"_5GT
    else
        cellranger_id="$cellranger_id"_5G
    fi
    bash ${s_path}/02.CellRanger_multi.sh $cellranger_id $config > cellranger_multi_"$cellranger_id".log
    exit 0
fi

if [ "$plex_info" = "Multi_SNP" ] && [ "$chemistry" = "5" ]; then
    echo "Running cellranger multi script for Multiplex with SNP and Chemistry 5 prime..."
    if [ "$VDJ_variable" = "V" ]; then
        cellranger_id="$cellranger_id"_5GVS
    elif [ "$VDJ_variable" = "B" ]; then
        cellranger_id="$cellranger_id"_5GBS
    elif [ "$VDJ_variable" = "T" ]; then
        cellranger_id="$cellranger_id"_5GTS
    else
        cellranger_id="$cellranger_id"_5GS
    fi
    bash ${s_path}/02.CellRanger_multi.sh $cellranger_id $config > cellranger_multi_"$cellranger_id".log
    exit 0
fi

### 3. CellRanger Multi - CellPlex CSP with 3' or 5'
if [ "$plex_info" = "Multi_CSP" ] && [ "$chemistry" = "3" ]; then
    echo "Running cellranger multi script for Multiplex with CSP and Chemistry 3 prime..."
    cellranger_id="$cellranger_id"_3GH
    bash ${s_path}/02.CellRanger_multi.sh $cellranger_id $config > cellranger_multi_CSP_"$cellranger_id".log
    echo "Now Running bamtofastq, then creating Per sample CSV files..."
    bash ${s_path}/03.Post_multi_CSP_demulti.sh -p $output_directory -f $cellranger_id > cellranger_post_multi_CSP_"$cellranger_id".log
    exit 0
fi

if [ "$plex_info" = "Multi_CSP" ] && [ "$chemistry" = "5" ]; then
    echo "Running cellranger multi script for Multiplex with CSP and Chemistry 5 prime..."
    cellranger_id="$cellranger_id"_5GH
    bash ${s_path}/02.CellRanger_multi.sh $cellranger_id $config > cellranger_multi_CSP_"$cellranger_id".log
    echo "Now Running bamtofastq, then creating Per sample CSV files..."
    bash ${s_path}/03.Post_multi_CSP_demulti.sh -p $output_directory -f $cellranger_id > cellranger_post_multi_CSP_"$cellranger_id".log
    exit 0
fi

### 4. CellRanger ATAC ### all ATAC data in SCAID will be demultiplexed with SNP
if [ "$plex_info" = "Multi_SNP" ] && [ "$chemistry" = "ATAC" ]; then
    echo "Running cellranger atac script for Multiplex with SNP and Chemistry ATAC..."
    cellranger_id="$cellranger_id"_AS
    bash ${s_path}/04.CellRanger-ATAC_count.sh $cellranger_id $fastq_name $fastq_path > cellranger_atac_"$cellranger_id".log
    exit 0
fi

### 5. CellRanger Multiome
if [ "$chemistry" = "Multiome" ]; then
    echo "Running cellranger arc script for Chemistry Multiome..."
    cellranger_id="$cellranger_id"_MS
    bash ${s_path}/05.CellRanger-ARC_count.sh $cellranger_id $config > cellranger_arc_"$cellranger_id".log
    exit 0
fi

echo "$cellranger_id CellRanger Done. Time: `date "+%Y-%m-%d %H:%M:%S"`"

