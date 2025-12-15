#!/bin/sh

# =========================================
# 一键运行 GitHub wp-admin-arg-limit.sh
# 自动备份 CRS 配置并执行操作
# 参数: enable | disable | preview
# =========================================

# GitHub 原始脚本 URL
SCRIPT_URL="https://raw.githubusercontent.com/Project0ne/kejilion-Unlock-ModSecurity/main/wp-admin-arg-limit.sh"

# 本地 CRS 配置文件
CONF="/etc/nginx/modsec/crs-setup.conf"

# 参数检查
if [ -z "$1" ]; then
  echo "Usage: $0 {enable|disable|preview}"
  exit 1
fi

ACTION="$1"

# 检查配置文件是否存在
if [ ! -f "$CONF" ]; then
  echo "❌ 配置文件不存在: $CONF"
  exit 1
fi

# 自动备份
BACKUP="$CONF.bak.$(date +%F_%H%M%S)"
cp "$CONF" "$BACKUP"
echo "💾 已备份配置文件到 $BACKUP"

# 拉取 GitHub 脚本并执行
echo "🌐 从 GitHub 拉取脚本并执行 [$ACTION]..."
curl -sSL "$SCRIPT_URL" | sh -s -- "$ACTION"

echo "✅ 完成。请确认 nginx 已重载，如有必要可执行: nginx -t && nginx -s reload"
