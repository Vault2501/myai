#!/bin/sh

AIDIR=$(dirname "$0")/..



function cleanup()
{
  popd 2>/dev/null
}

trap cleanup EXIT

function setupLocalAI()
{
  pushd ${AIDIR}/LocalAI
  docker compose down
  docker compose up -d
  popd
}

function setupAnythingllm()
{
  pushd ${AIDIR}
  git clone https://github.com/Mintplex-Labs/anything-llm.git
  cp docker/anything-llm/docker-compose.yaml docker/anything-llm/.env anything-llm/docker
  cd anything-llm/docker
  docker compose up
  popd
}

#setupLocalAI
setupAnythingllm
