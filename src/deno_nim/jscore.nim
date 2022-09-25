import std/private/jsutils

type
    TextEncoder* = ref object of JsRoot
        encoding*: cstring

func newTextEncoder*(): TextEncoder {.importjs: "(new TextEncoder(@))".}
func encode*(self: TextEncoder; input: cstring): Uint8Array {.importcpp.}
