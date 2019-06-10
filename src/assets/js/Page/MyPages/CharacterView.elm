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
    let
        character =
            getCharacter session characterId

        characterCmd =
            case character of
                Just _ ->
                    Cmd.none

                Nothing ->
                    Session.fetchCharacter GotCharacter characterId
    in
    ( Model session Close apiKey (Character.initCharacter "")
    , Cmd.batch [ characterCmd ]
    )


getCharacter : Session.Data -> String -> Maybe Character
getCharacter session characterId =
    case Session.getCharacter session characterId of
        Just json ->
            case D.decodeString Character.characterDecoder json of
                Err a ->
                    Nothing

                Ok char ->
                    Just char

        Nothing ->
            Nothing


type Msg
    = ToggleNavigation
    | GotCharacter (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        GotCharacter (Ok json) ->
            case D.decodeString Character.characterDecoder json of
                Ok character ->
                    let
                        oldCharacterModel =
                            model

                        newCharacterModel =
                            { oldCharacterModel | character = character, session = Session.addCharacter model.session json character.characterId }
                    in
                    ( newCharacterModel, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GotCharacter (Err _) ->
            ( model, Cmd.none )


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
            [ text model.character.name ]
        ]
