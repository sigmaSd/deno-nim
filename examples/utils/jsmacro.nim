import std/[macros, jsffi, strformat, strutils]

proc convert(thing: NimNode): string =
  case thing.kind
  of nnkExprColonExpr:
    let name = thing[0].strVal
    let val = convert(thing[1])
    result = fmt"{name}: {val}"
  of nnkTableConstr:
    var vals: seq[string]
    for arg in thing:
      vals.add convert(arg)
    result = "{<vals.join(\", \")>}".fmt('<', '>')
  of nnkIntLit: result = $thing.intVal
  of nnkStrLit: result = &"\"{thing.strVal}\""
  else: error(&"TODO type: {$thing}")

macro js*(args: untyped): untyped =
  expectKind args, nnkTableConstr

  let jscode = convert(args) & "@" # have an empty "pattern" to fool importjs

  result = quote do:
    proc jscall: JsObject {.importjs: `jscode`.}
    jscall()


runnableExamples"-r:off":
  import std/jsconsole
  console.log(js({a: 4, b: "hello", c: {q: 4}}))
