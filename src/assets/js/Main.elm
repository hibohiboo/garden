port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import GitHub exposing (Issue, Repo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page.GitHubUser exposing (..)
import Page.Markdown as Markdown
import Page.Problem as Problem
import Page.Repo exposing (..)
import Page.RuleBook exposing (..)
import Page.Top exposing (..)
import Route exposing (..)
import Skeleton exposing (Details, view)
import Url
import Url.Builder



-- 初期化完了をjsに伝える


port initializedToJs : () -> Cmd msg



-- 画面遷移をjsに伝える


port urlChangeToJs : () -> Cmd msg



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | ErrorPage Http.Error
    | TopPage Page.Top.Model
    | GitHubUserPage Page.GitHubUser.Model
    | RepoPage Page.Repo.Model
    | MarkdownPage Markdown.Model
    | RuleBook


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    -- 後に画面遷移で使うためのキーを Modelに持たせておく
    Model key (TopPage Page.Top.initModel)
        -- はじめてページを訪れた時も忘れずにページの初期化を行う
        |> goTo (Route.parse url)
        |> initialized


{-| 初期化後をjsに伝える
-}
initialized : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initialized ( model, msg ) =
    ( model, Cmd.batch [ msg, initializedToJs () ] )



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Loaded (Result Http.Error Page)
    | RepoMsg Page.Repo.Msg
    | GitHubUserMsg Page.GitHubUser.Msg
    | MarkdownMsg Markdown.Msg
    | TopMsg Page.Top.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            -- ページの初期化をヘルパー関数に移譲
            goTo (Route.parse url) model
                -- 画面遷移をjsに伝える
                |> (\( newModel, newMsg ) ->
                        ( newModel, Cmd.batch [ newMsg, urlChangeToJs () ] )
                   )

        -- ページの内容を非同期で取得した時の共通処理
        Loaded result ->
            ( { model
                | page =
                    case result of
                        Ok page ->
                            page

                        Err e ->
                            ErrorPage e
              }
            , Cmd.none
            )

        -- Repoページのメッセージが来たとき
        RepoMsg repoMsg ->
            -- 現在表示中のページが
            case model.page of
                -- RepoPageであれば、
                RepoPage repoModel ->
                    -- Repoページのupdate処理を行う
                    let
                        ( newRepoModel, topCmd ) =
                            Page.Repo.update repoMsg repoModel
                    in
                    ( { model | page = RepoPage newRepoModel }, Cmd.map RepoMsg topCmd )

                _ ->
                    ( model, Cmd.none )

        -- GitHubUserページのメッセージが来たとき
        GitHubUserMsg gitHubUserMsg ->
            -- 現在表示中のページが
            case model.page of
                -- GitHubUserPageであれば、
                GitHubUserPage gitHubUserModel ->
                    -- GitHubUserページのupdate処理を行う
                    let
                        ( newGitHubUserModel, gitHubUserCmd ) =
                            Page.GitHubUser.update gitHubUserMsg gitHubUserModel
                    in
                    ( { model | page = GitHubUserPage newGitHubUserModel }, Cmd.map GitHubUserMsg gitHubUserCmd )

                _ ->
                    ( model, Cmd.none )

        MarkdownMsg markdownMsg ->
            case model.page of
                MarkdownPage markdownModel ->
                    let
                        ( newMarkdownModel, markdownCmd ) =
                            Markdown.update markdownMsg markdownModel
                    in
                    ( { model | page = MarkdownPage newMarkdownModel }, Cmd.map MarkdownMsg markdownCmd )

                _ ->
                    ( model, Cmd.none )

        TopMsg pageTopMsg ->
            case model.page of
                TopPage topModel ->
                    let
                        ( newModel, topCmd ) =
                            Page.Top.update pageTopMsg topModel
                    in
                    ( { model | page = TopPage newModel }, Cmd.map TopMsg topCmd )

                _ ->
                    ( model, Cmd.none )



{- パスに応じて各ページを初期化する -}


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )

        Just Route.Top ->
            let
                ( m, cmd ) =
                    Page.Top.init
            in
            ( { model | page = TopPage m }
            , Cmd.map TopMsg cmd
            )

        Just Route.RuleBook ->
            ( { model | page = RuleBook }
            , Cmd.none
            )

        Just Route.PrivacyPolicy ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init "privacy-policy.md"
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just Route.About ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init "about.md"
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just (Route.GitHubUser gitHubUserName) ->
            -- GitHubUser ページの初期化
            let
                ( gitHubUserModel, gitHubUserCmd ) =
                    Page.GitHubUser.init gitHubUserName
            in
            ( { model | page = GitHubUserPage gitHubUserModel }
            , Cmd.map GitHubUserMsg gitHubUserCmd
            )

        Just (Route.Repo gitHubUserName projectName) ->
            -- Repo ページの初期化
            let
                ( repoModel, repoCmd ) =
                    Page.Repo.init gitHubUserName projectName
            in
            ( { model | page = RepoPage repoModel }
            , Cmd.map RepoMsg repoCmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


styles : List (Attribute msg)
styles =
    [ style "padding" "6em 0"
    ]


view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFound ->
            Skeleton.view never
                { title = "Not Found"
                , attrs = Problem.styles
                , kids = Problem.notFound
                }

        RuleBook ->
            Skeleton.view never Page.RuleBook.view

        TopPage m ->
            Skeleton.view TopMsg (Page.Top.view m)

        MarkdownPage markdownModel ->
            Skeleton.view MarkdownMsg
                (Markdown.view
                    markdownModel
                )

        _ ->
            { title = "Garden - 箱庭の島の子供たち"
            , body =
                [ a [ href "/" ] [ h1 [] [ text "Garden - 箱庭の島の子供たち" ] ]
                , case model.page of
                    NotFound ->
                        viewNotFound

                    ErrorPage error ->
                        viewError error

                    GitHubUserPage gitHubUserPageModel ->
                        -- GitHubUserページのview関数を呼ぶ
                        Page.GitHubUser.view gitHubUserPageModel
                            |> Html.map GitHubUserMsg

                    RepoPage repoPageModel ->
                        -- Repoページのview関数を呼ぶ
                        Page.Repo.view repoPageModel
                            |> Html.map RepoMsg

                    _ ->
                        text "parse error"
                ]
            }


{-| NotFound ページ
-}
viewNotFound : Html msg
viewNotFound =
    text "not found"


{-| エラーページ
-}
viewError : Http.Error -> Html msg
viewError error =
    case error of
        Http.BadBody message ->
            pre [] [ text message ]

        _ ->
            text "error"



--text (Debug.toString error)
