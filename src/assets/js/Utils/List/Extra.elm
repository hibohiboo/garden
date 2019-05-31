module Utils.List.Extra exposing (findIndex)

{-| Take a predicate and a list, return the index of the first element that satisfies the predicate. Otherwise, return `Nothing`. Indexing starts from 0.
isEven : Int -> Bool
isEven i =
modBy 2 i == 0
findIndex isEven [ 1, 2, 3 ]
--> Just 1
findIndex isEven [ 1, 3, 5 ]
--> Nothing
findIndex isEven [ 1, 2, 4 ]
--> Just 1
-}

-- https://github.com/elm-community/list-extra/blob/8.2.0/src/List/Extra.elm


findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex =
    findIndexHelp 0


findIndexHelp : Int -> (a -> Bool) -> List a -> Maybe Int
findIndexHelp index predicate list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if predicate x then
                Just index

            else
                findIndexHelp (index + 1) predicate xs
