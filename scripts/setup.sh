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

function setupSearxng()
{
  pushd ${AIDIR}
  if [ ! -d searxng ]; then 
    git clone https://github.com/searxng/searxng.git
  fi
  cp docker/searxng/docker-compose.yaml searxng/
  cp docker/searxng/.env searxng/
  cp config/searxng/settings.yml searxng/searxng/
  cd searxng
  docker compose down
  docker compose up -d
  popd
}

function setupOpenwebui()
{
  pushd ${AIDIR}/openwebui
  docker compose down
  docker compose up -d
  echo Waiting for first setup
  sleep 60
  docker compose down
  docker compose up -d
  popd
}

function setupOpenwebuiPipelines()
{
  pushd ${AIDIR}
  if [ ! -d pipelines ]; then
    git clone https://github.com/open-webui/pipelines.git
  fi
  cp docker/pipelines/docker-compose.yaml pipelines
  cd pipelines
  docker compose down
  docker compose up -d
  popd
}

#setupLocalAI
#setupSearxng
#setupAnythingllm
#setupOpenwebui
setupOpenwebuiPipelines
