## 24.03.12 SY ##

### Software ###
cellranger_arc="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Programs/cellranger-arc-2.0.2/cellranger-arc"

### Output Directory ###
output_directory='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output'

### DBs ###
human_GRCh38_arc_ref='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-cellranger-arc-GRCh38-2020-A-2.0.0'

### Arguments ###
cellranger_id=$1
config=$2

################ CellRanger-ARC v2.0.2 Running ##################
cd ${output_directory}
echo "Started cellranger arc v2.0.2 count with ${cellranger_id}. Time: `date "+%Y-%m-%d %H:%M:%S"`"

${cellranger_arc} count --id=${cellranger_id} \
                        --libraries=${config} \
                        --reference=${human_GRCh38_arc_ref} \
                        --localcores=40 \
                        --localmem=256

echo "${cellranger_id} CellRanger ARC v2.0.2 count Done. Time: `date "+%Y-%m-%d %H:%M:%S"`"
