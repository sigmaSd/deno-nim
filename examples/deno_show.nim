import std/strformat
import std/asyncjs
import std/jsfetch
import std/jsre
import std/sugar
import std/sequtils
from std/jsffi import JsObject

import "../src/deno_nim/option.nim"
import "../src/deno_nim.nim"
from "utils/jsmacro.nim" import js

let homeDir = proc (): string =
    case $Deno.build.os
        of "linux", "darwin":
            return Deno.env.get("HOME").unwrap.`$`
        of "windows":
            return Deno.env.get("USERPROFILE").unwrap.`$`

let binaryPathFromName = proc(name: string): string = &"{homeDir()}/.deno/bin/{name}"

proc pipe[A, B](self: A, fn: proc(self: A): B): B =
    return fn(self)

let denoFile = proc(name: string): Future[cstring] {.async.} =
    return name
    .binaryPathFromName
    .pipe(proc(f: string): Future[cstring] = Deno.readTextFile(f))
    .await

let isFileLocal = (file: cstring) => file.contains(newRegExp("file://"))
let filePath = proc(file: cstring): cstring = file.match(newRegExp(
        "file://(.*)'"))[1]
let httpsPath = proc(file: cstring): string =
    # there can be multiple https links if there is an import map for example
    # we'll just pick the last one using  this separator " '"
    let matches = file.match(newRegExp("(https://.*)'"))[1].split(newRegExp(" '"));
    return $matches[matches.len - 1]

let downloadRemoteFileAndReturnPath = proc(path: string): Future[
        string] {.async.} =
    let code = await fetch(path.cstring)
    .then(proc (r: Response): Future[cstring] = r.text())
    let codePath = await Deno.makeTempFile(js({suffix: ".ts"}));
    await Deno.writeFile(codePath, newTextEncoder().encode(code))
    return $codePath;

let cmd = () => Deno.env.get("CMD").unwrap_or("bat")

let exec = proc (file: string, cmd: string): Future[bool] {.async.} =
    let cmdIter = cmd.split(newRegExp(" "));
    let args = if cmdIter.len > 1: cmdIter[1..cmdIter.len] else: @[]
    let status = await newCommand(cmdIter[0], DenoCommandOptions(
      args: Some(args.concat(@[file.cstring])),
      stdout: Some("inherit".cstring)
    )).spawn.status
    return status.success


const listAll = proc() {.async.} =
    let files = Deno.readDirSync(cstring(&"{homeDir()}/.deno/bin"));
    for file in files:
        let ftype = if isFileLocal(denoFile(
                $file.name).await): "local" else: "remote"
        echo(&"- {file.name} {ftype}")


proc main(): Future[void] {.async.} =
    let args = Deno.args
    if args.len != 0:
        let file = await denoFile($args[0]);
        let codePath = if isFileLocal(file): $filePath(
                file) else: $file.httpsPath.downloadRemoteFileAndReturnPath.await
        if exec(codePath, $cmd()).await != true:
                echo(&"{cmd()} {codePath} failed")
    else:
        await listAll()

discard main()
