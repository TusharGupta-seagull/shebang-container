
# shebang-con

**shebang-con** is a lightweight, Docker-inspired container runtime built on bash using core Linux features like `btrfs`, `cgroups`, `namespaces`, and `chroot`. It uses a Bash-based CLI to manage images and containers and supports pulling images directly from Docker Hub using the v2 API.

---

## ⚙️ Features

- Pull images from Docker Hub (v2 API) without Docker runtime.
- Create images from local directories or Docker layers.
- Run containers in isolated environments with:
  - Network namespaces and virtual Ethernet pairs
  - cgroups for CPU and memory limits
  - `file-system`, `process`, `network`, `hostname`, `IPC` isolation
- Execute commands inside running containers
- Export logs, list images/containers, and manage container lifecycle
- Minimal dependencies, Bash-native

---

## 💻 Environment Setup

This project uses **Vagrant + VirtualBox** to create a CentOS 7 virtual machine preconfigured with everything needed to run `shebang-con`.

### 📂 Project Structure

```
.
├── Vagrantfile
├── bootstrap.sh
├── shebang-con         # Main shebang-con script
└── README.md
```

---

## Quick Start

### 1. Start the VM

```bash
vagrant up
```

This will:
- Launch a CentOS 7 VM using the `boxomatic/centos-7` image.
- Run `bootstrap.sh` to provision required tools, Btrfs, networking, etc.
- Mount your working directory to `/vagrant` inside the VM.
- Link `shebang-con` to `/usr/bin`.

### 2. SSH into the VM

```bash
vagrant ssh
```

---

## Commands

Use the `shebang-con` CLI to manage images and containers:

### 💿 Image Commands

```bash
shebang-con init <directory>             # Create an image from a directory
shebang-con pull <name> <tag>            # Pull image from Docker Hub
shebang-con images                       # List all images
shebang-con rm <image_id>/<container_id> # Delete image or container
```

### 📦 Container Commands

```bash
shebang-con run <image_id> <cmd>         # Run container from image
shebang-con run -it <image_id>           # Run container in interactive mode
shebang-con ps                           # List running/stopped containers
shebang-con exec <container_id> <cmd>    # Execute command in container
shebang-con logs <container_id>          # View container logs
shebang-con commit <cont_id> <img_id>    # Commit container state to image
```

---

## 🔌 Networking

The runtime uses a `bridge0` interface with static IP allocation (`10.0.0.0/24`). If `bridge0` is not found, it will be created during provisioning.

NAT is configured with:

```bash
iptables -t nat -A POSTROUTING -o bridge0 -j MASQUERADE
```

---

## 📂 Storage

- All images and containers are stored as **btrfs subvolumes** in `/var/shebang-con`.
- A 10GB loopback file (`/root/btrfs.img`) is mounted there and configured via `/etc/fstab`.

---

## 🧪 Example

```bash
# Pull and run Alpine Linux
shebang-con pull alpine latest
shebang-con images

# Run an interactive shell
shebang-con run -it img_XXXXX 

# List containers
shebang-con ps

# View logs
shebang-con logs cont_XXXXX

# Deleting an image
shebang-con rm img_XXXXX
```

---

## 🔧 Requirements (installed via bootstrap.sh script)

Inside the VM:
- Btrfs mount file-system (`btrfs-progs`)
- cgroups tools
- bridge networking setup
- Docker image extraction tool: `undocker`
- jq for parsing json data
- Python3 

---

