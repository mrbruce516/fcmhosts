#!/bin/zsh
# 确保 Docker Compose 环境能正常执行
/usr/bin/docker compose -f /home/bruce/Developer/fcmhosts/docker-compose.yml run --rm fcmhosts-updater
