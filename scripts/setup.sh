#!/bin/sh

AIDIR=$(dirname "$0")/..



function cleanup()
{
  popd 2>/dev/null
}

trap cleanup EXIT

function startLocalAI()
{
  pushd ${AIDIR}/LocalAI
  docker compose up -d
  popd
}

function stopLocalAI()
{
  pushd ${AIDIR}/LocalAI
  docker compose down
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
  popd
}

function startAnythingllm()
{
  pushd ${AIDIR}/anything-llm/docker
  docker compose up -d
  popd
}

function stopAnythingllm()
{
  pushd ${AIDIR}/anything-llm/docker
  docker compose down
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
  mkdir searxng/searxng
  cp config/searxng/settings.yml searxng/searxng/
  popd
}

function startSearxing()
{
  cd ${AIDIR}/searxng
  docker compose up -d
  popd
}

function stopSearxing()
{
  cd ${AIDIR}/searxng
  docker compose down
  popd
}

function startOpenwebui()
{
  pushd ${AIDIR}/openwebui
  docker compose up -d
  echo Waiting for first setup
  sleep 60
  docker compose down
  docker compose up -d
  popd
}

function stopOpenwebui()
{
  pushd ${AIDIR}/openwebui
  docker compose down
  popd
}

function setupOpenwebuiPipelines()
{
  pushd ${AIDIR}
  if [ ! -d pipelines ]; then
    git clone https://github.com/open-webui/pipelines.git
  fi
  cp docker/pipelines/docker-compose.yaml pipelines
  popd
}

function startOpenwebuiPipelines()
{
  pushd ${AIDIR}/pipelines
  docker compose up -d
  popd
}

function stopOpenwebuiPipelines()
{
  pushd ${AIDIR}/pipelines
  docker compose down
  popd
}

function setupTelegramBot()
{
  read -s -p "Please enter the Telegram token" TOKEN 
  pushd ${AIDIR}
  if [ ! -d chatgpt_telegram_bot ]; then
    git clone https://github.com/Vault2501/chatgpt_telegram_bot 
  fi
  cp docker/chatgpt_telegram_bot/docker-compose.yml chatgpt_telegram_bot/
  cp config/chatgpt_telegram_bot/config.yml chatgpt_telegram_bot/config/
  cp config/chatgpt_telegram_bot/config.env chatgpt_telegram_bot/config/
  sed -i "s/telegram_token:.*/telegram_token: \"$TOKEN\"/" chatgpt_telegram_bot/config/config.yml
  popd
}

function startTelegramBot()
{
  pushd ${AIDIR}/chatgpt_telegram_bot
  docker compose up --build -d
  popd
}

function stopTelegramBot()
{
  pushd ${AIDIR}/chatgpt_telegram_bot
  docker compose down
  popd
}

function setupComfyUI()
{
  pushd ${AIDIR}
  if [ ! -d ComfyUI-Docker ]; then 
    git clone https://github.com/YanWenKun/ComfyUI-Docker.git 
  fi
  cp docker/cu124-megapak/docker-compose.yaml ComfyUI-Docker/cu124-megapak/
  popd
}

function startComfyUI()
{
  pushd ${AIDIR}/ComfyUI-Docker/cu124-megapak
  docker compose up -d
  popd
}

function stopComfyUI()
{
  pushd ${AIDIR}/ComfyUI-Docker/cu124-megapak
  docker compose down
  popd
}

function setupStableDiffusionWebui()
{
  pushd ${AIDIR}
  if [ ! -d ComfyUI-Docker ]; then 
    git clone https://github.com/AbdBarho/stable-diffusion-webui-docker.git 
  fi
  cp docker/stable-diffusion-webui-docker/docker-compose.yaml stable-diffusion-webui-docker/
  # temp fix, todo: fork git and replace there
  cp docker/stable-diffusion-webui-docker/Dockerfile stable-diffusion-webui-docker/services/AUTOMATIC1111/
  popd
}

function startStableDiffusionWebui()
{
  pushd ${AIDIR}/stable-diffusion-webui-docker 
  # download models
  docker compose --profile download up --build
  # start container
  docker compose --profile auto up --build
  popd
}

function stopStableDiffusionWebui()
{
  pushd ${AIDIR}/stable-diffusion-webui-docker 
  docker compose down
  popd
}

function startNgix()
{
  pushd ${AIDIR}/nginx
  docker compose up -d
  popd
}

function stopNgix()
{
  pushd ${AIDIR}/nginx
  docker compose down
  popd
}

setupSearxng
setupAnythingllm
setupOpenwebuiPipelines
setupComfyUI
setupSstableDiffusionWebui
setupTelegramBot

#startLocalAI
#startNginx
#startOpenwebui
