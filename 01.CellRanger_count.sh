## 24.03.18 SY ##

### Software ###
cellranger8="/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Programs/cellranger-8.0.0/cellranger"

### Output Directory ###
output_directory='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/02.CellRanger_output'

### DBs ###
human_GRCh38_ref='/mnt/gmi-l1/_90.User_Data/Shared_SCAID/Reference/_10xgenomics/refdata-gex-GRCh38-2024-A'

### Arguments ###
cellranger_id=$1
fastq_name=$2
fastq_path=$3

################ CellRanger v8.0.0 Running #################
cd ${output_directory}
echo "Started cellranger_v8.0 count with ${cellranger_id}. Time: `date "+%Y-%m-%d %H:%M:%S"`"

${cellranger8} count --id=${cellranger_id} \
                     --fastqs=${fastq_path} \
                     --sample=${fastq_name} \
                     --transcriptome=${human_GRCh38_ref} \
        		     --create-bam=true \
                     --localcores=40 \
                     --localmem=256

echo "${cellranger_id} CellRanger_v8.0 count Done. Time: `date "+%Y-%m-%d %H:%M:%S"`"
