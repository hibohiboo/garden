module Utils.Util exposing (deleteAt)

import Array exposing (Array)


deleteAt : Int -> Array a -> Array a
deleteAt i arrays =
    let
        len =
            Array.length arrays

        head =
            Array.slice 0 i arrays

        tail =
            Array.slice (i + 1) len arrays
    in
    Array.append head tail
