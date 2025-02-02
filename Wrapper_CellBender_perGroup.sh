#!/bin/bash
## 24.03.14 SY ##

### Activate cellbender v0.3.0 environment ### You can replace it with your own cellbender env.
source /mnt/gmi-l1/_90.User_Data/sylash92/1.Programs/miniforge3/bin/activate cellbender
mamba list | grep -E '^python |cellbender'
echo
echo

# Check if disease_code is provided as an argument, otherwise set default value
if [ $# -eq 0 ]; then
    echo "Usage: $0 <disease_code>"
    exit 1
fi

# Get disease_code from command-line argument
disease_code="$1"

### Where all CellRanger outputs are located
cellranger_output_path="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output"

### Create a list of raw_feature_bc_matrix.h5 files to parse
raw_matrix_h5_list=$(find ${cellranger_output_path} -type f -name 'raw_feature_bc_matrix.h5')

### raw_matrix_h5 list for cellranger output of the query disease set
filtered_list=""

for file_path in $raw_matrix_h5_list; do
    # Extract the 7th and 8th layers of the path because 7th layer is the cellranger_id and sometimes h5 files are present under SC_MULTI_CS 
    seventh_layer=$(echo "$file_path" | cut -d'/' -f7)
    eighth_layer=$(echo "$file_path" | cut -d'/' -f8)

    # Check if the 7th layer contains "ILD" and the 8th layer is exactly "outs"
    if [[ "$seventh_layer" == *"$disease_code"* ]] && [[ "$eighth_layer" == "outs" ]]; then
        filtered_list="$filtered_list $file_path"
    fi
done

for file_path in $filtered_list; do
    echo "$file_path"
done

# Loop through each file in the file_list
for file_path in $filtered_list; do
    # Get the directory of the current file
    dir=$(dirname "$file_path")

    # Get the cellranger id from this directory. Only will work for current SCAID settings.
    cellranger_id=$(echo "$dir" | cut -d'/' -f7)

    # Change directory to the directory containing the file
    cd "$dir" || exit

    # Check if 'CellBender_Done' exists in the current directory
    if [ -e "CellBender_Done" ]; then
        echo "CellBender had been done for ${cellranger_id}"
    else
        echo "Running CellBender v0.3.0 in ${cellranger_id}"
        cellbender remove-background \
                --input raw_feature_bc_matrix.h5 \
                --output ${cellranger_id}_cellbender_output.h5 \
                --cuda \
                --fpr 0.01 0.05 0.1 \
                --epochs 150 \
                --low-count-threshold 5 \
                --projected-ambient-count-threshold 0.1
        # Create CellBender_Done file
        touch CellBender_Done
        echo "${cellranger_id} CellBender v0.3.0 remove-background Done. Time: `date "+%Y-%m-%d %H:%M:%S"`"
    fi
done

#################################################################################################################
# fpr default is 0.01                                                                                           #
# epochs default is 150                                                                                         #
# low-count-threshold default is 5                                                                              #
# projected-ambient-count-threshold default is 0.1. But we may need to change it to 2 for scATAC seq data.      #
#################################################################################################################



