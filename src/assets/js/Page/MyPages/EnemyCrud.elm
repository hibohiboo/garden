port module Page.MyPages.EnemyCrud exposing (Model, Msg(..), init, subscriptions, update, view)

import Array
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (class, name, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D
import Models.Enemy as Enemy exposing (EditorModel, Enemy, PageState)
import Page.MyPages.EnemyEditor as EnemyEditor
import Page.Views.EnemyEditor as EnemyEditorView
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.ModalWindow as Modal
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


port crudEnemy : D.Value -> Cmd msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        []


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , pageState : PageState
    , editorModel : EditorModel EnemyEditor.Msg
    , storeUserId : String
    }


type Msg
    = ToggleNavigation
    | EditorMsg EnemyEditor.Msg
    | Save


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        EditorMsg emsg ->
            case emsg of
                -- EnemyEditor.Delete ->
                --     ( model, deleteCharacter (Character.encodeCharacterIdsToValue model.character) )
                _ ->
                    let
                        ( editor, cmd ) =
                            EnemyEditor.update emsg model.editorModel
                    in
                    ( { model | editorModel = editor }, Cmd.map EditorMsg cmd )

        Save ->
            let
                enemy =
                    model.editorModel.editingEnemy
            in
            case model.pageState of
                Enemy.Create ->
                    ( model, crudEnemy <| Enemy.encodeCrudValue <| Enemy.CreateEnemy model.storeUserId enemy )

                Enemy.Read ->
                    ( model, Cmd.none )

                Enemy.Update ->
                    ( model, crudEnemy <| Enemy.encodeCrudValue <| Enemy.UpdateEnemy model.storeUserId enemy )


init : Session.Data -> String -> PageState -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey pageState storeUserId characterId =
    ( initModel session apiKey pageState storeUserId
    , Cmd.batch [ Cmd.none ]
    )


initModel session apiKey pageState storeUserId =
    Model session Close apiKey pageState Enemy.defaultEditorModel storeUserId


view : Model -> Skeleton.Details Msg
view model =
    let
        naviClass =
            getNavigationPageClass model.naviState

        title =
            case model.pageState of
                Enemy.Create ->
                    "新規"

                Enemy.Update ->
                    "更新"

                Enemy.Read ->
                    "View"
    in
    { title = title
    , attrs = [ class naviClass, class "character-sheet" ]
    , kids =
        [ viewMain <| viewHelper title model
        ]
    }


viewHelper : String -> Model -> Html Msg
viewHelper title model =
    div [ class "" ]
        [ h1 []
            [ text title ]
        , div
            [ class "edit-karte" ]
            [ edit model
            ]
        ]


edit : Model -> Html Msg
edit model =
    div [ class "edit-area" ]
        [ Html.map EditorMsg (EnemyEditor.editArea model.editorModel)
        , button [ onClick Save, class "btn waves-effect waves-light", type_ "button", name "save" ]
            [ text "更新"
            , i [ class "material-icons right" ] [ text "send" ]
            ]

        -- , Html.map EditorMsg (deleteModal model.character model.editorModel)
        ]
