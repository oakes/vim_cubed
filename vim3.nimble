# Package

version       = "0.1.0"
author        = "oakes"
description   = "Vim for masochists"
license       = "Public Domain"
srcDir        = "src"
bin           = @["vim3"]

task dev, "Run dev version":
  exec "nimble run vim3"

# Dependencies

requires "nim >= 1.0.6"
requires "paranim >= 0.6.0"
requires "paravim >= 0.11.0"
requires "stb_image >= 2.5"
