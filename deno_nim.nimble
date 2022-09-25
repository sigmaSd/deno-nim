# Package

version       = "0.1.0"
author        = "Nbiba Bedis"
description   = "Deno stdlib for nim"
license       = "MIT"
srcDir        = "src"
backend       = "js"


# Dependencies

requires "nim >= 1.7.1"

task cexample, "compile examples":
    exec "nim c --backend=js examples/example.nim"
task rexample, "run examples":
    exec "deno run -A examples/example.js"
