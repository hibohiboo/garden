module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, fragment, map, oneOf, s, string, top)


type Route
    = Top
    | RuleBook (Maybe String)
    | PrivacyPolicy
    | About
    | Agreement
    | LoginUser
    | CharacterCreate String
    | CharacterUpdate String


parse : Url -> Maybe Route
parse url =
    Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Top top
        , map RuleBook (s "rulebook" </> fragment identity)
        , map PrivacyPolicy (s "privacy-policy")
        , map Agreement (s "agreement")
        , map About (s "about")
        , map LoginUser (s "mypage")
        , map CharacterCreate (s "mypage" </> s "character" </> s "create" </> string)
        , map CharacterUpdate (s "mypage" </> s "character" </> s "edit" </> string)

        -- , map GitHubUser string
        -- , map Repo (string </> string)
        ]
