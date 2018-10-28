#!/bin/sh

## s3 path structure
# .
# ├── workspace
# │   ├── hoge.dig
# │   └── py
# │        └── hoge.py
# ├── in_file.json
# ├── out_file.json
# ├── run.sh
# ├── runner.py
# ├── stdout.log
# └── stderr.log

## local path structure
# .
# ├── run.sh
# └── digdag-operator-ecs_task
#      ├── workspace
#      │   ├── hoge.dig
#      │   └── py
#      │        └── hoge.py
#      ├── in.json
#      ├── out.json
#      ├── runner.py
#      ├── stdout.log
#      └── stderr.log

set -ex
set -o pipefail

mkdir -p ./digdag-operator-ecs_task
cd digdag-operator-ecs_task

# Download requirements
aws s3 cp s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/ ./ --recursive

# Move workspace
cd workspace

# Run setup command
${ECS_TASK_PY_SETUP_COMMAND} \
        2>> ../stderr.log \
    | tee -a ../stdout.log

# Run
cat runner.py \
    | python - "${ECS_TASK_PY_COMMAND}" \
        ../in.json \
        ../out.json \
        2>> ../stderr.log \
    | tee -a ../stdout.log

# Move out workspace
cd ..

# For logging driver
cat stderr.log 1>&2

# Upload results
aws s3 ./out.json s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/
aws s3 ./stdout.log s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/
aws s3 ./stderr.log s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/
