# GNOME 49 extensions pre-built by Bluefin LTS — avoids compiling TypeScript (Blur My Shell,
# Dash to Dock use `make`). Extensions are OS-agnostic JS + GSettings schemas.
FROM ghcr.io/ublue-os/bluefin:lts AS bluefin-gnome49

# RHEL 10 bootc Workstation Base Image
FROM registry.redhat.io/rhel10/rhel-bootc@sha256:3fb542abf4c8a65f4388cbd52db67497a4e6a87cb8060f9cc79c193457d1b1e4

LABEL org.opencontainers.image.title="DayTwo RHEL 10 Bootc Workstation Base" \
      org.opencontainers.image.description="Shared base image for DayTwo DevOps team workstations" \
      org.opencontainers.image.vendor="DayTwo" \
      org.opencontainers.image.source="https://github.com/daytwo-internal/rhel10-bootc-workstation-base"

ARG OC_VERSION=4.20
ARG NEOVIM_VERSION=0.11.2

COPY rootfs/ /
COPY build.d/ /tmp/build.d/

RUN --mount=type=secret,id=activation_key \
    --mount=type=secret,id=org_id \
    bash /tmp/build.d/build.sh && \
    rm -rf /tmp/build.d

# Copy GNOME 49 extensions from Bluefin LTS (pre-built, no source compilation needed)
RUN --mount=type=bind,from=bluefin-gnome49,source=/usr/share/gnome-shell/extensions,target=/tmp/bluefin-extensions \
    cp -av /tmp/bluefin-extensions/appindicatorsupport@rgcjonas.gmail.com /usr/share/gnome-shell/extensions/ && \
    cp -av /tmp/bluefin-extensions/blur-my-shell@aunetx                   /usr/share/gnome-shell/extensions/ && \
    cp -av /tmp/bluefin-extensions/caffeine@patapon.info                  /usr/share/gnome-shell/extensions/ && \
    cp -av /tmp/bluefin-extensions/dash-to-dock@micxgx.gmail.com          /usr/share/gnome-shell/extensions/
