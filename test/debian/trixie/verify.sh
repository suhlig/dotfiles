#!/usr/bin/env bash
# Checks the result of stowing the public dotfiles on a Linux machine.
# Runs as the last step of test/debian/trixie/Dockerfile.slim (as an unprivileged
# user), but works on any Linux machine where the dotfiles are stowed:  bash verify.sh
#
# Checks that guard a bug that was fixed once say so in a comment.
# SC2088: a quoted ~ is literal on purpose; git prints user.signingkey unexpanded.
# shellcheck disable=SC2088
set -u

# shellcheck source=../../lib.sh
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

echo "== shell"

# Guards the Linux guard in .zshenv: /opt/homebrew/bin/brew does not exist here.
expect "zsh starts without errors" "" "$(zsh -c true 2>&1)"

echo "== ssh"

check "ssh parses the merged config" ssh -G shop

# Guards UseKeychain: OpenSSH on Linux rejects it unless IgnoreUnknown precedes it.
expect "ssh -G prints no warnings" "" "$(ssh_warnings shop)"

# Guards the host order in ~/.ssh/config: the short name and the FQDN must resolve alike.
expect "shop and its FQDN use the same user" "suhlig" "$(ssh_g shop user)"
expect "shop and its FQDN use the same user (FQDN)" "suhlig" "$(ssh_g shop.tailnet-204f.ts.net user)"
expect "other tailnet hosts get root" "root" "$(ssh_g foo.tailnet-204f.ts.net user)"

# Git does not use ssh for GitHub, so ~/.ssh/config has nothing to say about it.
expect "no ssh block for github.com" "" "$(ssh_g github.com identityfile | grep identities/)"

echo "== git"

cd "$TEST_TMP" || exit 1

repo "$TEST_TMP/r-default" https://github.com/suhlig/example.git
expect "default e-mail" "steffen@familie-uhlig.net" "$(git -C "$TEST_TMP/r-default" config user.email)"
expect "commits are signed with ssh" "ssh" "$(git -C "$TEST_TMP/r-default" config gpg.format)"
expect "signing is on by default" "true" "$(git -C "$TEST_TMP/r-default" config commit.gpgsign)"
expect "signing key is the personal one" "~/.ssh/identities/suhlig/id_ed25519.pub" "$(git -C "$TEST_TMP/r-default" config user.signingkey)"
expect "allowedSignersFile is defined once" "1" "$(git config --global --includes --get-all gpg.ssh.allowedsignersfile | wc -l | tr -d ' ')"
check "~/.ssh/git-signers lists a key" grep -q ssh-ed25519 "$HOME/.ssh/git-signers"

echo "== GitHub over https"

# Guards the https-only setup: old clones and tools with ssh URLs must end up on https.
for host in github.com gist.github.com; do
  for url in "git@$host:foo/bar.git" "ssh://git@$host/foo/bar.git" "https://$host/foo/bar.git"; do
    expect "$url: is rewritten to https" "https://$host/foo/bar.git" "$(git ls-remote --get-url "$url")"
  done
done

# Guards the helper chain: only gh may supply credentials. An osxkeychain helper from
# the system gitconfig would run first and could hand out the wrong account's token.
for host in github.com gist.github.com; do
  expect "$host credentials come from gh only" "!gh auth git-credential" \
    "$(git -C "$TEST_TMP/r-default" config --get-urlmatch credential.helper "https://$host")"
  expect "$host: the default gh account is suhlig" "suhlig" \
    "$(git -C "$TEST_TMP/r-default" config --get-urlmatch credential.username "https://$host")"
done
# The container has no system-level osxkeychain, so simulate one: it must not run.
printf '[credential]\n  helper = !echo SYSTEM-HELPER-RAN >&2; true\n' > "$TEST_TMP/system-gitconfig"
out=$(cd "$TEST_TMP/r-default" && printf 'protocol=https\nhost=github.com\n\n' \
  | GIT_CONFIG_SYSTEM="$TEST_TMP/system-gitconfig" GIT_TERMINAL_PROMPT=0 git credential fill 2>&1)
case $out in
  *SYSTEM-HELPER-RAN*) fail "a system-level credential helper does not run before gh" "$out" ;;
  *) pass "a system-level credential helper does not run before gh" ;;
esac
expect "no ssh command is configured anywhere" "" "$(git -C "$TEST_TMP/r-default" config core.sshcommand)"

echo "== identities per directory"

# Guards the gitdir rules: the checkout location alone selects the identity and the gh
# account (credential.username). Aishe's and nerab's tokens are never on this machine;
# these checks only look at the configuration.
org_check() {
  local dir=$1 email=$2 account=$3 gpgsign=$4
  mkdir -p "$dir/.." || fail "can create $dir"
  repo "$dir" https://github.com/some/repo.git
  expect "$dir: e-mail" "$email" "$(git -C "$dir" config user.email)"
  expect "$dir: gh account" "$account" "$(git -C "$dir" config --get-urlmatch credential.username https://github.com)"
  expect "$dir: gpgsign" "$gpgsign" "$(git -C "$dir" config commit.gpgsign)"
  expect "$dir: gh is the only credential helper" "!gh auth git-credential" "$(git -C "$dir" config --get-urlmatch credential.helper https://github.com)"
}

org_check ~/git/github.com/nerab/pairing "nerab@gmx.at" nerab true
org_check ~/git/github.com/nowak-reisen/x "aishe.drechsler@speisehof.de" aidrechs false
org_check ~/git/github.com/speisehof/x "aishe.drechsler@speisehof.de" aidrechs false
org_check ~/git/github.com/suhlig/x "steffen@familie-uhlig.net" suhlig true

# A worktree of an organisation's repository lives next to it and must get the same identity.
git -C ~/git/github.com/nowak-reisen/x -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init \
  && git -C ~/git/github.com/nowak-reisen/x worktree add -q ../x-branch -b branch
expect "worktree of an organisation repo: e-mail" "aishe.drechsler@speisehof.de" "$(git -C ~/git/github.com/nowak-reisen/x-branch config user.email)"

finish
