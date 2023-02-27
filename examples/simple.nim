import std/asyncjs
import std/jsre
import std/tables

import "../src/deno_nim.nim"

proc startsWith(self: cstring, s: cstring): bool {.importcpp.}
proc split(self: cstring, s: cstring): seq[cstring] {.importcpp.}

proc main(): Future[void] {.async.} =
    let hosts = Deno.readTextFileSync("/etc/hosts")
    var data = initTable[cstring, cstring]()
    for line in hosts.split("\n"):
        if line.startsWith("#") or line == "":
            continue
        let entry = line.split(newRegExp("\\s+"))
        data[entry[0]] = entry[1]
    echo data

discard main()

# proc main(): Future[void] {.async.} =
#   let args = Deno.args
#   let cmd = args[0]
#   let prog = args[1]
#   cmd.split("=").echo
