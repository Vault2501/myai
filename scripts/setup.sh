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
  mkdir searxng/searxng
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
  cd chatgpt_telegram_bot
  docker compose down
  docker compose up --build -d
  popd
}

function setupComfyUI()
{
  pushd ${AIDIR}
  if [ ! -d ComfyUI-Docker ]; then 
    git clone https://github.com/YanWenKun/ComfyUI-Docker.git 
  fi
  cp docker/cu124-megapak/docker-compose.yaml ComfyUI-Docker/cu124-megapak/
  cd ComfyUI-Docker/cu124-megapak
  docker compose down
  docker compose up -d
  popd
}

function setupSstableDiffusionWebui()
{
  pushd ${AIDIR}
  if [ ! -d ComfyUI-Docker ]; then 
    git clone https://github.com/AbdBarho/stable-diffusion-webui-docker.git 
  fi
  cp docker/stable-diffusion-webui-docker/docker-compose.yaml stable-diffusion-webui-docker/
  # temp fix, todo: fork git and replace there
  cp docker/stable-diffusion-webui-docker/Dockerfile stable-diffusion-webui-docker/services/AUTOMATIC1111/
  cd stable-diffusion-webui-docker 
  docker compose down
  # download models
  docker compose --profile download up --build
  # start container
  docker compose --profile auto up --build
  popd
}

function setupNgix()
{
  pushd ${AIDIR}/nginx
  docker compose down
  docker compose up -d
  popd
}

setupLocalAI
setupSearxng
setupAnythingllm
setupOpenwebui
setupOpenwebuiPipelines
setupComfyUI
setupSstableDiffusionWebui
setupTelegramBot
setupNginx
