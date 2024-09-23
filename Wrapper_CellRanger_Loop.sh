#!/bin/bash

input="/mnt/gmi-l1/_90.User_Data/sylash92/0.SCAID_Analysis/02.CellRanger_input/ILD_Wrapper_Loop_input_4.txt"
s_path="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/01.Script/"

while read -r cellranger_id plex chemistry config_path fastq_name fastq_path
do
echo "Start $ID"
bash ${s_path}/Wrapper_CellRanger.sh -p $plex -c $chemistry -i $cellranger_id --config $config_path --fastq_name $fastq_name --fastq_path $fastq_path
echo "Done $ID"
done < $input
