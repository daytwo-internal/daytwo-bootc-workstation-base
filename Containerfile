# RHEL 10 bootc Workstation Base Image
FROM registry.redhat.io/rhel10/rhel-bootc@sha256:e983235c2f531901c990c81b9d121663fa3b6db156e7b074c11eb812edba8fce

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
