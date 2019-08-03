port module Page.MyPages.EnemyCrud exposing (Model, Msg(..), init, subscriptions, update, view)

import Array
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Json.Decode as D
import Models.Enemy as Enemy exposing (Enemy, PageState)
import Page.Views.EnemyEditor as EnemyEditor
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        []


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , pageState : PageState

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


init : Session.Data -> String -> PageState -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey pageState storeUserId characterId =
    ( initModel session apiKey pageState
    , Cmd.batch [ Cmd.none ]
    )


initModel session apiKey pageState =
    Model session Close apiKey pageState


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
viewHelper model =
    EnemyEditor.view model.pageState
