port module Page.MyPages.CharacterCreate exposing (Model, Msg, init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Character exposing (..)
import Page.MyPages.CharacterEditor as CharacterEditor exposing (editArea)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


port saveNewCharacter : String -> Cmd msg


type alias Model =
    { naviState : NaviState
    , character : Character
    }


init : String -> ( Model, Cmd Msg )
init storeUserId =
    ( initModel storeUserId
    , Cmd.none
    )


initModel : String -> Model
initModel storeUserId =
    Model Close (initCharacter storeUserId)


type Msg
    = ToggleNavigation
    | EditorMsg CharacterEditor.Msg
    | Save


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        -- キャラクターデータの更新
        EditorMsg emsg ->
            let
                ( m, s ) =
                    CharacterEditor.update emsg model.character
            in
            ( { model | character = m }, Cmd.map EditorMsg s )

        Save ->
            ( model, model.character |> encodeCharacter |> saveNewCharacter )


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
            , karte model
            ]
        ]


edit : Model -> Html Msg
edit model =
    div [ class "edit-area" ]
        [ Html.map EditorMsg (editArea model.character)
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
