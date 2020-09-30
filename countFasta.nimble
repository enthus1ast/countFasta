# Package

version       = "0.1.0"
author        = "David Krause"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.3.5"
requires "cligen"

task release, "builds fastalib":
  exec "nim c -d:release --opt:speed -d:danger --passl:-s fastalib.nim"
