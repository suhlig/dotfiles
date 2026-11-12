# shellcheck shell=bash
# Shared helpers for the verify.sh scripts of suhlig/dotfiles and (when it is
# stowed on top) dotfiles-ibm. Source this file; do not run it.
#
# Each check prints PASS or FAIL. Call `finish` last: the exit status is the
# number of failures (capped at 255).

failures=0

# Private scratch directory: a fixed path in /tmp could be left over from an earlier
# run by another user (e.g. in a Docker layer) and cannot be deleted by us (sticky /tmp).
TEST_TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TEST_TMP"' EXIT

pass() { printf 'PASS  %s\n' "$1"; }

fail() {
  printf 'FAIL  %s\n' "$1"
  [[ -n ${2:-} ]] && printf '      %s\n' "$2"
  failures=$((failures + 1))
}

# check <description> <command...>; the command's output is shown on failure.
check() {
  local desc=$1 out
  shift
  if out=$("$@" 2>&1); then pass "$desc"; else fail "$desc" "${out//$'\n'/$'\n      '}"; fi
}

# expect <description> <expected> <actual>
expect() {
  if [[ $2 == "$3" ]]; then pass "$1"; else fail "$1" "expected '$2', got '$3'"; fi
}

# repo <dir> [origin-url]: a fresh repository outside the dotfiles checkouts.
# Fails loudly: a stale directory would make every identity check meaningless.
repo() {
  local dir=$1 url=${2:-}
  if ! { rm -rf "$dir" && git init -q "$dir"; }; then
    fail "can create a fresh repository in $dir"
    return 1
  fi
  [[ -z $url ]] || git -C "$dir" remote add origin "$url"
}

# ssh_g <host> <keyword>: the value(s) `ssh -G` resolves for the host.
ssh_g() { ssh -G "$1" 2>/dev/null | grep -i "^$2 " | cut -d' ' -f2-; }

# git_ssh_argv <repo>: the arguments git passes to `ssh` for `git ls-remote origin` in <repo>
# (empty if git does not use ssh for that remote). A shim stands in for ssh and records
# its argv, so this sees exactly what core.sshCommand, GIT_SSH_COMMAND and url.insteadOf
# lead to, without any network access.
git_ssh_argv() {
  local shim=$TEST_TMP/shim
  mkdir -p "$shim"
  printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/argv"\nexit 255\n' "$TEST_TMP" > "$shim/ssh"
  chmod +x "$shim/ssh"
  rm -f "$TEST_TMP/argv"
  PATH=$shim:$PATH GIT_TERMINAL_PROMPT=0 timeout 15 git -C "$1" ls-remote origin > /dev/null 2>&1
  if [[ -f $TEST_TMP/argv ]]; then tr '\n' ' ' < "$TEST_TMP/argv"; fi
  return 0
}

# ssh_warnings <host>: what `ssh -G` complains about, e.g. "Bad configuration option".
# The "Pseudo-terminal" notice comes from ssh itself whenever stdin is not a terminal
# (as in a Docker build), not from the configuration.
ssh_warnings() { ssh -G "$1" 2>&1 >/dev/null | grep -v '^Pseudo-terminal will not be allocated'; true; }

finish() {
  echo
  if ((failures)); then
    printf '%d check(s) failed.\n' "$failures"
    exit $((failures > 255 ? 255 : failures))
  fi
  echo "All checks passed."
}
