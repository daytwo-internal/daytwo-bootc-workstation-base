# DayTwo RHEL 10 bootc workstation (base image)

Shared bootc OCI image for DayTwo DevOps workstations, built on top of `registry.redhat.io/rhel10/rhel-bootc`.

Published to **`ghcr.io/daytwo-internal/daytwo-bootc-workstation-base`** — private, GHCR-hosted.

> **This image derives from a RHEL bootc base and must stay private.** Never
> change the GHCR package visibility to public; redistributing RHEL content
> requires a valid Red Hat subscription on the consuming side, which a public
> pull would bypass.

## Channels

| Tag | Meaning |
| --- | --- |
| `<short-sha>` | Every build on `main`, tagged with the 7-char commit SHA. |
| `<YYYYMMDD>-<short-sha>` | Dated build tag. The SHA suffix means two builds on the same day never overwrite each other. |
| `testing` | Always points at the latest build from `main`. Moves automatically on every push/weekly rebuild. |
| `stable` | Moves **only** via the manual [`promote-stable.yml`](.github/workflows/promote-stable.yml) workflow, which promotes one already-signed digest. Nothing else in CI is allowed to touch this tag. |

There is no `latest` tag. Pin to `stable`, `testing`, or a specific digest/SHA tag.

## What's included

- GNOME Workstation + Dash to Dock
- Container tools: Podman, Buildah, Skopeo, Toolbx
- Virtualization: libvirt, QEMU, virt-manager, Cockpit
- Kubernetes: `oc`, `kubectl`
- Dev tools: `git`, `zsh`, `tmux`, `fzf`, `ripgrep`, `fd`, `bat`, `gh`, `mise`, Starship
- Cloud: Terraform, ZeroTier
- Editors: VS Code, Vim, NeoVim
- Browsers: Google Chrome
- Backups: borgbackup, restic, rclone

## Repository layout

```
Containerfile          Image definition
build.d/               Build scripts (run in lexical order by build.sh)
rootfs/                Files overlaid onto / at build time
  etc/
    yum.repos.d/       Third-party repo definitions
    rpm-ostreed.conf
  usr/lib/systemd/system/
.github/workflows/     CI: build+publish+sign, weekly rebuild, PR validation, stable promotion, Renovate
```

## Build locally

```bash
printf '%s' 'YOUR_ACTIVATION_KEY' > activation_key.txt
printf '%s' 'YOUR_ORG_ID'         > org_id.txt

podman build \
  --secret id=activation_key,src=activation_key.txt \
  --secret id=org_id,src=org_id.txt \
  -t ghcr.io/daytwo-internal/daytwo-bootc-workstation-base:local \
  .

shred -u activation_key.txt org_id.txt 2>/dev/null || rm -f activation_key.txt org_id.txt
```

## Authenticating a workstation to GHCR

Consuming this image (via `bootc switch`, `podman pull`, or as a derivative
`FROM`) requires a **read-only** token, since the package is private.

1. Ask a repo owner for a GitHub [fine-grained personal access
   token](https://github.com/settings/tokens?type=beta) scoped to:
   - Repository access: `daytwo-internal/daytwo-bootc-workstation-base` only
   - Permissions: **Contents: Read-only** and **Packages: Read-only**
   - No write scopes.
2. Log in with it:

   ```bash
   echo "$GHCR_READ_TOKEN" | sudo podman login ghcr.io \
     -u '<your-github-username>' --password-stdin
   ```

   Use `sudo podman login` (root's auth file) if bootc will pull as root at
   boot; a plain `podman login` only authenticates your own user.

## Configuring bootc to pull a private image

`bootc` reads registry credentials from **`/etc/ostree/auth.json`** for
private registries — a separate file from your user-level `podman login`
(see [bootc: private registries](https://github.com/containers/bootc/blob/main/docs/src/registries-and-offline.md#private-registries)).
Populate it before switching:

```bash
echo "$GHCR_READ_TOKEN" | sudo podman login ghcr.io \
  -u '<your-github-username>' \
  --authfile /etc/ostree/auth.json \
  --password-stdin

sudo bootc switch ghcr.io/daytwo-internal/daytwo-bootc-workstation-base:stable
```

If `bootc switch`/`upgrade` reports an authentication error, confirm
`/etc/ostree/auth.json` exists and contains a `ghcr.io` entry.

## Verifying the Cosign signature

Every published digest is signed keylessly with [Cosign](https://docs.sigstore.dev/)
via GitHub Actions OIDC — no static signing key exists. Verify before trusting
an image:

```bash
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/daytwo-internal/daytwo-bootc-workstation-base/' \
  ghcr.io/daytwo-internal/daytwo-bootc-workstation-base@sha256:<digest>
```

A signature that fails to verify, or an image with no signature, must not be
deployed.

Build provenance is a GitHub
[artifact attestation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds)
for the same digest; verify it with `gh` (requires `gh auth login` and, for
`oci://`, being logged in to the registry the artifact came from):

```bash
gh attestation verify \
  oci://ghcr.io/daytwo-internal/daytwo-bootc-workstation-base@sha256:<digest> \
  --owner daytwo-internal
```

The SBOM is pushed straight to the registry via `cosign attest` instead —
this image's SBOM regularly exceeds the 16MB size cap on GitHub's own
attestation API, so it isn't in the `gh attestation` list. Verify it with
Cosign, same identity as the signature:

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/daytwo-internal/daytwo-bootc-workstation-base/' \
  ghcr.io/daytwo-internal/daytwo-bootc-workstation-base@sha256:<digest>
```

## CI

- **build.yml** — builds on push to `main` when `Containerfile`, `rootfs/**`,
  or `build.d/**` change. Pushes `<short-sha>` and dated tags, moves
  `testing`, signs the resulting digest with Cosign, pushes the SBOM as a
  Cosign attestation, and attaches a build-provenance attestation via
  GitHub's native attestations. Authenticates to GHCR with the ephemeral,
  per-run `GITHUB_TOKEN` only.
- **weekly-rebuild.yml** — runs `build.yml` every Monday at 06:00 UTC to pick
  up upstream package updates.
- **pr-validate.yml** — on every pull request: ShellCheck on `build.d/*.sh`,
  Hadolint on the `Containerfile`, a full (unpushed) image build, and `bootc
  container lint --fatal-warnings` against the built image. The full build
  and lint step is skipped for pull requests from forks, since forks never
  receive repository secrets (no RHEL entitlement available) — see that
  workflow's job summary for what wasn't checked in that case. This workflow
  never authenticates to any registry and never publishes.
- **promote-stable.yml** — manual-only (`workflow_dispatch`). Verifies the
  given digest is Cosign-signed, then re-tags it `stable`. This is the only
  path that can move `stable`.
- **renovate.yml** — keeps the base image digest and GitHub Actions SHAs
  current.

### What CI can't verify

The build runner has no GPU, no real display, and isn't a bootc-managed
system itself, so none of the workflows above can confirm: GNOME session
behavior, GPU/driver-dependent extensions, or that `bootc switch`/`upgrade`
and an actual reboot succeed on real hardware. Those need a manual
smoke-test on a workstation after promoting to `stable`.

## Secrets

**Still required** (GitHub Actions repository secrets):

| Secret | Used for |
| --- | --- |
| `REGISTRY_REDHAT_IO_USER` / `REGISTRY_REDHAT_IO_PASSWORD` | Pulling `registry.redhat.io/rhel10/rhel-bootc` and the Renovate host rule for the same registry. |
| `RHSM_ACTIVATION_KEY` / `RHSM_ORG_ID` | `subscription-manager register` inside the build, to enable RPM repos. |
| `RENOVATE_TOKEN` | PAT used by `renovate.yml` so Renovate's own PRs trigger CI (`GITHUB_TOKEN`-authored PRs don't). |
| `DERIVATIVE_DISPATCH_TOKEN` | Optional. Notifies derivative repos to rebuild after a base image push. |

No GHCR credential is a secret: publishing uses the ephemeral, per-run
`GITHUB_TOKEN` (scoped to `packages: write` for that job only), and Cosign
signing is keyless via OIDC — there is no long-lived signing key to store or
rotate.

**Can be removed** (Quay is no longer used):

- `QUAY_USER`
- `QUAY_PASSWORD`

## Manual step required after the first GHCR push

The first time `build.yml` pushes an image, GitHub creates the
`daytwo-bootc-workstation-base` package under the `daytwo-internal` org. New
packages usually inherit the visibility of the workflow that created them,
but **confirm it explicitly**: go to the package's settings on GitHub
(org → Packages → daytwo-bootc-workstation-base → Package settings) and set
**Visibility: Private**, plus restrict access to the intended
teams/collaborators. Do this before relying on the image being private —
this repo's automation does not and cannot change package visibility itself.
