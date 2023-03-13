import std/strformat
import std/jscore
import std/jsconsole

import "../src/utils.nim"
import "../src/deno_nim/option.nim"
import "../src/deno_nim"

proc split(a: cstring, s:cstring): seq[cstring] {.importcpp.}
proc join(a: seq[cstring], s:cstring): cstring {.importcpp.}

# let updateAll = Deno.args.find((a) => a === "--update-all");

let binsPath = "{home_dir().unwrap}/.nimble/bin".fmt;


let files = Deno.readDirSync(binsPath.cstring)
for file in files:
  if not file.isSymlink: continue
  # console.log(file)
  let realBinPath = Deno.realPathSync("{binsPath}/{file.name}".fmt).cstring;

  # The pkg name can differ from the binary name
  let pkg = realBinPath.split("/".cstring)[^2]
  let (name, version) =  block:
    let r = pkg.split("-");
    (r[0],r[1])
  # if not pkg: throw "failed to read pkg from " + realBinPath

  let pkgPath = realBinPath.split("/".cstring)[0..^2].join("/");
  let meta = JSON.parse(
    Deno.readTextFileSync("{pkgPath}/nimblemeta.json".fmt).cstring,
  );
  console.log(meta)
  


