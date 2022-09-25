# Package

version       = "0.1.0"
author        = "Nbiba Bedis"
description   = "Deno stdlib for nim"
license       = "MIT"
srcDir        = "src"
backend       = "js"

# Dependencies


import std/strformat

task deno_show_compile, "compile deno-show example":
    exec "nim c --backend=js -d:release examples/deno_show.nim"
task deno_show_run, "run deno-show example":
    let args = commandLineParams[3.. commandLineParams.len - 1].join(" ")
    echo args
    exec &"deno run -A --unstable examples/deno_show.js {args}"

task test, "run tests":
    exec "nim c --backend=js tests/test1.nim"
    exec "deno run -A tests/test1.js"
