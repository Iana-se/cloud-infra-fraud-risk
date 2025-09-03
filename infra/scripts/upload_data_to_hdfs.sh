#!/bin/bash
set -euo pipefail
# Функция логирования
log() { echo "[$(date +'%F %T')] $*"; }

# Инициализация источника данных
# if command -v terraform >/dev/null 2>&1 && [ -f infra/terraform.tfstate -o -d .terraform ]; then
#     SOURCE_BUCKET="$(terraform -chdir=infra output -raw source_bucket_name 2>/dev/null || true)"
# fi
# SOURCE_BUCKET="${SOURCE_BUCKET:-otus-mlops-source-data}"

# SOURCE_BUCKET="${SOURCE_BUCKET:-${s3_bucket}}"

if [ -n "${s3_bucket:-}" ]; then
    SOURCE_BUCKET="${s3_bucket}"
elif command -v terraform >/dev/null 2>&1 && [ -f infra/terraform.tfstate -o -d .terraform ]; then
    SOURCE_BUCKET="$(terraform -chdir=infra output -raw source_bucket_name 2>/dev/null || true)"
else
    SOURCE_BUCKET="otus-mlops-source-data"
fi

DEST_HDFS="${DEST_HDFS:-/user/ubuntu/data}"

log "Using source bucket: s3a://${SOURCE_BUCKET}"
log "HDFS destination   : ${DEST_HDFS}"

# Создаём каталог в HDFS
hdfs dfs -mkdir -p "${DEST_HDFS}" || true

# Копируем файл
log "No file specified — copying ALL objects from bucket"
hadoop distcp -m 10 -overwrite "s3a://${SOURCE_BUCKET}/" "hdfs://${DEST_HDFS}"

# Проверяем что все скопированоx
log "Listing HDFS path:"
hdfs dfs -ls -R "${DEST_HDFS}" | head -200
log "Completed"

# # Проверяем, передан ли аргумент (имя файла)
# if [ -n "$1" ]; then
#     FILE_NAME="$1"
#     log "File name provided: $FILE_NAME"
# else
#     log "No file name provided, copying all files"
# fi

# # Создаем директорию в HDFS
# log "Creating directory in HDFS"
# hdfs dfs -mkdir -p /user/ubuntu/data

# # Копируем данные из S3 в зависимости от того, передано ли имя файла
# if [ -n "$FILE_NAME" ]; then
#     # Копируем конкретный файл
#     log "Copying specific file from S3 to HDFS"
#     hadoop distcp s3a://{{ s3_bucket }}/$FILE_NAME /user/ubuntu/data/$FILE_NAME
# else
#     # Копируем все данные
#     log "Copying all data from S3 to HDFS"
#     hadoop distcp s3a://{{ s3_bucket }}/ /user/ubuntu/data
# fi

# # Выводим содержимое директории для проверки
# log "Listing files in HDFS directory"
# hdfs dfs -ls /user/ubuntu/data

# # Проверяем успешность выполнения операции
# if [ $? -eq 0 ]; then
#     log "Data was successfully copied to HDFS"
# else
#     log "Failed to copy data to HDFS"
#     exit 1
# fi
