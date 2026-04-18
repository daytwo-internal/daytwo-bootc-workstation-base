# RHEL 10 bootc Workstation Base Image
FROM registry.redhat.io/rhel10/rhel-bootc@sha256:e983235c2f531901c990c81b9d121663fa3b6db156e7b074c11eb812edba8fce

LABEL org.opencontainers.image.title="DayTwo RHEL 10 Bootc Workstation Base" \
      org.opencontainers.image.description="Shared base image for DayTwo DevOps team workstations" \
      org.opencontainers.image.vendor="DayTwo" \
      org.opencontainers.image.source="https://github.com/daytwo-internal/rhel10-bootc-workstation-base"

# Register with RHSM using build-time secrets.
# The activation_key and org_id files are mounted via `podman build --secret`
RUN --mount=type=secret,id=activation_key \
    --mount=type=secret,id=org_id \
    subscription-manager register \
        --activationkey="$(cat /run/secrets/activation_key)" \
        --org="$(cat /run/secrets/org_id)" && \
    subscription-manager repos \
        --enable=rhel-10-for-x86_64-baseos-rpms \
        --enable=rhel-10-for-x86_64-appstream-rpms \
        --enable=codeready-builder-for-rhel-10-x86_64-rpms

# RHEL 10
RUN dnf -y update && \
    dnf -y groupinstall Workstation && \
    dnf -y install \
        ansible-core \
        bootc \
        buildah \
        cockpit \
        cockpit-machines \
        cockpit-podman \
        cockpit-storaged \
        curl \
        dnf-plugins-core \
        gnome-extensions-app \
        gnome-shell-extension-dash-to-dock \
        edk2-ovmf \
        flatpak \
        git \
        git-lfs \
        iproute \
        jq \
        libvirt \
        libvirt-client \
        podman \
        qemu-kvm \
        rsync \
        skopeo \
        tmux \
        toolbox \
        tree \
        unzip \
        virt-install \
        virt-manager \
        vim-enhanced \
        wget \
        zsh \
        zstd

# EPEL
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm && \
    dnf -y install \
        bat \
        borgbackup \
        btop \
        fd-find \
        fzf \
        gh \
        htop \
        just \
        ncdu \
        restic \
        rclone \
        ripgrep \
        tldr

# Third-party software
COPY etc/yum.repos.d/ /etc/yum.repos.d/

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    rpm --import https://dl.google.com/linux/linux_signing_key.pub && \
    rpm --import https://rpm.releases.hashicorp.com/gpg && \
    rpm --import 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg'

RUN dnf -y install \
        code \
        google-chrome-stable \
        terraform \
        zerotier-one

# mise
RUN dnf -y copr enable jdxcode/mise && \
    dnf -y install mise

# Starship
RUN dnf -y copr enable atim/starship && \
    dnf -y install starship

RUN dnf -y copr enable che/nerd-fonts && \
    dnf -y install nerd-fonts

#  Icons for GNOME
RUN for size in 16 24 32 48 64 128 256; do \
        mkdir -p /usr/share/icons/hicolor/${size}x${size}/apps && \
        ln -sf /opt/google/chrome/product_logo_${size}.png \
               /usr/share/icons/hicolor/${size}x${size}/apps/google-chrome.png ; \
    done && \
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true

# OpenShift CLI
ARG OC_VERSION=4.20
RUN curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OC_VERSION}/openshift-client-linux.tar.gz" \
        -o /tmp/oc.tar.gz && \
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin/ oc kubectl && \
    chmod +x /usr/local/bin/oc /usr/local/bin/kubectl && \
    rm -f /tmp/oc.tar.gz

# System configuration
COPY etc/ /etc/
COPY systemd/ /etc/systemd/system/

# Enable services:
RUN systemctl enable \
        cockpit.socket \
        libvirtd.socket \
        zerotier-one.service \
        && \
    systemctl set-default graphical.target

# Unregister from RHSM and clean up
RUN subscription-manager unregister || true && \
    subscription-manager clean && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/ldconfig/* /var/log/*.log \
           /var/log/dnf* /var/log/hawkey.log /var/log/yum* \
           /tmp/* /var/tmp/* && \
    bootc container lint
