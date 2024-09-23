#!/bin/bash

################ SoupOrCell Running #################
source /mnt/gmi-l1/_90.User_Data/sylash92/1.Programs/miniforge3/bin/activate souporcell
mamba list | grep -E '^python |souporcell'

souporcellpy="/mnt/gmi-l1/_90.User_Data/sylash92/3.Environments/souporcell/souporcell_pipeline.py"
cellranger_output="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output"

# Define the list of sample-multiplex_k pairs
## 24.03.26 SY ##
## Rerun using cellbender barcodes ##
       #"AA_B0005a-B0008a-B0017a-B0029a_5GTS 4"
       #"AA_B0033a-B0055a-B0002a-B0006a_5GTS 4"
       #"AA_B0010a-B0019a-B0034a-B0043a_5GTS 4"
       #"AA_B0045a-B0047a-B0059a-B0071a_5GTS 4"
       #"AA_B0005b-B0008b-B0017b-B0029b_5GTS 4"
       #"AA_B0033b-B0055b-B0002b-B0006b_5GTS 4"
       #"AA_B0010b-B0019b-B0034b-B0043b_5GTS 4"
       #"AA_B0045b-B0047b-B0059b-B0071b_5GTS 4"

## 24.04.10 SY ##
pairs=("RAAS_B0001a-S0002a-S0003a_5GVS 3"
       "RAAS_B0003a-S0008a-S0006a_5GVS 3"
       "RAAS_B0004a-S0005a-S0001a_5GVS 3"
       "RAAS_B0006a-S0007a-S0004a_5GVS 3"
       "RAAS_B0015a-B0016a-B0017a_5GTS 3"
       "RAAS_B0018a-B0019a-B0020a_5GTS 3"
       "RAAS_S0009a-S0010a-S0011a_5GTS 3"
       "RAAS_S0012a-S0013a-S0014a_5GTS 3"
       "RAAS_S0015a-S0016a-S0017a_5GTS 3"
       "RAAS_S0018a-S0019a-S0020a_5GTS 3"
       "PSO_T0001a-T0002a-T0003a_5GS 3")

# Iterate through each pair
for pair in "${pairs[@]}"; do
    # Extract sample and multiplex_k from the pair
    sample=$(echo "$pair" | cut -d ' ' -f 1)
    multiplex_k=$(echo "$pair" | cut -d ' ' -f 2)
    
    # Run your Python script with the current sample and multiplex_k values
    # Use CellBender output cellbarcodes.csv
    python ${souporcellpy} \
        -i "${cellranger_output}/${sample}/outs/per_sample_outs/${sample}/count/sample_alignments.bam" \
        -b "${cellranger_output}/${sample}/outs/multi/count/${sample}_cellbender_output_cell_barcodes.csv" \
        -f "/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-gex-GRCh38-2024-A/fasta/genome.fa" \
        -t 20 \
        -o "${cellranger_output}/${sample}/souporcell_output/" \
        -k "${multiplex_k}"
done
