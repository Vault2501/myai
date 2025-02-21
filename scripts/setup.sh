#!/bin/sh

AIDIR=$(dirname "$0")/..



function cleanup()
{
  popd
}

trap cleanup EXIT

function setupLocalAI()
{
  pushd ${AIDIR}/production/LocalAI
  docker compose up -d
  popd
}

setupLocalAI
