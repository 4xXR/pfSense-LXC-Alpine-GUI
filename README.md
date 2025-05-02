# pfSense GUI Access via Alpine LXC Container (Proxmox)

This project documents how to access the pfSense web GUI through a lightweight Alpine Linux LXC container using X11 Forwarding. Designed for home labs, Proxmox users looking for a minimal solution without relying on a full VM.

---

## 🎯 Objectives

* Deploy an **Alpine Linux container** with:

  * 512MB RAM
  * 1 vCPU
  * 2GB disk
* Access pfSense GUI using a **lightweight browser (Falkon)** via **X11 Forwarding**
* Avoid installing a full desktop environment or using VMs
* Improve security by running as a non-root user
* Optimize resource usage for lab environments

---

## 🧰 Tools & Technologies

* **Proxmox VE**
* **Alpine Linux**
* **Openbox** window manager
* **Falkon** browser (QtWebEngine-based)
* **X11 Forwarding** via SSH
* Optional: `xauth`, `xcb-util-cursor`, `mesa`, etc.

---

## 📖 Documentation

All setup steps, troubleshooting, lessons learned, and scripts are documented in [`docs/guia-setup.md`](docs/guia-setup.md).

> Includes:
>
> * Container creation and config
> * Package installation
> * SSH X11 setup
> * Running Falkon as non-root
> * Installing fonts to fix text rendering
> * Common errors and fixes

---

## 📦 Scripts

Located in [`scripts/`](scripts/), e.g.:

* `start-browser.sh` – Simplifies launching the GUI session inside the container

---

## 🖼️ Screenshots

### [`screenshots/screenshot_1.png`](screenshots/screenshot_1.png)

> **Description**: Falkon browser running inside the Alpine LXC container, successfully displaying the pfSense login page. The image shows that basic rendering and network reachability are functioning.

### [`screenshots/screenshot_2.png`](screenshots/screenshot_2.png)

> **Description**: pfSense dashboard interface accessed through Falkon inside the Alpine container. This confirms full GUI functionality and the ability to manage pfSense remotely via a lightweight browser setup.
---

## 🚀 Quick Start (from within container)

Once set up, log in as the non-root user and run:

```bash
./start-browser.sh
```

This will launch `openbox` and the `falkon` browser (with `--no-sandbox`) over X11 Forwarding.

---

## 📌 Notes

This project is not meant for production use. It is a functional, secure, low-resource home lab solution for managing pfSense when access to a full browser or desktop is not desired on the host.

Falkon works but may not render complex pages efficiently and can feel sluggish under X11 Forwarding. If needed, increase the container’s RAM to **1GB** for better performance.

---

## 🤝 Contributions

Feel free to open an issue or fork the repo to suggest improvements like:

* VNC/X2Go variants for better performance
* Lightweight VM version using XFCE or LXDE
* Pre-built LXC templates for quick deployment

