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

function setupAnything-llm()
{
  pushd ${AIDIR}
  git clone https://github.com/Mintplex-Labs/anything-llm.git
  cp ${AIDIR}/docker/anything-llm/* ${AIDIR}/anything-llm/docker
  pushd ${AIDIR}/anything-llm/docker
  docker compose up
  popd
  popd
}

#setupLocalAI
setupAnything-llm
