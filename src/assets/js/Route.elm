module Route exposing (Route(..), parse)

import Url exposing (..)


type Route
    = Top
    | RuleBook
    | PrivacyPolicy
    | NotFound


parse : Url -> Maybe Route
parse url =
    Just Top
