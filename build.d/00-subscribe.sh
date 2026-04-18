#!/usr/bin/env bash
set -eo pipefail

subscription-manager register \
    --activationkey="$(cat /run/secrets/activation_key)" \
    --org="$(cat /run/secrets/org_id)"

subscription-manager repos \
    --enable=rhel-10-for-x86_64-baseos-rpms \
    --enable=rhel-10-for-x86_64-appstream-rpms \
    --enable=codeready-builder-for-rhel-10-x86_64-rpms
