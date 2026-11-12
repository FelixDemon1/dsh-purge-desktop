#!/bin/bash
set -euo pipefail

export DSH_PURGE_HOME="${DSH_PURGE_HOME:-$HOME/.dsh-purge-desktop-full}"
MANAGER_DIR="$DSH_PURGE_HOME/manager"
if [[ ! -f "$DSH_PURGE_HOME/prompt-inject.md" || ! -f "$MANAGER_DIR/compose.yml" ]]; then
  echo '请先打开一次 DSH Purge Desktop，让它完成初始化。'
  exit 1
fi
if ! command -v docker >/dev/null || ! docker compose version >/dev/null 2>&1; then
  echo '请先从 https://www.docker.com/products/docker-desktop/ 安装 Docker Desktop 并打开。'
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo '请启动 Docker Desktop，并等它显示已运行后重试。'
  exit 1
fi
if ! docker image inspect dsh-purge-desktop/workbuddy-manager:2.11.9 dsh-purge-desktop/workbuddy2api:2.11.9 >/dev/null 2>&1; then
  echo '首次运行：正在导入随应用提供的 WorkBuddy 镜像……'
  docker load -i "$DSH_PURGE_HOME/tools/workbuddy-images.tar.gz"
fi
PASSWORD_FILE="$MANAGER_DIR/admin-password.txt"
if [[ ! -f "$PASSWORD_FILE" ]]; then
  umask 077
  openssl rand -hex 20 > "$PASSWORD_FILE"
fi
export WB_ADMIN_PASSWORD="$(cat "$PASSWORD_FILE")"
docker compose -p dshpurgedesktop -f "$MANAGER_DIR/compose.yml" up -d
echo
echo '管理页面：http://127.0.0.1:18864'
echo '管理员用户名：admin'
echo '管理员密码保存在：'"$PASSWORD_FILE"
echo '打开该文件即可查看密码；请勿分享此文件。'
echo '首次使用请在管理页面扫码授权自己的账号，并创建供 DSH 使用的 API 密钥。'
open 'http://127.0.0.1:18864'
