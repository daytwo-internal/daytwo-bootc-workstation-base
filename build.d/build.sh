#!/usr/bin/env bash
set -euxo pipefail

BUILD_D="$(dirname "$(realpath "$0")")"

for script in "${BUILD_D}"/[0-9]*.sh; do
    printf "::group:: ===%s===\n" "$(basename "$script")"
    bash "$script"
    printf "::endgroup::\n"
done

printf "::group:: ===cleanup===\n"
bash "${BUILD_D}/cleanup.sh"
printf "::endgroup::\n"
