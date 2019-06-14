module Page.MyPages.CharacterView exposing (Model, Msg(..), cardsView, init, update, view)

import Array exposing (Array)
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
    , cardState : Array CardState
    }


type alias CardState =
    { card : Card.CardData
    , isUsed : Bool
    , isDamaged : Bool
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

        model =
            case character of
                Just char ->
                    Model session Close apiKey char (char.cards |> Array.map (\c -> CardState c False False))

                Nothing ->
                    Model session Close apiKey (Character.initCharacter "") Array.empty
    in
    ( model
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
    | UnUsedAll


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
                            { oldCharacterModel
                                | character = character
                                , session = Session.addCharacter model.session json character.characterId
                                , cardState = character.cards |> Array.map (\c -> CardState c False False)
                            }
                    in
                    ( newCharacterModel, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GotCharacter (Err _) ->
            ( model, Cmd.none )

        UnUsedAll ->
            ( { model | cardState = model.character.cards |> Array.map (\c -> CardState c False False) }, Cmd.none )


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
    div [ class "character-sheet" ]
        [ h1 [] [ text "キャラクターシート" ]
        , characterCard model.character
        , h2 [] [ text "データカード" ]
        , button [ onClick UnUsedAll ] [ text "使用済チェックをすべて外す" ]
        , div [] (Array.map (\s -> dataCardSimpleView s) model.cardState |> Array.toList)
        ]


dataCardSimpleView cardState =
    let
        card =
            cardState.card
    in
    div [ class "simple-datacard" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "name" ] [ text card.cardName ]
                , div [ class "timingLabel label" ] [ text "タイミング" ]
                , div [ class "timingValue" ] [ text card.timing ]
                , div [ class "costLabel label" ] [ text "C" ]
                , div [ class "costValue" ] [ text <| String.fromInt card.cost ]
                , div [ class "rangeLabel label" ] [ text "R" ]
                , div [ class "rangeValue" ] [ text (Card.getRange card) ]
                , div [ class "targetLabel label" ] [ text "対象" ]
                , div [ class "targetValue" ] [ text card.target ]
                , div [ class "used" ] [ label [] [ input [ type_ "checkbox", checked cardState.isUsed ] [], span [] [ text "使用済" ] ] ]
                , div [ class "injury" ] [ label [] [ input [ type_ "checkbox", class "filled-in" ] [], span [] [ text "負傷" ] ] ]
                , div [ class "effect" ] [ text card.effect ]
                ]
            ]
        ]


characterCard : Character -> Html msg
characterCard char =
    let
        tag tagText =
            span [ class "tag" ] [ text tagText ]

        tagNameList =
            Card.getTraitList char.cards
    in
    div [ class "character-card" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "skillLabel" ] [ text ("キャラクター" ++ "/" ++ "検体") ]
                , div [ class "image" ]
                    [ img [ src "" ] []
                    , img [ src "" ] []
                    ]
                , div [ class "cardKana" ] [ text char.kana ]
                , div [ class "cardName" ] [ text char.name ]
                , div [ class "attrOrganLabel attrLabel border" ] [ text "変異器官" ]
                , div [ class "attrOrganValue border" ] [ text char.organ ]
                , div [ class "attrMutagenLabel attrLabel border" ] [ text "変異原" ]
                , div [ class "attrMutagenValue border" ] [ text char.mutagen ]
                , div [ class "attrReasonLabel attrLabel border" ] [ text "収容理由" ]
                , div [ class "attrReasonValue border" ] [ text char.reason ]
                , div [ class "attrLaboLabel attrLabel border" ] [ text "研究所" ]
                , div [ class "attrLaboValue attrLabel border" ] [ text char.labo ]
                , div [ class "tags" ] (List.map (\t -> tag t) tagNameList)
                , div [ class "mainContent border" ]
                    [ div [ class "effect " ] [ text ("行動力 : " ++ String.fromInt char.activePower) ]
                    , div [ class "description" ] [ text char.memo ]
                    ]
                , div [ class "bottomContent" ]
                    [ div [ class "cardId" ] [ text "" ]
                    ]
                ]
            ]
        ]
