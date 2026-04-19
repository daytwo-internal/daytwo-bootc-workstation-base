#!/usr/bin/env bash
set -euxo pipefail

curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OC_VERSION}/openshift-client-linux.tar.gz" \
    -o /tmp/oc.tar.gz
tar -xzf /tmp/oc.tar.gz -C /usr/local/bin/ oc kubectl
chmod +x /usr/local/bin/oc /usr/local/bin/kubectl
rm -f /tmp/oc.tar.gz
