set -ex
set -o pipefail

mkdir -p ./digdag-operator-ecs_task
cd digdag-operator-ecs_task

# Create output files
touch out.json stdout.log stderr.log

# Download requirements
aws s3 cp s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/ ./ --recursive

# Move workspace
cd workspace

# Unset e option for returning python results to digdag
set +e

# Run setup command
${ECS_TASK_PY_SETUP_COMMAND} \
        2>> ../stderr.log \
    | tee -a ../stdout.log

# Run
cat ../runner.py \
    | python - "${ECS_TASK_PY_COMMAND}" \
        ../in.json \
        ../out.json \
        2>> ../stderr.log \
    | tee -a ../stdout.log

# Capture exit code
EXIT_CODE=$?

# Set e option
set -e

# Move out workspace
cd ..

# For logging driver
cat stderr.log 1>&2

# Upload results
aws s3 cp ./out.json s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/
aws s3 cp ./stdout.log s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/
aws s3 cp ./stderr.log s3://${ECS_TASK_PY_BUCKET}/${ECS_TASK_PY_PREFIX}/

# Exit with the python exit code
exit $EXIT_CODE

