module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, fragment, int, map, oneOf, s, string, top)


type Route
    = Top
    | RuleBook (Maybe String)
    | PrivacyPolicy
    | About
    | Agreement
    | LoginUser
    | CharacterCreate String
    | CharacterUpdate String String
    | CharacterView String
    | SandBox String
    | CharacterList
    | CharacterListNext String
    | EnemyList
    | BattleSheet
    | EnemyCreate String
    | EnemyUpdate String String
    | EnemyView String


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
        , map CharacterUpdate (s "mypage" </> s "character" </> s "edit" </> string </> string)
        , map SandBox (s "sandbox" </> string)
        , map CharacterView (s "character" </> s "view" </> string)
        , map CharacterListNext (s "characters" </> string)
        , map CharacterList (s "characters")
        , map EnemyList (s "enemies")
        , map BattleSheet (s "battle-sheet")
        , map EnemyUpdate (s "mypage" </> s "enemy" </> s "edit" </> string </> string)
        , map EnemyCreate (s "mypage" </> s "enemy" </> s "create" </> string)
        , map EnemyView (s "enemy" </> s "view" </> string)

        -- , map GitHubUser string
        -- , map Repo (string </> string)
        ]
