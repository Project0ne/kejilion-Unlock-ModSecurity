cat << 'EOF' > /root/fix-wp-admin-400.sh
#!/bin/sh

CONF="/etc/nginx/modsec/crs-setup.conf"

echo "🔍 Checking CRS config: $CONF"

if [ ! -f "$CONF" ]; then
  echo "❌ File not found: $CONF"
  exit 1
fi

# Rule 1: increase max args for wp-admin
if ! grep -q "tx.max_num_args=5000" "$CONF"; then
  echo "➕ Adding wp-admin max_num_args=5000"
  cat << 'EOR' >> "$CONF"

# === WordPress admin tuning ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000101,\
  phase:1,\
  pass,\
  nolog,\
  setvar:tx.max_num_args=5000"
EOR
else
  echo "✔ max_num_args rule already exists"
fi

# Rule 2: remove ModSecurity core limit (200007) for wp-admin
if ! grep -q "ruleRemoveById=200007" "$CONF"; then
  echo "➕ Allowing large admin POST (remove rule 200007)"
  cat << 'EOR' >> "$CONF"

# === Allow large admin POST (menus / elementor) ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000102,\
  phase:1,\
  pass,\
  nolog,\
  ctl:ruleRemoveById=200007"
EOR
else
  echo "✔ ruleRemoveById=200007 already exists"
fi

echo "🔄 Reloading Nginx..."
nginx -t && nginx -s reload

echo "✅ Done. WordPress admin POST limit fixed."
EOF
