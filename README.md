# DayTwo RHEL 10 bootc workstation (base image)

Shared bootc OCI image for DayTwo DevOps workstations, built on top of `registry.redhat.io/rhel10/rhel-bootc`.

Published to `quay.io/daytwo/rhel10-bootc-workstation` (tags: `latest`, `YYYYMMDD`, short SHA).

## What's included

- GNOME Workstation + Dash to Dock
- Container tools: Podman, Buildah, Skopeo, Toolbx
- Virtualization: libvirt, QEMU, virt-manager, Cockpit
- Kubernetes: `oc`, `kubectl`
- Dev tools: `git`, `zsh`, `tmux`, `fzf`, `ripgrep`, `fd`, `bat`, `gh`, `mise`, Starship
- Cloud: Terraform, ZeroTier
- Editors: VS Code, Vim, NeoVim
- Browsers: Google Chrome
- Backups: borgbackup, restic, rclone

## Repository layout

```
Containerfile          Image definition
build.d/               Build scripts (run in lexical order by build.sh)
rootfs/                Files overlaid onto / at build time
  etc/
    yum.repos.d/       Third-party repo definitions
    rpm-ostreed.conf
  usr/lib/systemd/system/
.github/workflows/     CI: build, weekly rebuild, Renovate
```

## Build locally

```bash
printf '%s' 'YOUR_ACTIVATION_KEY' > activation_key.txt
printf '%s' 'YOUR_ORG_ID'         > org_id.txt

podman build \
  --secret id=activation_key,src=activation_key.txt \
  --secret id=org_id,src=org_id.txt \
  -t quay.io/daytwo/rhel10-bootc-workstation:local \
  .

shred -u activation_key.txt org_id.txt 2>/dev/null || rm -f activation_key.txt org_id.txt
```

## Consuming this image

```dockerfile
FROM quay.io/daytwo/rhel10-bootc-workstation:latest
# personal or machine-specific layers only
```

## CI

- Builds on push to `main` when `Containerfile`, `rootfs/**`, or `build.d/**` change.
- Weekly rebuild every Monday at 06:00 UTC to pick up upstream package updates.
- Renovate keeps the base image digest and GitHub Actions versions current.
