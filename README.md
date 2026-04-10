# DayTwo RHEL 10 bootc workstation (base image)

Shared **bootc**-compatible OCI image for DayTwo DevOps workstations. It extends Red Hat’s RHEL 10 bootc base with a GNOME Workstation-style stack, container and Kubernetes tooling, virtualization, and team-wide configuration. **Personal or machine-specific customizations belong in a derivative image** that uses `FROM` this one.

Published image (CI): `quay.io/daytwo/rhel10-bootc-workstation` (tags: `latest`, date `YYYYMMDD`, and short Git SHA).

## What’s in the image

The [`Containerfile`](Containerfile) applies layers in this order (see the file for the exact package lists):

1. **RHSM (build only):** Register with an activation key, enable BaseOS, AppStream, and CodeReady Builder (CRB), then later unregister and scrub so secrets are not left in the final layers.
2. **RHEL + Workstation:** `dnf update`, `@Workstation`, then extra RPMs from Red Hat repos only — Ansible, Podman/Buildah/Skopeo, `bootc`, Cockpit (+ machines, podman, storaged), libvirt/QEMU/virt-manager, `flatpak`, `toolbox`, `dnf-plugins-core`, **`gnome-extensions-app`**, **`gnome-shell-extension-dash-to-dock`**, and common CLI tools (`git`, `zsh`, `tmux`, `jq`, …). **No EPEL** in this step.
3. **EPEL 10:** Install [`epel-release-latest-10`](https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm), then **only** EPEL packages (modern CLIs, backups, Git UX). EPEL is **community-maintained** and **not** covered by Red Hat product support; CRB stays enabled for dependencies.
4. **Repo files + keys:** `COPY etc/yum.repos.d/` (VS Code, Google Chrome, HashiCorp, ZeroTier), then `rpm --import` for Microsoft, Google, HashiCorp, and ZeroTier GPG keys.
5. **Signed third-party RPMs:** `code`, `google-chrome-stable`, `terraform`, `zerotier-one` via those repos.
6. **COPR:** [mise](https://mise.jdx.dev/) (`jdxcode/mise`), then [Ghostty](https://ghostty.org/) (`scottames/ghostty`, as in [upstream Linux install docs](https://ghostty.org/docs/install/binary)).
7. **Chrome on GNOME:** Symlinks so Chrome’s icons appear in the shell (read-only `/usr` on bootc).
8. **OpenShift client:** Pinned `oc` + `kubectl` tarball (`ARG OC_VERSION`). **Helm is not installed in the base image** — use **mise** (e.g. `mise install helm`) or a derivative layer if the team standardizes a version.
9. **Config:** `COPY etc/` (including `rpm-ostreed.conf`) and `systemd/`.
10. **Services enabled:** `cockpit.socket`, `libvirtd.socket`, `zerotier-one.service`, graphical target.
11. **Seal:** RHSM cleanup, `dnf clean all`, **`bootc container lint`**.

### Highlights (not a full package list)

- **Desktop:** GNOME Workstation plus **Dash to Dock** from RPM (`gnome-shell-extension-dash-to-dock`); **`gnome-extensions-app`** for managing extensions.
- **Networking / VPN:** **ZeroTier** (`zerotier-one`) from [`etc/yum.repos.d/zerotier.repo`](etc/yum.repos.d/zerotier.repo) → [`download.zerotier.com`](https://download.zerotier.com/) **el/9** (upstream has not published **el/10** yet; RHEL 10 uses these builds). Join after boot: `sudo zerotier-cli join <network_id>`.
- **Terraform:** HashiCorp repo via [`etc/yum.repos.d/hashicorp.repo`](etc/yum.repos.d/hashicorp.repo) (currently **`RHEL/9`** `baseurl`; adjust when you standardize on el10 paths).
- **Backups (EPEL):** `borgbackup`, `restic`, `rclone`; **`rsync`** on the host. **Deja Dup** is not an RPM here — use Flathub: `flatpak install flathub org.gnome.DejaDup` after adding Flathub.
- **Git / terminal UX (EPEL):** `gh`, plus tools in the **LinuxTeck** table below. **`lazygit`** is not baked in — `mise install lazygit` (or `mise use -g lazygit@…`).
- **Not on the host:** Heavy network capture/scan tools (e.g. Wireshark, `nmap`, `tcpdump`) — use Toolbx. **Compilers** — use mise, Toolbx, or pet containers.

### LinuxTeck-style tools → RPM names (RHEL 10 + EPEL)

The [LinuxTeck “modern Linux tools”](https://www.linuxteck.com/modern-linux-tools/) article uses distro-agnostic install names. On this image:

| Article / usual name | RPM package | Binary notes |
|----------------------|-------------|--------------|
| bat | `bat` | `bat` |
| ripgrep (`rg`) | `ripgrep` | `rg` |
| fd | **`fd-find`** | **`fd`** (not Debian’s `fdfind`) |
| tldr | `tldr` | `tldr` |
| btop | `btop` | `btop` |
| fzf | `fzf` | `fzf` |
| zoxide | — | **`mise install zoxide`** (or add when EPEL ships it). |
| dust | — | **`mise install dust`** or use **`ncdu`**. |

Shell aliases from the article are **not** set globally; use dotfiles or a derivative.

### mise (not Homebrew, not asdf in base)

- **RPM** from [COPR `jdxcode/mise`](https://copr.fedorainfracloud.org/coprs/jdxcode/mise/) (`dnf copr enable jdxcode/mise` then `dnf install mise`).
- Examples: `mise use -g node@22`, `mise install golang@1.24`, `mise install lazygit`, `mise install helm`.

### Flatpak (Zoom and other apps)

The image includes **`flatpak`**. **Flathub is not pre-enabled**; add it when policy allows:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub us.zoom.Zoom
```

## Repository layout

| Path | Role |
|------|------|
| `Containerfile` | Image definition (layer order above) |
| `etc/yum.repos.d/` | VS Code, Chrome, HashiCorp, ZeroTier repo snippets |
| `etc/rpm-ostreed.conf` | rpm-ostree settings copied into the image |
| `systemd/` | Optional unit drop-ins for the team |
| `.github/workflows/` | Build, weekly rebuild, Renovate |

## Build locally (Podman)

- Logged into `registry.redhat.io` (pull the base image).
- RHSM activation key + org ID as build secrets (same as CI).

```bash
printf '%s' 'YOUR_ACTIVATION_KEY' > activation_key.txt
printf '%s' 'YOUR_ORG_ID' > org_id.txt

podman build \
  --secret id=activation_key,src=activation_key.txt \
  --secret id=org_id,src=org_id.txt \
  -t quay.io/daytwo/rhel10-bootc-workstation:local \
  .

shred -u activation_key.txt org_id.txt 2>/dev/null || rm -f activation_key.txt org_id.txt
```

Do not commit secret files; they are in `.gitignore`.

## CI/CD (GitHub Actions)

- **Build and push** (`.github/workflows/build.yml`): on pushes to `main` when `Containerfile`, `etc/**`, `systemd/**`, or `rpms/**` change; also `workflow_dispatch` and `workflow_call`.
- **Weekly rebuild** (`.github/workflows/weekly-rebuild.yml`): Mondays 06:00 UTC.
- **Renovate** (`.github/workflows/renovate.yml` + `.github/renovate.json`): digest and Actions updates.

### Secrets used in CI

| Secret | Purpose |
|--------|---------|
| `REGISTRY_REDHAT_IO_USER` / `REGISTRY_REDHAT_IO_PASSWORD` | Pull from `registry.redhat.io` |
| `RHSM_ACTIVATION_KEY` / `RHSM_ORG_ID` | Register during image build |
| `QUAY_USER` / `QUAY_PASSWORD` | Push to Quay |
| `RENOVATE_TOKEN` | PAT so Renovate PRs trigger workflows |
| `DERIVATIVE_DISPATCH_TOKEN` | Optional: cascade rebuilds to derivative repos |

## Consuming this image

```dockerfile
FROM quay.io/daytwo/rhel10-bootc-workstation:latest
# … team-approved or personal layers only …
```

For **bare metal / VM**, use bootc’s documented flow (`bootc install to-disk`, OCI image or archive, kargs, disks, SSH bootstrap as appropriate).

## Maintenance

- Prefer changing this base; keep derivatives thin.
- Edit `Containerfile`, `etc/`, or `systemd/` and merge to `main` to rebuild (or run the workflow manually).
- **`bootc container lint`** runs at the end of the `Containerfile`.

### More packages (ideas)

Search **EPEL 10** or use **mise** before adding new `curl | tar` layers. Examples: `dive`, `hyperfine`, `sd`.
