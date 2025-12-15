# wp-admin-arg-limit.sh

使用:chmod +x /root/wp-admin-arg-limit-run.sh



🔐 WordPress 后台参数限制智能控制脚本  
（ModSecurity / OWASP CRS / 科技 Lion LDNMP 专用）

---

## 📖 背景说明（为什么需要这个脚本）

在启用 **ModSecurity + OWASP CRS** 的 Nginx 环境中，  
WordPress 后台常见以下问题：

- 保存菜单时报错 `400 Bad Request`
- Elementor 点击保存无反应
- WooCommerce 批量产品 / 大变体保存失败

Nginx 错误日志中通常能看到类似内容：

```text
ModSecurity: Access denied with code 400
[msg "Failed to fully parse request body due to large argument count"]
[id "200007"]

❗ 根本原因

OWASP CRS 默认规则：

当 POST / GET 参数数量 ≥ 1000 时 → 直接拦截


而 WordPress 后台在以下场景中 非常容易超过 1000 个参数：

大型菜单（nav-menus.php）

Elementor 容器 + 小组件

WooCommerce 复杂变体

🎯 本脚本解决了什么？

✅ 仅对 /wp-admin 放宽参数限制（5000）
✅ 前台仍保持 1000，不牺牲安全性
✅ 不关闭 ModSecurity，不移除 CRS
✅ 可随时一键恢复默认设置
✅ 支持删除前预览，避免误操作

⚙️ 工作原理（安全说明）

脚本通过在 CRS 配置中增加一段 精准规则：

# === WordPress admin tuning ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000101,\
  phase:1,\
  pass,\
  nolog,\
  setvar:tx.max_num_args=5000"
# === Allow large admin POST (menus / elementor) ===
SecRule REQUEST_URI "@beginsWith /wp-admin/" \
 "id:1000102,\
  phase:1,\
  pass,\
  nolog,\
  ctl:ruleRemoveById=200007"
