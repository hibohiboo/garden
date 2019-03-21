module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, fragment, map, oneOf, s, string, top)


type Route
    = Top
    | RuleBook (Maybe String)
    | PrivacyPolicy
    | About
    | GitHubUser String
    | Repo String String


parse : Url -> Maybe Route
parse url =
    Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Top top
        , map RuleBook (s "rulebook" </> fragment identity)
        , map PrivacyPolicy (s "privacy-policy")
        , map About (s "about")
        , map GitHubUser string
        , map Repo (string </> string)
        ]
