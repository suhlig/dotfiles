group "default" {
  targets = [
    "dotfiles-debian-trixie-slim",
    "dotfiles-debian-trixie-full",
    "dotfiles-debian-trixie-test",
  ]
}

target "dotfiles-debian-trixie-slim" {
  dockerfile = "test/debian/trixie/Dockerfile.slim"
  tags = ["dotfiles-debian-trixie:slim"]
  labels = {
    "org.opencontainers.image.source" = "https://github.com/suhlig/dotfiles"
    "org.opencontainers.image.author" = "steffen@familie-uhlig.net"
  }
  output = ["type=docker,name=dotfiles-debian-trixie:slim"]
}

target "dotfiles-debian-trixie-full" {
  inherits = ["dotfiles-debian-trixie-slim"]
  dockerfile = "test/debian/trixie/Dockerfile.full"
  contexts = {
    "dotfiles-debian-trixie:slim" = "target:dotfiles-debian-trixie-slim"
  }
  tags = ["dotfiles-debian-trixie:full", "dotfiles-debian-trixie:latest"]
}

target "dotfiles-debian-trixie-test" {
  inherits = ["dotfiles-debian-trixie-full"]
  dockerfile = "test/debian/trixie/Dockerfile.test"
  contexts = {
    "dotfiles-debian-trixie:slim" = "target:dotfiles-debian-trixie-slim"
    "dotfiles-debian-trixie:full" = "target:dotfiles-debian-trixie-full"
  }
  tags = ["dotfiles-debian-trixie:test"]
}
