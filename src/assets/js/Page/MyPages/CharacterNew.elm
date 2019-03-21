module Page.MyPages.CharacterNew exposing (Model, Msg, init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


type alias Model =
    { naviState : NaviState
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )


initModel : Model
initModel =
    Model Close


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
    { title = "新規作成"
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain viewHelper
        ]
    }


viewHelper : Html msg
viewHelper =
    div [ class "" ]
        [ h1 [] [ text "新規作成" ]
        , inputField
        ]


inputField =
    div [ class "edit-area" ]
        [ div [ class "input-field" ]
            [ input [ placeholder "名前", id "name", type_ "text", class "validate" ] []
            , label [ for "name" ] [ text "名前" ]
            ]
        ]
