when not defined(js) and not defined(nimdoc):
  {.fatal: "Module deno is designed to be used with the JavaScript backend.".}

import std/asyncjs
from std/jsffi import JsObject
import std/private/jsutils

import "deno_nim/option.nim"
export unwrap, unwrap_or

import "deno_nim/jscore.nim"
export newTextEncoder, encode


type
  DenoCommand* = ref object of JsRoot
  DenoCommandOptions* = ref object of JsRoot
    args*   : Option[seq[cstring]]
    stdout* : Option[cstring]
  DenoChildProcess = ref object of JsRoot
    status* : Future[DenoCommandStatus]
  DenoCommandStatus = ref object of JsRoot
    success* : bool

func newCommand*(command:cstring): DenoCommand {.importjs: "new Deno.Command(#)".}
func newCommand*(command:cstring,options: DenoCommandOptions): DenoCommand {.importjs: "new Deno.Command(#,#)".}
func spawn*(self: DenoCommand): DenoChildProcess {.importcpp.}

type
    deno* = ref object of JsRoot
        build*: DenoBuild
        env*: DenoEnv
        readTextFile*: proc(file: cstring): Future[cstring]
        readTextFileSync*: proc(file: cstring): cstring
        realPathSync*: proc(path: cstring): cstring
        makeTempFile*: proc(options: JsObject): Future[cstring]
        writeFile*: proc(file: cstring, data: Uint8Array): Future[void]
        args*: seq[cstring]
        cwd*: proc(): cstring
        Command*: DenoCommand

    DirEntry* = ref object of JsRoot
        name*: cstring
        isFile*: bool
        isDirectory*: bool
        isSymlink*: bool

    DenoBuild* = ref object of JsRoot
        target*: cstring
        arch*: cstring
        os*: cstring
        vendor*: cstring

    DenoEnv* = ref object of JsRoot
        get*: proc(key: cstring): Option[cstring]
        set*: proc(key: cstring, value: cstring)

    DenoMakeTempOptions* = ref object of JsRoot
        dir*: cstring
        suffix*: cstring

proc readDirSync*(self: deno, path: cstring): seq[DirEntry] {.importjs: "[... #.readDirSync(#)]".} #TODO iterbale

runnableExamples"-r:off":
    import std/asyncjs
    import std/jsconsole
    Deno.env.set("hello", "world")
    assert Deno.env.get("hello").unwrap == "world"
    proc main(): Future[void] {.async.} =
        Deno.readTextFile("/etc/hosts").await.echo
        console.log(Deno.build)
    discard main()


var Deno* {.importjs: "Deno".}: deno
