port module Page.MyPages.CharacterView exposing (Model, Msg(..), cardsView, init, subscriptions, update, view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import Json.Decode.Pipeline
import Json.Encode as E
import Models.Card as Card
import Models.Character as Character exposing (Character)
import Models.CharacterEditor exposing (EditorModel)
import Page.MyPages.CharacterEditor as CharacterEditor exposing (editArea)
import Page.Views.CharacterView exposing (characterCard)
import Page.Views.Tag exposing (tag)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


port saveCardState : E.Value -> Cmd msg


port getCardState : String -> Cmd msg


port gotCardState : (String -> msg) -> Sub msg


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
    , ap : Int
    , currentAp : Int
    }


type alias CardState =
    { card : Card.CardData
    , isUsed : Bool
    , isDameged : Bool
    }


type alias State =
    { isUsed : Bool
    , isDameged : Bool
    }


encodeCardStateToValue : CardState -> E.Value
encodeCardStateToValue state =
    E.object
        [ ( "isUsed", E.bool state.isUsed )
        , ( "isDameged", E.bool state.isDameged )
        ]


encodeCardViewToValue : Model -> E.Value
encodeCardViewToValue model =
    E.object
        [ ( "characterId", E.string model.character.characterId )
        , ( "states", E.array encodeCardStateToValue model.cardState )
        , ( "ap", E.int model.ap )
        , ( "currentAp", E.int model.currentAp )
        ]


stateDecoder : D.Decoder State
stateDecoder =
    D.succeed State
        |> Json.Decode.Pipeline.required "isUsed" D.bool
        |> Json.Decode.Pipeline.required "isDameged" D.bool


init : Session.Data -> String -> String -> ( Model, Cmd Msg )
init session apiKey characterId =
    let
        character =
            getCharacter session characterId

        characterCmd =
            case character of
                Just _ ->
                    getCardState characterId

                Nothing ->
                    Session.fetchCharacter GotCharacter characterId

        model =
            case character of
                Just char ->
                    Model session Close apiKey char (char.cards |> Array.map (\c -> CardState c False False)) 0 0

                Nothing ->
                    let
                        initChar =
                            Character.initCharacter ""
                    in
                    Model session Close apiKey { initChar | memo = "なうろーでぃんぐ" } Array.empty 0 0
    in
    ( model
    , Cmd.batch [ characterCmd ]
    )


getCharacter : Session.Data -> String -> Maybe Character
getCharacter session characterId =
    case Session.getCharacter session characterId of
        Just json ->
            case D.decodeString Character.characterDecoderFromFireStoreApi json of
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
    | ToggleUsed Int
    | ToggleInjury Int
    | GotCardState String
    | InputAp String
    | InputCurrentAp String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        GotCharacter (Ok json) ->
            case D.decodeString Character.characterDecoderFromFireStoreApi json of
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
                    ( newCharacterModel, getCardState character.characterId )

                Err _ ->
                    ( model, Cmd.none )

        GotCharacter (Err _) ->
            ( model, Cmd.none )

        UnUsedAll ->
            let
                newModel =
                    { model | cardState = model.cardState |> Array.map (\c -> CardState c.card False c.isUsed) }
            in
            ( newModel, newModel |> encodeCardViewToValue |> saveCardState )

        ToggleUsed i ->
            let
                beforeStates =
                    model.cardState

                before =
                    Array.get i beforeStates

                afterStates =
                    case before of
                        Just b ->
                            let
                                after =
                                    { b | isUsed = not b.isUsed }
                            in
                            Array.set i after beforeStates

                        -- Todo; なかったときの対応
                        Nothing ->
                            beforeStates

                newModel =
                    { model | cardState = afterStates }
            in
            ( newModel, newModel |> encodeCardViewToValue |> saveCardState )

        ToggleInjury i ->
            let
                beforeStates =
                    model.cardState

                before =
                    Array.get i beforeStates

                afterStates =
                    case before of
                        Just b ->
                            let
                                after =
                                    { b | isDameged = not b.isDameged }
                            in
                            Array.set i after beforeStates

                        -- Todo; なかったときの対応
                        Nothing ->
                            beforeStates

                newModel =
                    { model | cardState = afterStates }
            in
            ( newModel, newModel |> encodeCardViewToValue |> saveCardState )

        GotCardState val ->
            let
                states =
                    case D.decodeString (D.at [ "states" ] (D.array stateDecoder)) val of
                        Ok arr ->
                            arr

                        Err _ ->
                            Array.empty

                ap =
                    case D.decodeString (D.field "ap" D.int) val of
                        Ok n ->
                            n

                        Err _ ->
                            0

                currentAp =
                    case D.decodeString (D.field "currentAp" D.int) val of
                        Ok n ->
                            n

                        Err _ ->
                            0

                newStates =
                    Array.indexedMap
                        (\i state ->
                            case Array.get i states of
                                Just s ->
                                    { state | isUsed = s.isUsed, isDameged = s.isDameged }

                                Nothing ->
                                    state
                        )
                        model.cardState
            in
            ( { model | cardState = newStates, ap = ap, currentAp = currentAp }, Cmd.none )

        InputAp n ->
            let
                newModel =
                    { model | ap = Maybe.withDefault 0 (String.toInt n) }
            in
            ( newModel, newModel |> encodeCardViewToValue |> saveCardState )

        InputCurrentAp n ->
            let
                newModel =
                    { model | currentAp = Maybe.withDefault 0 (String.toInt n) }
            in
            ( newModel, newModel |> encodeCardViewToValue |> saveCardState )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ gotCardState GotCardState
        ]


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
        [ h1 []
            [ text "キャラクターシート" ]
        , div
            [ class "data-area" ]
            [ viewLeft model
            , div []
                [ img [ src model.character.characterImage ] []
                ]
            ]
        ]


viewLeft model =
    div [ style "max-width" "320px" ]
        [ characterCard model.character

        -- , h2 [] [ text "状態" ]
        , div []
            [ inputArea "ap" "行動力" (String.fromInt model.ap) InputAp
            , inputArea "currentAp" "行動値" (String.fromInt model.currentAp) InputCurrentAp
            ]
        , h2 [] [ text "データカード" ]
        , button [ onClick UnUsedAll ] [ text "使用済チェックをすべて外す" ]
        , div [] (Array.indexedMap (\i s -> dataCardSimpleView i s) model.cardState |> Array.toList)
        ]


inputArea : String -> String -> String -> (String -> msg) -> Html msg
inputArea fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "number", class "validate", value val, onInput toMsg ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        ]


dataCardSimpleView i cardState =
    let
        card =
            cardState.card
    in
    div [ class "simple-datacard" ]
        [ div [ class "wrapper" ]
            [ div [ class "base" ]
                [ div [ class "name" ] (text card.cardName :: List.map (\t -> span [ class "tag" ] [ text t.name ]) card.tags)
                , div [ class "timingLabel label" ] [ text "タイミング" ]
                , div [ class "timingValue" ] [ text card.timing ]
                , div [ class "costLabel label" ] [ text "C" ]
                , div [ class "costValue" ] [ text <| String.fromInt card.cost ]
                , div [ class "rangeLabel label" ] [ text "R" ]
                , div [ class "rangeValue" ] [ text (Card.getRange card) ]
                , div [ class "targetLabel label" ] [ text "対象" ]
                , div [ class "targetValue" ] [ text card.target ]
                , div [ class "used" ] [ label [] [ input [ type_ "checkbox", checked cardState.isUsed, onClick (ToggleUsed i) ] [], span [] [ text "使用済" ] ] ]
                , div [ class "injury" ] [ label [] [ input [ type_ "checkbox", class "filled-in", checked cardState.isDameged, onClick (ToggleInjury i) ] [], span [] [ text "負傷" ] ] ]
                , div [ class "effect" ] [ text card.effect ]
                ]
            ]
        ]
