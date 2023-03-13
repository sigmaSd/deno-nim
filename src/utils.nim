import "../src/deno_nim/option.nim"

{.emit: """
import home_dir from "https://deno.land/x/dir@1.5.1/home_dir/mod.ts";
""".}
proc home_dir*(): Option[cstring] {.importjs: "home_dir()".}

