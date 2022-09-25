import std/asyncjs
import std/private/jsutils
from std/jsffi import JsObject

type
  deno* = ref object of JsRoot
    build*: DenoBuild
    env*: DenoEnv
    readTextFile*: proc(file: cstring): Future[cstring]
    makeTempFile*: proc(options: JsObject): Future[cstring]
    writeFile*: proc(file:cstring, data: Uint8Array): Future[void]

  DenoBuild* = ref object of JsRoot
    target*: cstring
    arch*: cstring
    os*: cstring
    vendor*: cstring

  DenoEnv* = ref object of JsRoot
    get*: proc(key: cstring): cstring
    set*: proc(key: cstring, value: cstring)

  DenoMakeTempOptions* = ref object of JsRoot
    dir*: cstring
    suffix*: cstring

var Deno* {.importjs: "Deno".}: deno



type
  TextEncoder* = ref object of JsRoot ## https://nodejs.org/api/util.html#util_class_util_textencoder
    encoding*: cstring  ## https://nodejs.org/api/util.html#util_textencoder_encoding

func newTextEncoder*(): TextEncoder {.importjs: "(new TextEncoder(@))".}


func encode*(self: TextEncoder; input: cstring): Uint8Array {.importcpp.}
  ## https://nodejs.org/api/util.html#util_textencoder_encode_input
