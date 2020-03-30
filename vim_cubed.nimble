# Package

version       = "0.1.0"
author        = "oakes"
description   = "Vim for masochists"
license       = "Public Domain"
srcDir        = "src"
bin           = @["vim_cubed"]

task dev, "Run dev version":
  exec "nimble run vim_cubed"

# Dependencies

requires "nim >= 1.0.6"
requires "paranim >= 0.3.0"
requires "paravim >= 0.8.0"
