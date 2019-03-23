port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import GitHub exposing (Issue, Repo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page.LoginUser
import Page.Markdown as Markdown
import Page.MyPages.CharacterNew as CharacterNew
import Page.MyPages.CharacterUpdate as CharacterUpdate
import Page.Problem as Problem
import Page.RuleBook as RuleBook
import Page.Top
import Route exposing (..)
import Skeleton exposing (Details, view)
import Url
import Url.Builder



-- 初期化完了をjsに伝える


port initializedToJs : () -> Cmd msg



-- 画面遷移をjsに伝える


port urlChangeToJs : () -> Cmd msg



-- ログインページへの遷移


port urlChangeToLoginPage : () -> Cmd msg



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
    | MarkdownPage Markdown.Model
    | RuleBookPage RuleBook.Model
    | LoginUserPage Page.LoginUser.Model
    | CharacterNewPage CharacterNew.Model
    | CharacterUpdatePage CharacterUpdate.Model


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
    | MarkdownMsg Markdown.Msg
    | TopMsg Page.Top.Msg
    | RuleBookMsg RuleBook.Msg
    | LoginUserMsg Page.LoginUser.Msg
    | CharacterNewMsg CharacterNew.Msg
    | CharacterUpdateMsg CharacterUpdate.Msg


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

        --MarkdownMsgページのメッセージが来たとき
        MarkdownMsg markdownMsg ->
            -- 現在表示中のページが
            case model.page of
                -- MarkdownPageであれば、
                MarkdownPage markdownModel ->
                    --MarkdownPage ページのupdate処理を行う
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

        RuleBookMsg rmsg ->
            case model.page of
                RuleBookPage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            RuleBook.update rmsg rmodel
                    in
                    ( { model | page = RuleBookPage newmodel }, Cmd.map RuleBookMsg newmsg )

                _ ->
                    ( model, Cmd.none )

        LoginUserMsg rmsg ->
            case model.page of
                LoginUserPage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            Page.LoginUser.update rmsg rmodel
                    in
                    ( { model | page = LoginUserPage newmodel }, Cmd.map LoginUserMsg newmsg )

                _ ->
                    ( model, Cmd.none )

        CharacterNewMsg ms ->
            case model.page of
                CharacterNewPage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            CharacterNew.update ms rmodel
                    in
                    ( { model | page = CharacterNewPage newmodel }, Cmd.map CharacterNewMsg newmsg )

                _ ->
                    ( model, Cmd.none )

        CharacterUpdateMsg ms ->
            case model.page of
                CharacterUpdatePage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            CharacterUpdate.update ms rmodel
                    in
                    ( { model | page = CharacterUpdatePage newmodel }, Cmd.map CharacterUpdateMsg newmsg )

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

        Just (Route.RuleBook id) ->
            let
                ( m, cmd ) =
                    RuleBook.init id
            in
            ( { model | page = RuleBookPage m }
            , Cmd.map RuleBookMsg cmd
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

        Just Route.Agreement ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init "agreement.md"
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just Route.LoginUser ->
            let
                ( m, cmd ) =
                    Page.LoginUser.init
            in
            ( { model | page = LoginUserPage m }
            , Cmd.batch [ Cmd.map LoginUserMsg cmd, urlChangeToLoginPage () ]
            )

        Just Route.CharacterNew ->
            let
                ( m, cmd ) =
                    CharacterNew.init
            in
            ( { model | page = CharacterNewPage m }
            , Cmd.map CharacterNewMsg cmd
            )

        Just (Route.CharacterUpdate id) ->
            let
                ( m, cmd ) =
                    CharacterUpdate.init id
            in
            ( { model | page = CharacterUpdatePage m }
            , Cmd.map CharacterUpdateMsg cmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map LoginUserMsg Page.LoginUser.subscriptions



-- VIEW


styles : List (Attribute msg)
styles =
    [ style "padding" "6em 0"
    ]


view : Model -> Browser.Document Msg
view model =
    case model.page of
        ErrorPage error ->
            Skeleton.view never
                { title = "Garden - 箱庭の島の子供たち"
                , attrs = Problem.styles
                , kids = [ viewError error ]
                }

        NotFound ->
            Skeleton.view never
                { title = "Not Found"
                , attrs = Problem.styles
                , kids = Problem.notFound
                }

        RuleBookPage m ->
            Skeleton.view RuleBookMsg (RuleBook.view m)

        TopPage m ->
            Skeleton.view TopMsg (Page.Top.view m)

        MarkdownPage markdownModel ->
            Skeleton.view MarkdownMsg
                (Markdown.view
                    markdownModel
                )

        LoginUserPage m ->
            Skeleton.view LoginUserMsg (Page.LoginUser.view m)

        CharacterNewPage m ->
            Skeleton.view CharacterNewMsg (CharacterNew.view m)

        CharacterUpdatePage m ->
            Skeleton.view CharacterUpdateMsg (CharacterUpdate.view m)


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
