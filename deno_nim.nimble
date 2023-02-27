# Package

version       = "0.1.0"
author        = "Nbiba Bedis"
description   = "Deno stdlib for nim"
license       = "MIT"
srcDir        = "src"
backend       = "js"

# Dependencies


import std/strformat

task simple, "simple":
    exec "nim c examples/simple.nim"
    exec "deno run -A examples/simple.js"

task deno_show, "deno-show":
    exec "nim c examples/deno_show.nim"
    let args = commandLineParams[3.. commandLineParams.len - 1].join(" ")
    exec &"deno run -A --unstable examples/deno_show.js {args}"

task test, "run tests":
    exec "nim c --backend=js tests/test1.nim"
    exec "deno run -A tests/test1.js"

task docs, "doc":
    exec "nim doc --backend:js src/deno_nim.nim"
    exec "deno run -A src/htmldocs/nimcache/runnableExamples/*.js"
