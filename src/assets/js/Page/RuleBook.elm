port module Page.RuleBook exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI exposing (Organ)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Page.Rules.Base exposing (..)
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


port openModal : () -> Cmd msg


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , googleSheetApiKey : String
    , id : String
    , modalTitle : String
    , modalContents : Html Msg
    }


init : Session.Data -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey s =
    case s of
        Just id ->
            ( Model session Close apiKey id "" (text ""), jumpToBottom id )

        Nothing ->
            ( initModel session apiKey
            , Cmd.none
            )


initModel : Session.Data -> String -> Model
initModel session apiKey =
    Model session Close apiKey "" "異形器官一覧" (text "")


type Msg
    = ToggleNavigation
    | NoOp
    | PageAnchor String
    | ModalOrgan String
    | GotOrgans (Result Http.Error String)


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
            case Session.getOrgans model.session of
                Just sheet ->
                    ( updateOrgansListModel { model | modalTitle = title } sheet, openModal () )

                Nothing ->
                    ( { model | modalTitle = title }, Session.fetchOrgans GotOrgans model.googleSheetApiKey )

        GotOrgans (Ok json) ->
            ( updateOrgansListModel model json, openModal () )

        GotOrgans (Err _) ->
            ( model, Cmd.none )


updateOrgansListModel : Model -> String -> Model
updateOrgansListModel model json =
    case GSAPI.organsInObjectDecodeFromString json of
        Ok organs ->
            { model
                | modalContents = organList organs
                , session = Session.addOrgans model.session json
            }

        Err _ ->
            { model | modalContents = text "error" }


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

        -- elmの遷移と干渉して、 close のときにM.Modal._modalsOpenの値が １から0にならない
        -- , div [ class "modal-footer" ]
        --     [ a [ href "#", class "modal-close waves-effect waves-green btn-flat" ] [ text "閉じる" ]
        --     ]
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
            , section [ id "character", class "content-doc" ]
                [ h1 []
                    [ text "キャラクター" ]
                , p
                    []
                    [ text """
プレイヤーの分身であるキャラクター（以下、PC)は、特異な力を持つ子供となる。
""" ]
                , h2 [] [ text "1. 変異器官の決定" ]
                , p
                    []
                    [ text """
異能の発生源となる変異器官を選択する。
""" ]
                ]
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
