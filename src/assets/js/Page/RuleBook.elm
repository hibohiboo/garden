port module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI exposing (Organ)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
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
    , googleSheetApiKey : String
    , id : String
    , modalTitle : String
    , modalContents : Html Msg
    }


init : String -> Maybe String -> ( Model, Cmd Msg )
init apiKey s =
    case s of
        Just id ->
            ( Model Close apiKey id "" (text ""), jumpToBottom id )

        Nothing ->
            ( initModel apiKey
            , Cmd.none
            )


initModel : String -> Model
initModel apiKey =
    Model Close apiKey "" "異形器官一覧" (text "")


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String
    | ModalOrgan String
    | GotOrgans (Result Http.Error (List Organ))


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
            ( { model | modalTitle = title }, GSAPI.getOrgans GotOrgans model.googleSheetApiKey "1cyGpEw4GPI2k5snngBPKz7rfETklKdSaIBqQKnTta1w" "organList!A2:B11" )

        GotOrgans (Ok organs) ->
            let
                organTable =
                    organList organs
            in
            ( { model | modalContents = organTable }, openModal () )

        GotOrgans (Err _) ->
            ( model, Cmd.none )


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
        , modalWindow model.modalTitle model.modalContents
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
            , a [ onClick (ModalOrgan "変異器官一覧"), class "waves-effect waves-light btn", href "#" ] [ text "変異器官一覧" ]
            ]
        ]


organList : List Organ -> Html Msg
organList organs =
    dl [ class "collection with-header" ]
        (List.indexedMap
            (\i organ ->
                [ dt [] [ text (String.fromInt (i + 1) ++ " : " ++ organ.name) ]
                , dd [] [ text organ.description ]
                ]
            )
            organs
            |> List.concat
        )


jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Dom.getViewportOf id
        |> Task.andThen (\info -> Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)
