## Hashtag_demulti: post initial cellranger multi step ##
## v1.0 240312 ##
## HJL ##

## Round up fxn may need further fixation, always check round up number yourself ##
## Use the help fxn and do use absolute path and folder name ##
## Bamtofastq goes into the cellranger ouput folder ##
## Run from SCAID server ##
## In the original config file, GEX library should come before CMO library ##

#!/bin/bash

# Command to put other tools bundled with Cell Ranger in your path:
source /mnt/gmi-l1/_90.User_Data/Shared_SCAID/Programs/cellranger-7.2.0/sourceme.bash

# Function to round up the number
round_up() {
    local number="$1"
    local length=${#number}

    if [ "$length" -gt 1 ]; then
        local second_largest_digit=$((length - 2))
        local rounding_digit=$((10**second_largest_digit))
        local remainder=$((number % rounding_digit))

        if [ "$remainder" -eq 0 ]; then
            # The number is already a multiple of rounding_digit, no rounding needed
            echo "$number"
        else
            # Round up to the next multiple of rounding_digit
            echo "$((number + rounding_digit - remainder))"
        fi
    else
        # Numbers with only one digit are already rounded
        echo "$number"
    fi
}


# Help function
display_help() {
    cat <<EOF
Usage: $0 [-p|--path <absolute_path>] [-f|--folder <folder_id>]

This script extracts the number from all subfolders within the specified path, rounds it up to the second largest digit, and runs bamtofastq.

Options:
  -p, --path   Specify the absolute path where the cellranger output folder will be located.

  -f, --folder Specify the identifier of the folder to process.

Example:
  $ $0 -p /absolute/path/to/base -f my_folder
EOF
}

# Set default values
base_path=""
folder_id=""

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--path)
            base_path="$2"
            shift
            ;;
        -f|--folder)
            folder_id="$2"
            shift
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        *)  # Unknown option or argument
            echo "Error: Unknown option or argument: $1"
            display_help
            exit 1
            ;;
    esac
    shift
done

# Check if folder_id argument is provided
if [ -z "$folder_id" ]; then
    echo "Error: folder_id argument is required."
    display_help
    exit 1
fi

# Set the current working directory to the specified base_path
if [ -n "$base_path" ]; then
    cd "$base_path" || exit 1
fi

# Get the path to all subfolders within per_sample_outs
subfolders=("$folder_id/outs/per_sample_outs"/*/)

# Check if any subfolders exist
if [ "${#subfolders[@]}" -eq 0 ]; then
    echo "No subfolders found in $folder_id/outs/per_sample_outs."
    exit 1
fi


# Create the bamtofastq directory
mkdir -p "$folder_id/bamtofastq"

# Loop through all subfolders
for subfolder in "${subfolders[@]}"; do
    echo "Processing subfolder: $subfolder Time: `date "+%Y-%m-%d %H:%M:%S"`"
    echo #

    # Extract the content within the quotation marks from the specified CSV file
    number=$(grep -o -m 1 'Number of reads,"[^"]*"' "$subfolder/metrics_summary.csv" | sed 's/Number of reads,//; s/,//g; s/"//g')

    # Round up the extracted number to the second largest digit
    number_rounded=$(round_up "$number")

    # Extract the value of the last column of 2nd row (first row after index) which is cell number
    cells_value=$(grep -o -m 1 'Cells,"[^"]*"' "$subfolder/metrics_summary.csv" | sed 's/Cells,//; s/,//g; s/"//g')

    # Output the original and rounded-up numbers
    
    echo "Original number for $subfolder: $number"
    echo "Rounded number for $subfolder: $number_rounded"
    echo "Cells value for $subfolder: $cells_value"
    echo #

    # Run the bamtofastq command with the rounded number
    bamtofastq --reads-per-fastq="$number_rounded" "$subfolder/count/sample_alignments.bam" "$folder_id/bamtofastq/$(basename "$subfolder")"

    # Output a message when the bamtofastq command is done
    echo "bamtofastq command for $subfolder is done. Time: `date "+%Y-%m-%d %H:%M:%S"`"
    echo #

    # Extract the last part of the subfolder path
    subfolder_name=$(basename "$subfolder")

    # Extract the first folder from the subfolder ## which should be GEX as long as you put the GEX first in the original config file
    first_folder=$(basename "$(find "$folder_id/bamtofastq/$subfolder_name/" -mindepth 1 -maxdepth 1 -type d | head -n 1)")

    # Create a CSV file for each subfolder in the folder_id directory
    csv_file="$base_path/$folder_id/${subfolder_name}.csv"

    # Check if the file already exists and overwrite it
    if [ -e "$csv_file" ]; then
        echo "CSV file already exists. Overwriting: $csv_file"
    fi

    cat <<EOF > "$csv_file"
[gene-expression]
reference,/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-gex-GRCh38-2024-A/
force-cells,$cells_value
check-library-compatibility,false
create-bam,true

[vdj]
reference,/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0

[libraries]
fastq_id,fastqs,feature_types
bamtofastq,$base_path/$folder_id/bamtofastq/$subfolder_name/$first_folder,Gene Expression
EOF

    echo "CSV file created for $subfolder_name in $folder_id folder."
    echo #
    echo "###################################### IMPORTANT ##########################################"
    echo "            DONT FORGET TO PUT TCR/BCR INFO TO THE CSV FILE IF NECESSARY "
    echo "ALSO MAKE SURE THAT THE GEX LIBRARY WAS PUT BEFORE CMO LIBRARY IN THE ORIGINAL CONFIG FILE" 
    echo " THIS CODE ASSUMES THAT THE FIRST BAMTOFASTQ SUBFOLDER  CREATED FOR EACH SAMPLE IS FOR GEX"
    echo "###########################################################################################"
    echo #

done




