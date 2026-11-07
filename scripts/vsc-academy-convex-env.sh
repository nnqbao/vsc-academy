#!/bin/zsh
set -euo pipefail

if (( $# == 0 )); then
  echo "usage: $0 <command> [args...]" >&2
  exit 64
fi

# Port comes from infra/convex-local/.env when this working copy overrides it, so the wrapper
# always talks to THIS copy's backend and never to another clone's (or teduenglish's on 3280).
readonly REPO_ROOT="${0:A:h:h}"
if [[ -r "$REPO_ROOT/infra/convex-local/.env" ]]; then
  set -a; source "$REPO_ROOT/infra/convex-local/.env"; set +a
fi
export CONVEX_SELF_HOSTED_URL="${CONVEX_SELF_HOSTED_URL:-http://127.0.0.1:${ACADEMY_CONVEX_PORT:-3320}}"
if ! admin_key="$(
  security find-generic-password \
    -s vsc-academy-convex-local-admin-key \
    -a vsc-academy \
    -w
)"; then
  echo "failed to read vsc-academy-convex-local-admin-key from Keychain" >&2
  exit 78
fi
if [[ -z "$admin_key" ]]; then
  echo "vsc-academy-convex-local-admin-key is empty" >&2
  exit 78
fi
export CONVEX_SELF_HOSTED_ADMIN_KEY="$admin_key"
export CONVEX_DEPLOYMENT=""

exec "$@"
