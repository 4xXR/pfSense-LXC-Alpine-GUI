# pfSense GUI Access via Alpine LXC Container (Proxmox) - Full Setup Guide

## 🚀 Project Goal

To deploy a **minimal Alpine Linux LXC container** inside **Proxmox** to access the **pfSense web GUI** via a lightweight browser using **X11 Forwarding**, consuming very few resources and avoiding full desktop environments or virtual machines.

---

## 🔧 LXC Container Setup in Proxmox

### Step 1: Create the container

* Use Alpine 3.18 (or later) template in Proxmox
* Settings:

  * RAM: `512MB`
  * vCPU: `1`
  * Disk: `2GB`
  * Unprivileged container: **Yes**
  * Network: connect to the same bridge or VLAN as pfSense

### Step 2: Adjust container config in Proxmox

Before starting the container, edit its config file:

```bash
nano /etc/pve/lxc/101.conf
```

Add:

```ini
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: c 4:0 rwm
lxc.cgroup.devices.allow: c 4:1 rwm
lxc.cgroup.devices.allow: c 5:0 rwm
lxc.cgroup.devices.allow: c 5:1 rwm
lxc.cgroup.devices.allow: c 10:229 rwm
lxc.mount.entry: /dev/fuse dev/fuse none bind,create=file
```

Then start the container:

```bash
pct start 101
pct enter 101
```

---

## 🧰 Package Installation (inside container)

Log in to the container (e.g., via `pct enter 101` or SSH) and run:

```bash
apk update && apk upgrade
apk add xorg-server xf86-video-dummy openbox falkon xterm dbus mesa-dri-gallium mesa-gl mesa-egl xcb-util-cursor xauth openssh
```

* `falkon`: lightweight web browser
* `xorg-server` and `openbox`: minimal X environment
* `xauth`: required for X11 Forwarding to work
* `mesa`, `xcb`: required by Falkon/Qt
* `openssh`: to allow remote access via SSH

---

## 🔐 Enable SSH and X11 Forwarding (inside the Alpine container)

You need to configure the **SSH server inside the Alpine container** to allow X11 Forwarding. This enables the graphical application (Falkon) to be displayed on your local laptop through SSH.

Edit the SSH daemon configuration file:

```bash
vi /etc/ssh/sshd_config
```

Ensure the following lines are present and **not commented out**:

```ini
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
```

Save and restart the SSH server:

```bash
service sshd restart
```

If SSH isn't running, you can start it manually:

```bash
rc-update add sshd
service sshd start
```

---

## 👤 Create a non-root user (recommended)

Still inside the container, run:

```bash
adduser youruser
passwd youruser
```

Now edit `/etc/passwd` and make sure the shell is `/bin/ash` (not `/sbin/nologin`):

```text
youruser:x:1000:1000::/home/youruser:/bin/ash
```

Fix ownership of the home directory:

```bash
chown -R youruser:youruser /home/youruser
```

---

## 💻 Connect via SSH with X11 Forwarding from your laptop

From your **Linux laptop or computer with a graphical environment** and X11 enabled (e.g., using GNOME, KDE, or XFCE), connect to the container with:

```bash
ssh -X youruser@192.168.x.x
```

The `-X` flag enables X11 Forwarding, so graphical applications launched in the container will display on your local machine.

Test that the forwarding is active:

```bash
echo $DISPLAY
```

Expected output:

```
localhost:10.0
```

If this is empty, the forwarding failed (likely due to SSH config or `xauth` missing).

---

## 🧪 Run the browser from inside the container

### 🆕 Install fonts (to fix invisible text issue)

If you notice that text is not visible when typing in login forms or other fields inside Falkon, it's likely due to missing fonts. Alpine does not come with any fonts by default.

As root, install standard font packages:

```bash
apk add font-noto font-dejavu font-liberation ttf-freefont
```

This will ensure Falkon can render all UI and web content properly.

---

Once logged in as `youruser`, run:

```bash
openbox &
falkon --no-sandbox &
```

* `openbox` is a minimal window manager
* `--no-sandbox` is required because Chromium-based browsers don't allow root or unprivileged execution without it

---

## 🧰 Optional: Create a launcher script

The launcher script is designed to simplify the startup process every time you connect to the container. Instead of typing multiple commands to start the window manager (`openbox`) and the browser (`falkon`), this script checks whether the X11 environment is ready and whether Openbox is already running, then launches everything in order.

This is especially useful if you regularly manage pfSense from this container and want a quick, repeatable workflow with one command.

### `~/start-browser.sh`

```bash
#!/bin/sh

if [ -z "$DISPLAY" ]; then
  echo "❌ DISPLAY not set. Connect with ssh -X"
  exit 1
fi

if ! pgrep -x "openbox" > /dev/null; then
  echo "✅ Starting Openbox..."
  openbox &
  sleep 1
fi

echo "🚀 Launching Falkon..."
falkon --no-sandbox &
```

Make it executable:

```bash
chmod +x ~/start-browser.sh
```

Run with:

```bash
./start-browser.sh
```

---

## 🧯 Troubleshooting Summary

| Issue                                     | Solution                                                                                          |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `nano: not found`                         | Use `vi` or `apk add nano`                                                                        |
| SSH: "REMOTE HOST IDENTIFICATION CHANGED" | Run: `ssh-keygen -f ~/.ssh/known_hosts -R 192.168.x.x` on your laptop                             |
| `X11 forwarding request failed`           | Make sure `xauth` is installed (`apk add xauth`) and SSHD is configured properly in the container |
| `could not connect to display`            | Ensure `$DISPLAY` is set after connecting with `ssh -X`                                           |
| `Falkon sandbox error`                    | Use `falkon --no-sandbox` or switch to a non-root user                                            |

---

## 🎓 Lessons Learned

* Alpine is extremely lightweight, but needs manual configuration.
* X11 Forwarding is simple but **not ideal for performance**.
* Falkon is usable but requires `--no-sandbox` when run as root.
* Always prefer using a **non-root user** for GUI apps.
* For better performance, consider using **X2Go** or **VNC** instead of X11.

---

## ✅ Conclusion

With just 512MB RAM and 1 vCPU, we successfully launched a secure browser session from a lightweight Alpine LXC container to manage pfSense's web GUI. This setup is perfect for low-resource labs and minimal GUI access, without needing to run a full VM.

Overall, this was a very valuable and insightful experience. It demonstrated how far you can go with limited resources and good configuration. That said, if you notice that the browser performance is sluggish, it may help to increase the container's memory to **1GB**, especially when running Falkon, which relies on QtWebEngine (Chromium-based) and does not render complex pages very efficiently without acceleration.

For a smoother graphical experience, consider setting up VNC or X2Go in the same container, or spinning up a lightweight VM with XFCE or LXDE if resources allow. we successfully launched a secure browser session from a lightweight Alpine LXC container to manage pfSense's web GUI. This setup is perfect for low-resource labs and minimal GUI access, without needing to run a full VM.

For a smoother graphical experience, consider setting up VNC or X2Go in the same container, or spinning up a lightweight VM with XFCE or LXDE if resources allow.

