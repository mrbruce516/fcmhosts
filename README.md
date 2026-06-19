# FCM Hosts for Mihomo

自动获取 FCM (Firebase Cloud Messaging) hosts 模板，合并到 Mihomo (Clash Meta) 配置文件 `android_fcm.yaml` 中。通过 Docker 容器化部署，每 12 小时自动更新一次，确保 Android 设备上的 FCM 推送通知始终使用最新可用的 IP 地址。

## 背景

Android 设备在国内网络环境下，FCM 推送服务可能因 DNS 污染或网络限制导致无法正常连接。通过配置正确的 hosts 映射，可以确保 FCM 相关域名解析到可用 IP，从而恢复推送通知功能。

## 文件说明

| 文件 | 说明 |
|------|------|
| `README.md` | 项目说明文档 |
| `android_fcm.yaml` | Mihomo (Clash Meta) 配置文件，由 updater.py 自动生成，包含合并后的 hosts 段 |
| `updater.py` | Python 更新脚本，下载 FCM hosts 模板，从远程下载源配置并合并 hosts 到 yaml |
| `Dockerfile` | Docker 镜像构建文件 |
| `pyproject.toml` | Python 项目配置，依赖管理使用 uv |
| `requirements.txt` | Python 依赖清单 |

## 工作原理

```
┌──────────────────┐     ┌──────────────┐     ┌──────────────────┐
│  GitHub 模板       │────▶│  updater.py  │────▶│ android_fcm.yaml │
│  fcm_ipv4.hosts   │     │  下载 & 合并   │     │  hosts 已更新     │
└──────────────────┘     └──────────────┘     └──────────────────┘
                                   │
                           ┌───────▼────────┐
                           │  远程源配置       │
                           │  android.yaml   │
                           └────────────────┘

                ┌────────────────────┐
                │  Cron / 手动触发     │
                │  每 12 小时自动执行   │
                └────────────────────┘
```

1. 从 GitHub 下载最新的 FCM hosts 模板（IPv4）
2. 从远程 URL 下载 Mihomo 源配置
3. 解析 hosts 模板，合并到源配置中（已有 hosts 段则替换，否则追加）
4. 在文件头部添加生成时间戳注释
5. 输出为 `android_fcm.yaml`

## 快速开始

### 1. 构建 Docker 镜像

```bash
docker build -t fcmhosts-updater .
```

> 基础镜像使用 `python:3.14-alpine`，包管理使用 `uv`。

### 2. 运行容器

```bash
docker run -d \
  --name fcmhosts-updater \
  -v $(pwd)/android_fcm.yaml:/app/android_fcm.yaml \
  fcmhosts-updater
```

容器启动后会立即执行一次更新，之后每 12 小时自动更新一次。

### 3. 手动触发更新

```bash
docker exec fcmhosts-updater python /app/updater.py
```

### 4. 查看日志

```bash
docker logs -f fcmhosts-updater
```

## 配置说明

脚本会从远程 URL 下载源配置，将 FCM hosts 模板合并后输出为 `android_fcm.yaml`。如果源配置中已有 `hosts:` 段则替换，否则在末尾追加。源配置中的其他内容（包括注释和格式）不会被修改。

生成的文件顶部会带有时间戳注释，便于追踪更新时间。使用时需确保 Mihomo 配置中 `dns.use-hosts: true`，无论是 `fake-ip` 还是 `redir-host` 模式均可生效。

## 本地开发

```bash
# 安装 uv（如未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 同步依赖
uv sync

# 手动执行更新
uv run python updater.py
```

## 相关链接

- [FCM Hosts 模板](https://github.com/cagedbird043/fcm-hosts-next)
- [Mihomo (Clash Meta)](https://github.com/MetaCubeX/mihomo)