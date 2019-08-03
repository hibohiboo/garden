port module Page.MyPages.EnemyCrud exposing (Model, Msg(..), init, subscriptions, update, view)

import Array
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI
import Http
import Json.Decode as D
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Html exposing (..)
import Html.Attributes exposing (class)
import Page.Views.EnemyCrud as EnemyCrudView
subscriptions : Sub Msg
subscriptions =
    Sub.batch
        []


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String

    -- , character : Character
    -- , editorModel : EditorModel CharacterEditor.Msg
    }


type Msg
    = ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )


init : Session.Data -> String -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey storeUserId characterId =
    ( initModel session apiKey
    , Cmd.batch [ Cmd.none ]
    )


initModel session apiKey =
    Model session Close apiKey


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass model.naviState
    in
    { title = "更新"
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain <| viewHelper model
        ]
    }


viewHelper : Model -> Html Msg
viewHelper model = EnemyCrudView.view

