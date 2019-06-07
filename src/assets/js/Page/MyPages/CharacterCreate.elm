port module Page.MyPages.CharacterCreate exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Models.Card as Card
import Models.Character exposing (..)
import Models.CharacterEditor as CharacterEditor exposing (..)
import Page.MyPages.CharacterEditor as CharacterEditor exposing (editArea)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


port saveNewCharacter : String -> Cmd msg


port createdCharacter : (Bool -> msg) -> Sub msg


port initNewCharacter : () -> Cmd msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ createdCharacter CreatedCharacter
        ]


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , character : Character
    , editorModel : EditorModel CharacterEditor.Msg
    }


init : Session.Data -> String -> String -> ( Model, Cmd Msg )
init session apiKey storeUserId =
    let
        cards =
            case Session.getCards session of
                Just sheet ->
                    case Card.cardDataListDecodeFromJson sheet of
                        Ok list ->
                            list

                        Err _ ->
                            []

                Nothing ->
                    []

        cardsCmd =
            if cards == [] then
                Session.fetchCards GotCards apiKey

            else
                initNewCharacter ()
    in
    ( Model session Close (initCharacter storeUserId) (EditorModel [] [] cards "" "" (text ""))
    , Cmd.batch [ cardsCmd ]
    )


type Msg
    = ToggleNavigation
    | EditorMsg CharacterEditor.Msg
    | Save
    | CreatedCharacter Bool
    | GotCards (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        -- キャラクターデータの更新
        EditorMsg emsg ->
            let
                ( ( char, editor ), s ) =
                    CharacterEditor.update emsg model.character model.editorModel
            in
            ( { model | character = char }, Cmd.map EditorMsg s )

        Save ->
            ( model, model.character |> encodeCharacter |> saveNewCharacter )

        CreatedCharacter _ ->
            ( model, Navigation.load (Url.Builder.absolute [ "mypage" ] []) )

        GotCards (Ok json) ->
            case Card.cardDataListDecodeFromJson json of
                Ok cards ->
                    let
                        oldEditorModel =
                            model.editorModel

                        newEditorModel =
                            { oldEditorModel | cards = cards }
                    in
                    ( { model
                        | editorModel = newEditorModel
                        , session = Session.addCards model.session json
                      }
                    , initNewCharacter ()
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotCards (Err _) ->
            ( model, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "新規作成"
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain <| viewHelper model
        ]
    }


viewHelper : Model -> Html Msg
viewHelper model =
    div [ class "" ]
        [ h1 []
            [ text "新規作成" ]
        , div
            [ class "edit-karte" ]
            [ edit model

            -- , karte model
            ]
        ]


edit : Model -> Html Msg
edit model =
    div [ class "edit-area" ]
        [ Html.map EditorMsg (editArea model.character model.editorModel)
        , button [ onClick Save, class "btn waves-effect waves-light", type_ "button", name "save" ]
            [ text "保存"
            , i [ class "material-icons right" ] [ text "send" ]
            ]
        ]


karte : Model -> Html Msg
karte model =
    let
        char =
            model.character
    in
    div [ class "karte" ]
        [ div [ class "label-personal" ] [ text "個体識別用情報" ]
        , div [ class "label-kana" ] [ text "フリガナ" ]
        , div [ class "kana" ] [ text char.kana ]
        , div [ class "label-name" ] [ text "名前" ]
        , div [ class "name" ] [ text char.name ]
        , div [ class "outer-line" ] []
        ]
