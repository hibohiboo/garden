port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import GitHub exposing (Issue, Repo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Page.BattleSheet
import Page.CharacterList
import Page.EnemyList
import Page.LoginUser
import Page.Markdown as Markdown
import Page.MyPages.CharacterCreate as CharacterCreate
import Page.MyPages.CharacterUpdate as CharacterUpdate
import Page.MyPages.CharacterView as CharacterView
import Page.Problem as Problem
import Page.RuleBook as RuleBook
import Page.SandBox as SandBox
import Page.Top
import Route exposing (..)
import Session
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


main : Program String Model Msg
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
    , googleSheetApiKey : String
    }


type Page
    = NotFound Session.Data
    | ErrorPage Http.Error
    | TopPage Page.Top.Model
    | MarkdownPage Markdown.Model
    | RuleBookPage RuleBook.Model
    | LoginUserPage Page.LoginUser.Model
    | CharacterCreatePage CharacterCreate.Model
    | CharacterUpdatePage CharacterUpdate.Model
    | CharacterViewPage CharacterView.Model
    | SandBoxPage SandBox.Model
    | CharacterListPage Page.CharacterList.Model
    | EnemyListPage Page.EnemyList.Model
    | BattleSheetPage Page.BattleSheet.Model


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        apiKey =
            case D.decodeString (D.field "googleSheetApiKey" D.string) flags of
                Ok decodedKey ->
                    decodedKey

                Err _ ->
                    ""
    in
    -- 後に画面遷移で使うためのキーを Modelに持たせておく
    Model key (NotFound Session.empty) apiKey
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
    | CharacterCreateMsg CharacterCreate.Msg
    | CharacterUpdateMsg CharacterUpdate.Msg
    | CharacterViewMsg CharacterView.Msg
    | SandBoxMsg SandBox.Msg
    | CharacterListMsg Page.CharacterList.Msg
    | EnemyListMsg Page.EnemyList.Msg
    | BattleSheetMsg Page.BattleSheet.Msg


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

        CharacterCreateMsg ms ->
            case model.page of
                CharacterCreatePage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            CharacterCreate.update ms rmodel
                    in
                    ( { model | page = CharacterCreatePage newmodel }, Cmd.map CharacterCreateMsg newmsg )

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

        SandBoxMsg m ->
            case model.page of
                SandBoxPage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            SandBox.update m rmodel
                    in
                    ( { model | page = SandBoxPage newmodel }, Cmd.map SandBoxMsg newmsg )

                _ ->
                    ( model, Cmd.none )

        CharacterViewMsg ms ->
            case model.page of
                CharacterViewPage rmodel ->
                    let
                        ( newmodel, newmsg ) =
                            CharacterView.update ms rmodel
                    in
                    ( { model | page = CharacterViewPage newmodel }, Cmd.map CharacterViewMsg newmsg )

                _ ->
                    ( model, Cmd.none )

        CharacterListMsg pageCharacterListMsg ->
            case model.page of
                CharacterListPage topModel ->
                    let
                        ( newModel, topCmd ) =
                            Page.CharacterList.update pageCharacterListMsg topModel
                    in
                    ( { model | page = CharacterListPage newModel }, Cmd.map CharacterListMsg topCmd )

                _ ->
                    ( model, Cmd.none )

        EnemyListMsg pageEnemyListMsg ->
            case model.page of
                EnemyListPage topModel ->
                    let
                        ( newModel, topCmd ) =
                            Page.EnemyList.update pageEnemyListMsg topModel
                    in
                    ( { model | page = EnemyListPage newModel }, Cmd.map EnemyListMsg topCmd )

                _ ->
                    ( model, Cmd.none )

        BattleSheetMsg pageBattleSheetMsg ->
            case model.page of
                BattleSheetPage topModel ->
                    let
                        ( newModel, topCmd ) =
                            Page.BattleSheet.update pageBattleSheetMsg topModel
                    in
                    ( { model | page = BattleSheetPage newModel }, Cmd.map BattleSheetMsg topCmd )

                _ ->
                    ( model, Cmd.none )



-- EXIT


exit : Model -> Session.Data
exit model =
    case model.page of
        MarkdownPage m ->
            m.session

        TopPage m ->
            m.session

        RuleBookPage m ->
            m.session

        LoginUserPage m ->
            m.session

        CharacterCreatePage m ->
            m.session

        CharacterUpdatePage m ->
            m.session

        CharacterViewPage m ->
            m.session

        SandBoxPage m ->
            m.session

        NotFound session ->
            session

        ErrorPage _ ->
            Session.empty

        CharacterListPage m ->
            m.session

        EnemyListPage m ->
            m.session

        BattleSheetPage m ->
            m.session



{- パスに応じて各ページを初期化する -}


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    let
        session =
            exit model
    in
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound session }
            , Cmd.none
            )

        Just Route.Top ->
            let
                ( m, cmd ) =
                    Page.Top.init session
            in
            ( { model | page = TopPage m }
            , Cmd.map TopMsg cmd
            )

        Just (Route.RuleBook id) ->
            let
                ( m, cmd ) =
                    RuleBook.init session model.googleSheetApiKey id
            in
            ( { model | page = RuleBookPage m }
            , Cmd.map RuleBookMsg cmd
            )

        Just Route.PrivacyPolicy ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init session "privacy-policy.md" 1.0
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just Route.About ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init session "about.md" 1.0
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just Route.Agreement ->
            let
                ( markdownModel, markdownCmd ) =
                    Markdown.init session "agreement.md" 1.0
            in
            ( { model | page = MarkdownPage markdownModel }
            , Cmd.map MarkdownMsg markdownCmd
            )

        Just Route.LoginUser ->
            let
                ( m, cmd ) =
                    Page.LoginUser.init session
            in
            ( { model | page = LoginUserPage m }
            , Cmd.batch [ Cmd.map LoginUserMsg cmd, urlChangeToLoginPage () ]
            )

        Just (Route.CharacterCreate storeUserId) ->
            let
                ( m, cmd ) =
                    CharacterCreate.init session model.googleSheetApiKey storeUserId
            in
            ( { model | page = CharacterCreatePage m }
            , Cmd.map CharacterCreateMsg cmd
            )

        Just (Route.CharacterUpdate storeUserId characterId) ->
            let
                ( m, cmd ) =
                    CharacterUpdate.init session model.googleSheetApiKey storeUserId characterId
            in
            ( { model | page = CharacterUpdatePage m }
            , Cmd.map CharacterUpdateMsg cmd
            )

        Just (Route.SandBox id) ->
            let
                ( m, cmd ) =
                    SandBox.init session model.googleSheetApiKey id
            in
            ( { model | page = SandBoxPage m }
            , Cmd.map SandBoxMsg cmd
            )

        Just (Route.CharacterView characterId) ->
            let
                ( m, cmd ) =
                    CharacterView.init session model.googleSheetApiKey characterId
            in
            ( { model | page = CharacterViewPage m }
            , Cmd.map CharacterViewMsg cmd
            )

        Just Route.CharacterList ->
            let
                ( m, cmd ) =
                    Page.CharacterList.init session
            in
            ( { model | page = CharacterListPage m }
            , Cmd.map CharacterListMsg cmd
            )

        Just Route.EnemyList ->
            let
                ( m, cmd ) =
                    Page.EnemyList.init session
            in
            ( { model | page = EnemyListPage m }
            , Cmd.map EnemyListMsg cmd
            )

        Just Route.BattleSheet ->
            let
                ( m, cmd ) =
                    Page.BattleSheet.init session
            in
            ( { model | page = BattleSheetPage m }
            , Cmd.map BattleSheetMsg cmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map LoginUserMsg Page.LoginUser.subscriptions
        , Sub.map CharacterUpdateMsg CharacterUpdate.subscriptions
        , Sub.map CharacterCreateMsg CharacterCreate.subscriptions
        , Sub.map CharacterViewMsg CharacterView.subscriptions
        ]



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

        NotFound _ ->
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

        CharacterCreatePage m ->
            Skeleton.view CharacterCreateMsg (CharacterCreate.view m)

        CharacterUpdatePage m ->
            Skeleton.view CharacterUpdateMsg (CharacterUpdate.view m)

        CharacterViewPage m ->
            Skeleton.view CharacterViewMsg (CharacterView.view m)

        SandBoxPage m ->
            Skeleton.view SandBoxMsg (SandBox.view m)

        CharacterListPage m ->
            Skeleton.view CharacterListMsg (Page.CharacterList.view m)

        EnemyListPage m ->
            Skeleton.view EnemyListMsg (Page.EnemyList.view m)

        BattleSheetPage m ->
            Skeleton.view BattleSheetMsg (Page.BattleSheet.view m)


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
