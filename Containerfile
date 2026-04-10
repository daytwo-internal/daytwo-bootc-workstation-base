# DayTwo RHEL 10 Bootc Workstation — Base Image
#
# This image is the shared base for the DayTwo DevOps team workstations.
# Personal customizations live in derivative images that do FROM this one.
#
# See README.md for build, push, and consumption instructions.

# Base image: pinned by digest for reproducibility.
# Renovate updates this automatically when upstream publishes a new digest.
FROM registry.redhat.io/rhel10/rhel-bootc@sha256:e81f6b7e6dd197d3f2a82c88cbde40e76942611dd09985f9840802b5abb09ae3

LABEL org.opencontainers.image.title="DayTwo RHEL 10 Bootc Workstation Base" \
      org.opencontainers.image.description="Shared base image for DayTwo DevOps team workstations" \
      org.opencontainers.image.vendor="DayTwo" \
      org.opencontainers.image.source="https://github.com/daytwo-internal/rhel10-bootc-workstation-base"

# ──────────────────────────────────────────────────────────────────────────────
# 1. Register with RHSM using build-time secrets (never persisted in layers)
# ──────────────────────────────────────────────────────────────────────────────
# The activation_key and org_id files are mounted via `podman build --secret`
# and are only visible during the RUN that mounts them. They never end up in
# the image layers.
#
# We register, install everything we need, then unregister + clean up in the
# final RUN of this section.

RUN --mount=type=secret,id=activation_key \
    --mount=type=secret,id=org_id \
    subscription-manager register \
        --activationkey="$(cat /run/secrets/activation_key)" \
        --org="$(cat /run/secrets/org_id)" && \
    subscription-manager repos \
        --enable=rhel-10-for-x86_64-baseos-rpms \
        --enable=rhel-10-for-x86_64-appstream-rpms \
        --enable=codeready-builder-for-rhel-10-x86_64-rpms

# ──────────────────────────────────────────────────────────────────────────────
# 2. Third-party repos (VS Code, Google Chrome, HashiCorp)
# ──────────────────────────────────────────────────────────────────────────────
COPY etc/yum.repos.d/ /etc/yum.repos.d/

# Import GPG keys for the third-party repos
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    rpm --import https://dl.google.com/linux/linux_signing_key.pub && \
    rpm --import https://rpm.releases.hashicorp.com/gpg

# ──────────────────────────────────────────────────────────────────────────────
# 3. Optional: bundled RPMs (currently empty for DayTwo — we don't have
#    internal-only RPMs to ship). Kept for future use; the COPY+install is
#    a no-op when the directory only contains the .gitkeep file.
# ──────────────────────────────────────────────────────────────────────────────
COPY rpms/ /tmp/rpms/

# ──────────────────────────────────────────────────────────────────────────────
# 4. Install everything
# ──────────────────────────────────────────────────────────────────────────────
# Strategy:
#   - @Workstation gives us a working GNOME desktop
#   - DevOps toolchain explicit (oc, helm, ansible, podman, libvirt, ...)
#   - Editors and browsers from third-party repos
#   - --nodocs to keep the image lean

RUN dnf -y groupinstall --nodocs Workstation && \
    dnf -y update --nodocs && \
    dnf -y install --nodocs \
        # Core CLI / shell
        git git-lfs tmux zsh vim-enhanced jq tree bind-utils \
        wget curl rsync unzip \
        # Container / k8s tooling
        podman buildah skopeo bootc \
        # Virtualization (libvirt + virt-manager UI)
        qemu-kvm libvirt libvirt-client virt-install virt-manager \
        edk2-ovmf \
        # Networking utilities
        nmap tcpdump wireshark traceroute mtr nftables iproute \
        NetworkManager-tui \
        # Languages & dev tooling
        python3 python3-pip \
        nodejs golang rust cargo make gcc gcc-c++ \
        # Ansible
        ansible-core \
        # Cockpit for local + remote system mgmt
        cockpit cockpit-machines cockpit-podman cockpit-storaged \
        # Editors and browsers (third-party repos)
        code google-chrome-stable \
        # HashiCorp
        terraform \
        && \
    # Bundled RPMs (no-op if rpms/ is empty)
    bash -c 'shopt -s nullglob; rpms=(/tmp/rpms/*.rpm); if [ ${#rpms[@]} -gt 0 ]; then dnf -y install --nodocs --nogpgcheck "${rpms[@]}"; fi' && \
    rm -rf /tmp/rpms

# ──────────────────────────────────────────────────────────────────────────────
# 5. Install OpenShift CLI (oc + kubectl) — pinned version
# ──────────────────────────────────────────────────────────────────────────────
ARG OC_VERSION=4.20
RUN curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OC_VERSION}/openshift-client-linux.tar.gz" \
        -o /tmp/oc.tar.gz && \
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin/ oc kubectl && \
    chmod +x /usr/local/bin/oc /usr/local/bin/kubectl && \
    rm -f /tmp/oc.tar.gz

# ──────────────────────────────────────────────────────────────────────────────
# 6. Install Helm — pinned version
# ──────────────────────────────────────────────────────────────────────────────
ARG HELM_VERSION=v3.16.3
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
        -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp linux-amd64/helm && \
    install -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

# ──────────────────────────────────────────────────────────────────────────────
# 7. System configuration (drop-in files for the team)
# ──────────────────────────────────────────────────────────────────────────────
COPY etc/ /etc/
COPY systemd/ /etc/systemd/system/

# Enable services that should start on every team workstation
RUN systemctl enable libvirtd.socket cockpit.socket && \
    systemctl set-default graphical.target

# ──────────────────────────────────────────────────────────────────────────────
# 8. Unregister from RHSM and clean up before sealing the image
# ──────────────────────────────────────────────────────────────────────────────
RUN subscription-manager unregister || true && \
    subscription-manager clean && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/ldconfig/* /var/log/*.log \
           /var/log/dnf* /var/log/hawkey.log /var/log/yum* \
           /tmp/* /var/tmp/* && \
    # bootc lint sanity check — ensures the image is valid as a bootc target
    bootc container lint
