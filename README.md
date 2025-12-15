# wp-admin-arg-limit.sh

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
