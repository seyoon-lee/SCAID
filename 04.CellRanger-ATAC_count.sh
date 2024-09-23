## 24.03.12 SY ##

### Software ###
cellranger_atac="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Programs/cellranger-atac-2.1.0/cellranger-atac"

### Output Directory ###
output_directory='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output'

### DBs ###
human_GRCh38_atac_ref='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-cellranger-arc-GRCh38-2020-A-2.0.0`'

### Arguments ###
cellranger_id=$1
fastq_name=$2
fastq_path=$3

################ CellRanger ATAC v2.1.0 Running ##################
cd ${output_directory}
echo "Started cellranger atac v2.1.0 count with ${cellranger_id}. Time: `date "+%Y-%m-%d %H:%M:%S"`"

${cellranger_atac} count --id=${cellranger_id} \
                         --sample=${fastq_name} \
                         --fastqs=${fastq_path} \
                         --reference=${human_GRCh38_atac_ref} \
                         --localcores=40 \
                         --localmem=256

echo "${cellranger_id} CellRanger ATAC v2.1.0 count Done. Time: `date "+%Y-%m-%d %H:%M:%S"`"
