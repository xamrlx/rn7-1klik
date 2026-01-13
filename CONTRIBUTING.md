# Contributing Guide

Thank you for considering contributing to RN7 1-Click Tool.

This project focuses on **SAFETY FIRST** for MIUI devices.
Please read this guide carefully before contributing.

---

## 🧠 Principles
- No uninstall of core system apps
- Disable-only approach is preferred
- Avoid changes that may cause bootloop
- Redmi / Xiaomi / POCO compatibility first

---

## 🛠️ How to Contribute

### 1. Fork the repository
Create your own fork on GitHub.

### 2. Create a new branch
```bash
git checkout -b feature/my-feature
```

### 3. Make your changes
- Follow existing bash style
- Comment risky commands clearly
- Test on real device if possible

### 4. Commit with clear message
```bash
git commit -m "Add: safe debloat for MIUI service X"
```

### 5. Open a Pull Request
Explain:
- What you changed
- Why it is safe
- Which device you tested

---

## 🚫 What NOT to do
- Do NOT add uninstall commands for system apps
- Do NOT touch SystemUI, SecurityCenter, or core framework
- Do NOT add root-only commands

---

## 🐞 Bug Reports
Please include:
- Device model
- MIUI version
- Android version
- Command output / error message

---

## 📜 License
By contributing, you agree that your contributions
will be licensed under the MIT License.
