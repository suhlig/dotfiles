#!/usr/bin/env bash
# Checks the result of stowing the public dotfiles on a Linux machine.
# Runs as the last step of test/debian/trixie/Dockerfile.slim (as an unprivileged
# user), but works on any Linux machine where the dotfiles are stowed:  bash verify.sh
#
# Checks that guard a bug that was fixed once say so in a comment.
# SC2088: a quoted ~ is literal on purpose; `ssh -G` prints IdentityFile paths unexpanded.
# shellcheck disable=SC2088
set -u

# shellcheck source=../../lib.sh
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

echo "== shell"

# Guards the Linux guard in .zshenv: /opt/homebrew/bin/brew does not exist here.
expect "zsh starts without errors" "" "$(zsh -c true 2>&1)"

echo "== ssh"

check "ssh parses the merged config" ssh -G github.com

# Guards UseKeychain: OpenSSH on Linux rejects it unless IgnoreUnknown precedes it.
expect "ssh -G prints no warnings" "" "$(ssh_warnings github.com)"

expect "github.com: User git" "git" "$(ssh_g github.com user)"
expect "github.com: IdentitiesOnly" "yes" "$(ssh_g github.com identitiesonly)"
expect "github.com: only the personal key" "~/.ssh/identities/suhlig/id_ed25519" "$(ssh_g github.com identityfile)"

# Guards the host order in 50-main.conf: the short name and the FQDN must resolve alike.
expect "shop and its FQDN use the same user" "suhlig" "$(ssh_g shop user)"
expect "shop and its FQDN use the same user (FQDN)" "suhlig" "$(ssh_g shop.tailnet-204f.ts.net user)"
expect "other tailnet hosts get root" "root" "$(ssh_g foo.tailnet-204f.ts.net user)"
expect "pi hosts get user pi" "pi" "$(ssh_g pi user)"

# Only *.conf is included, so editor backups and the like cannot break ssh.
stray=$HOME/.ssh/config.d/zz-stray
echo "this is not valid ssh configuration" > "$stray"
expect "files in config.d without .conf are ignored" "" "$(ssh_warnings github.com)"
rm -f "$stray"

echo "== git"

cd "$TEST_TMP" || exit 1

repo "$TEST_TMP/r-default" git@github.com:suhlig/example.git
expect "default e-mail" "steffen@familie-uhlig.net" "$(git -C "$TEST_TMP/r-default" config user.email)"
expect "commits are signed with ssh" "ssh" "$(git -C "$TEST_TMP/r-default" config gpg.format)"
expect "signing is on by default" "true" "$(git -C "$TEST_TMP/r-default" config commit.gpgsign)"
expect "signing key is the personal one" "~/.ssh/identities/suhlig/id_ed25519.pub" "$(git -C "$TEST_TMP/r-default" config user.signingkey)"

# Only the default identity needs no extra SSH key: ~/.ssh/config picks it per host.
expect "no default core.sshCommand" "" "$(git -C "$TEST_TMP/r-default" config core.sshcommand)"

expect "https URLs are rewritten to ssh" "git@github.com:foo/bar.git" "$(git ls-remote --get-url https://github.com/foo/bar.git)"

# Guards the includeIf rules for Aishe's organisations: both URL forms must match,
# because hasconfig:remote.*.url compares the URL before insteadOf rewriting.
for url in git@github.com:nowak-reisen/x.git https://github.com/nowak-reisen/x.git \
           git@github.com:speisehof/x.git https://github.com/speisehof/x.git; do
  repo "$TEST_TMP/r-aishe" "$url"
  expect "$url: e-mail" "aishe.drechsler@speisehof.de" "$(git -C "$TEST_TMP/r-aishe" config user.email)"
  expect "$url: unsigned" "false" "$(git -C "$TEST_TMP/r-aishe" config commit.gpgsign)"
  case $(git -C "$TEST_TMP/r-aishe" config core.sshcommand) in
    *identities/aidrex/id_ed25519*) pass "$url: uses Aishe's key" ;;
    *) fail "$url: uses Aishe's key" "core.sshcommand is '$(git -C "$TEST_TMP/r-aishe" config core.sshcommand)'" ;;
  esac
done

mkdir -p ~/git/github.com/nerab || fail "can create ~/git/github.com/nerab"
repo ~/git/github.com/nerab/pairing
expect "nerab checkout: e-mail" "nerab@gmx.at" "$(git -C ~/git/github.com/nerab/pairing config user.email)"

# Guards UseKeychain in the org sshCommands: -F /dev/null drops the IgnoreUnknown
# from ~/.ssh/config, so the command has to carry its own.
for r in "$TEST_TMP/r-aishe" ~/git/github.com/nerab/pairing; do
  cmd=$(git -C "$r" config core.sshcommand)
  check "core.sshCommand of ${r##*/} is valid OpenSSH here" sh -c "$cmd -G github.com"
done

expect "allowedSignersFile is defined once" "1" "$(git config --global --includes --get-all gpg.ssh.allowedsignersfile | wc -l | tr -d ' ')"
check "~/.ssh/git-signers lists a key" grep -q ssh-ed25519 "$HOME/.ssh/git-signers"

finish
