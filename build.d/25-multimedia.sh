#!/usr/bin/env bash
set -eo pipefail

dnf -y --nodocs install --enablerepo=epel-multimedia \
    ffmpeg \
    libavcodec \
    @multimedia \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-libs \
    gstreamer1-plugins-good \
    gstreamer1-plugins-base \
    lame \
    lame-libs \
    libjxl \
    ffmpegthumbnailer
