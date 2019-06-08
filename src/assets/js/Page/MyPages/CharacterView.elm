module Page.MyPages.CharacterView exposing (cardsView)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Models.Card as Card
import Models.Character exposing (..)
import Models.CharacterEditor exposing (EditorModel)
import Page.MyPages.CharacterEditor as CharacterEditor exposing (editArea)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


cardsView : Character -> Html msg
cardsView char =
    div [ class "cards" ]
        [ Card.cardList (Array.toList char.cards)
        ]


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , character : Character
    }


init : Session.Data -> String -> String -> String -> ( Model, Cmd Msg )
init session apiKey storeUserId characterId =
    ( initModel session apiKey storeUserId reasons traits cards
    , Cmd.batch [ getCharacter ( storeUserId, characterId ), reasonsCmd, traitsCmd, cardsCmd ]
    )
