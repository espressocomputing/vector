#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
revision=$(git rev-parse HEAD)
image=${1:-vector:0.58.0-espresso-${revision:0:12}}
features=sources-kafka,sources-internal_metrics,sources-stdin,sinks-aws_s3,sinks-prometheus,sinks-console,transforms-remap,transforms-filter,codecs-parquet,vrl/stdlib,kafka-integration-tests

cargo build --locked --release --no-default-features --features "$features"
context=$(mktemp -d)
trap 'rm -rf "$context"' EXIT
cp target/release/vector "$context/vector"
cp distribution/docker/debian/Dockerfile.espresso "$context/Dockerfile"
docker build --platform linux/amd64 --build-arg "SOURCE_REVISION=$revision" -t "$image" "$context"
docker run --rm "$image" --version
