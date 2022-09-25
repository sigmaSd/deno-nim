type Option*[T] = distinct T

proc isSome*[T](o: Option[T]): bool {.importjs: "# !== undefined".}

proc unwrap*[T](o: Option[T]): T =
    if o.isSome:
        return T(o)
    raise newException(Defect, "Can't obtain a value from a `none`")

proc unwrap_or*[T](o: Option[T], default: T): T =
    if o.isSome:
        return T(o)
    return default
