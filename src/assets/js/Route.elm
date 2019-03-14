module Route exposing (Route(..), parse)

import Url exposing (..)


type Route
    = Top
    | Rulebook
    | PrivacyPolicy


parse : Url -> Maybe Route
parse url =
    Just Top
