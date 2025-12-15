cat << 'EOF' > /root/wp-admin-arg-limit.sh
#!/bin/sh

CONF="/etc/nginx/modsec/crs-setup.conf"

ENABLE_RULE_1="tx.max_num_args=5000"
ENABLE_RULE_2="ruleRemoveById=200007"

echo "========================================"
echo " WordPress wp-admin 参数限制控制脚本"
echo "========================================"
echo "1) 解除 wp-admin 参数限制（推荐）"
echo "2) 恢复原本安全设置（回滚）"
echo "0) 退出"
echo "----------------------------------------"
printf "请输入选项 [0-2]: "
read CHOICE

if [ ! -f "$CONF" ]; then
  echo "❌ 配置文件不存在: $CONF"
  exit 1
fi

case "$CHOICE" in
  1)
    echo "🔓 开始解除 wp-admin 参数限制..."

    if ! grep -q "$ENABLE_RULE_1" "$CONF"; then
      cat << 'EOR' >> "$CONF"

# === WordPress admin tuning ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000101,\
  phase:1,\
  pass,\
  nolog,\
  setvar:tx.max_num_args=5000"
EOR
      echo "✔ 已添加 max_num_args=5000"
    else
      echo "✔ max_num_args 规则已存在"
    fi

    if ! grep -q "$ENABLE_RULE_2" "$CONF"; then
      cat << 'EOR' >> "$CONF"

# === Allow large admin POST (menus / elementor) ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000102,\
  phase:1,\
  pass,\
  nolog,\
  ctl:ruleRemoveById=200007"
EOR
      echo "✔ 已放行规则 200007"
    else
      echo "✔ 200007 放行规则已存在"
    fi

    nginx -t && nginx -s reload
    echo "✅ wp-admin 参数限制已解除"
    ;;

  2)
    echo "🔒 正在恢复原本安全设置..."

    sed -i '/WordPress admin tuning/,+6d' "$CONF"
    sed -i '/Allow large admin POST/,+6d' "$CONF"

    nginx -t && nginx -s reload
    echo "✅ 已恢复默认参数限制（1000）"
    ;;

  0)
    echo "👋 已退出"
    exit 0
    ;;

  *)
    echo "❌ 无效选项"
    exit 1
    ;;
esac
EOF
