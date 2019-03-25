port module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Rules.Base exposing (..)
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


port openModal : () -> Cmd msg


type alias Model =
    { naviState : NaviState
    , id : String
    , modalTitle : String
    , modalContentsUrl : String
    }


init : Maybe String -> ( Model, Cmd Msg )
init s =
    case s of
        Just id ->
            ( Model Close id "" "", jumpToBottom id )

        Nothing ->
            ( initModel
            , Cmd.none
            )


initModel : Model
initModel =
    Model Close "" "異形器官一覧" ""


organList : String -> Html Msg
organList url =
    div []
        [ ul []
            [ li [] [ text "翼" ]
            ]
        ]


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String
    | ModalOrgan String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        PageAnchor id ->
            ( model, Navigation.load id )

        ModalOrgan title ->
            ( { model | modalTitle = title }, openModal () )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "基本ルール"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain viewRulebook
        , viewNavi (List.map (\( value, text ) -> NavigationMenu value text) tableOfContents)
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        , modalWindow model.modalTitle (organList model.modalContentsUrl)
        ]
    }


modalWindow : String -> Html msg -> Html msg
modalWindow title content =
    div [ id "mainModal", class "modal" ]
        [ div [ class "modal-content" ]
            [ h4 [] [ text title ]
            , p [] [ content ]
            ]
        , div [ class "modal-footer" ]
            [ a [ href "#!", class "modal-close waves-effect waves-green btn-flat" ] [ text "閉じる" ]
            ]
        ]


viewNavi : List NavigationMenu -> Html Msg
viewNavi menues =
    let
        navigations =
            List.map
                (\menu ->
                    li []
                        [ a [ onClick (PageAnchor menu.src) ] [ text menu.text ]
                        ]
                )
                menues
    in
    nav [ class "page-nav" ]
        [ ul []
            navigations
        ]


tableOfContents : List ( String, String )
tableOfContents =
    [ ( "/", "トップに戻る" ), ( "#first", "はじめに" ), ( "#world", "ワールド" ) ]


viewRulebook : Html Msg
viewRulebook =
    div []
        [ div [ class "rulebook-title" ] [ div [] [ text Terms.trpgGenre ], h1 [] [ text "Garden 基本ルールブック" ] ]
        , div [ class "content" ]
            [ first
            , world
            , character
            , a [ onClick (ModalOrgan "変異器官一覧"), class "waves-effect waves-light btn modal-trigger", href "#" ] [ text "変異器官一覧" ]
            ]
        ]


jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)
