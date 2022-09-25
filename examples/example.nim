import std/strformat
import std/asyncjs
import std/jsfetch
import std/jsre
import std/jsconsole
import std/sugar
import "../src/deno_nim.nim"
from std/jsffi import JsObject
from "utils/jsmacro.nim" import js


static:
    echo add(5, 5)

let homeDir = proc (): string =
    case $Deno.build.os
        of "linux", "darwin":
            return $Deno.env.get("HOME")
        of "windows":
            return $Deno.env.get("USERPROFILE")

let binaryPathFromName = proc(name: string): string = &"{homeDir()}/.deno/bin/{name}"

proc pipe[A, B](self: A, fn: proc(self: A): B): B =
    return fn(self)

let denoFile = proc(name: string): Future[string] {.async.} =
    return name
    .binaryPathFromName
    .pipe(proc(f: string): Future[cstring] = Deno.readTextFile(f))
    .await
    .`$`

let filePath = proc(file: string): cstring = file.match(newRegExp(
        "file://(.*)'"))[1]
let httpsPath = proc(file: string): string =
    # there can be multiple https links if there is an import map for example
    # we'll just pick the last one using  this separator " '"
    let matches = file.match(newRegExp("(https://.*)'"))[1].`$`.split(newRegExp(
            " '"));
    return $matches[matches.len - 1]

let downloadRemoteFileAndReturnPath = proc(path: string):Future[string] {.async.} =
    let code = await fetch(path.cstring)
    .then(proc (r: Response): Future[cstring] = r.text())
    let codePath = await Deno.makeTempFile(js({ suffix: ".ts" }));
    await Deno.writeFile(codePath,newTextEncoder().encode(code))
    return $codePath;

proc main(): Future[void] {.async.} =
    #console.log(
    #fetch("https://cdn.deno.land/bolt/meta/versions.json".cstring)
    #.then(proc(r: Response): Future[JsObject] = r.json())
    #.await
    #)
    echo denoFile("bing").await

discard main()
