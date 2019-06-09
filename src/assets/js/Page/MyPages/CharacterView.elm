module Page.MyPages.CharacterView exposing (Model, Msg(..), cardsView, init, update, view)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Models.Card as Card
import Models.Character as Character exposing (Character)
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


init : Session.Data -> String -> String -> ( Model, Cmd Msg )
init session apiKey characterId =
    ( Model session Close apiKey (Character.initCharacter "")
    , Cmd.none
    )


type Msg
    = ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "更新"
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain <| viewHelper model
        ]
    }


viewHelper : Model -> Html Msg
viewHelper model =
    div [ class "" ]
        [ h1 []
            [ text "キャラクターシート" ]
        , div
            [ class "edit-karte" ]
            []
        ]
