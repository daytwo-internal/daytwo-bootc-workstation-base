#!/usr/bin/env bash
set -euxo pipefail

curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
    -o /tmp/nvim.tar.gz
tar -xzf /tmp/nvim.tar.gz -C /usr/local/ --strip-components=1
rm -f /tmp/nvim.tar.gz
