# Troubleshooting

This guide helps fix common issues when using RN7 1-Click Tool
with Termux + Shizuku.

---

## ❌ rish: command not found
**Cause**
- rish not installed
- PATH not refreshed

**Fix**
```bash
command -v rish
```
If empty, reinstall rish from Shizuku export.

---

## ❌ RISH_APPLICATION_ID is not set
**Fix**
```bash
export RISH_APPLICATION_ID=com.termux
```
To make permanent:
```bash
echo 'export RISH_APPLICATION_ID=com.termux' >> ~/.profile
```

---

## ❌ Request timeout / cannot connect to Shizuku
**Cause**
- Shizuku not running
- Battery restriction
- Autostart disabled

**Fix**
- Shizuku status must be RUNNING
- Battery: No restrictions
- Autostart: ON for Termux & Shizuku

---

## ❌ Shizuku stops working after reboot
**Fix**
- Restart Shizuku via Wireless Debugging or ADB
- Reopen Termux and retry

---

## ⚠️ Features missing after debloat
**Fix**
- Use menu: Restore
- Or enable manually:
```bash
rish -c "pm enable <package_name>"
```

---

## 📊 Check performance
```bash
rish -c "top -o RES,CPU,ARGS -s 10"
```

---

## ℹ️ Notes
- Some MIUI versions hide advanced settings
- Behavior may vary between devices
- Always use SAFE mode first
