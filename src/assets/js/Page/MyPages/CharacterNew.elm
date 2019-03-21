port module Page.MyPages.CharacterNew exposing (Model, Msg, init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


port saveNewCharacter : String -> Cmd msg


type alias Character =
    { name : String
    , kana : String
    }


type alias Model =
    { naviState : NaviState
    , character : Character
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )


initModel : Model
initModel =
    Model Close (Character "" "")


type Msg
    = ToggleNavigation
    | InputName String
    | InputKana String
    | Save


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        -- キャラクターのモデルを更新
        char =
            model.character
    in
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        InputName s ->
            let
                c =
                    { char | name = s }
            in
            ( { model | character = c }, Cmd.none )

        InputKana s ->
            let
                c =
                    { char | kana = s }
            in
            ( { model | character = c }, Cmd.none )

        Save ->
            ( model, saveNewCharacter "a" )


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
            [ editArea model
            , karte model
            ]
        ]


editArea model =
    div [ class "edit-area" ]
        [ div [ class "input-field" ]
            [ input [ placeholder "名前", id "name", type_ "text", class "validate", value model.character.name, onInput InputName ] []
            , label [ for "name" ] [ text "名前" ]
            ]
        , div [ class "input-field" ]
            [ input [ placeholder "フリガナ", id "kana", type_ "text", class "validate", value model.character.kana, onInput InputKana ] []
            , label [ for "kana" ] [ text "フリガナ" ]
            ]
        , button [ onClick Save, class "btn waves-effect waves-light", type_ "button", name "save" ]
            [ text "保存"
            , i [ class "material-icons right" ] [ text "send" ]
            ]
        ]


karte model =
    let
        char =
            model.character
    in
    div [ class "karte" ]
        [ div [ class "label-personal" ] [ text "異能因子発現個体" ]
        , div [ class "label-kana" ] [ text "フリガナ" ]
        , div [ class "kana" ] [ text char.kana ]
        , div [ class "label-name" ] [ text "名前" ]
        , div [ class "name" ] [ text char.name ]
        , div [ class "outer-line" ] []
        ]
