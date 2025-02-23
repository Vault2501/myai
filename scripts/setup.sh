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
  if [ ! -d anything-llm ]; then
    git clone https://github.com/Mintplex-Labs/anything-llm.git
  fi
  cp docker/anything-llm/docker-compose.yaml anything-llm/docker/docker-compose.yml
  cp docker/anything-llm/.env anything-llm/docker
  cd anything-llm/docker
  docker compose down
  docker compose up -d
  popd
}

function setupopenwebui()
{
  pushd ${AIDIR}/openwebui
  docker compose down
  docker compose up -d
  popd
}

setupLocalAI
setupAnythingllm
setupopenwebui
