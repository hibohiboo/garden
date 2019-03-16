module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D exposing (Decoder)
import Route exposing (..)
import Url
import Url.Builder



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
    | TopPage
    | UserPage (List Repo)
    | RepoPage (List Issue)


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    -- 後に画面遷移で使うためのキーを Modelに持たせておく
    Model key TopPage
        -- はじめてページを訪れた時も忘れずにページの初期化を行う
        |> goTo (Route.parse url)



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Loaded (Result Http.Error Page)


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



{- パスに応じて各ページを初期化する -}


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )

        Just Route.Top ->
            ( { model | page = TopPage }
            , Cmd.none
            )

        Just (Route.User userName) ->
            -- UserPage を取得
            ( model
            , Http.get
                { url =
                    Url.Builder.crossOrigin "https://api.github.com" [ "users", userName, "repos" ] []
                , expect = Http.expectJson (Result.map UserPage >> Loaded) reposDecoder
                }
            )

        Just (Route.Repo userName projectName) ->
            -- RepoPageを取得
            ( model
            , Http.get
                { url = Url.Builder.crossOrigin "https://api.github.com" [ "repos", userName, projectName, "issues" ] []
                , expect = Http.expectJson (Result.map RepoPage >> Loaded) issuesDecoder
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "URL Interceptor"
    , body =
        [ a [ href "/" ] [ h1 [] [ text "My github view" ] ]
        , case model.page of
            NotFound ->
                viewNotFound

            ErrorPage error ->
                viewError error

            TopPage ->
                viewTopPage

            UserPage repos ->
                viewUserPage repos

            RepoPage issues ->
                viewRepoPage issues
        ]
    }


{-| NotFound ページ
-}
viewNotFound : Html Msg
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
            text (Debug.toString error)


viewTopPage : Html Msg
viewTopPage =
    ul []
        [ viewLink (Url.Builder.absolute [ "elm" ] [])
        , viewLink (Url.Builder.absolute [ "evancz" ] [])
        ]


viewUserPage : List Repo -> Html msg
viewUserPage repos =
    ul []
        -- ユーザの持っているリポジトリのURLを一覧で表示
        (repos
            |> List.map (\repo -> viewLink (Url.Builder.absolute [ repo.owner, repo.name ] []))
        )


viewRepoPage : List Issue -> Html msg
viewRepoPage issues =
    ul [] (List.map viewIssue issues)


viewIssue : Issue -> Html msg
viewIssue issue =
    li []
        [ span [] [ text ("[" ++ issue.state ++ "]") ]
        , span [] [ text ("#" ++ String.fromInt issue.number) ]
        , span [] [ text issue.title ]
        ]


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]



-- GITHUB


type alias Repo =
    { name : String
    , description : String
    , language : Maybe String
    , owner : String
    , fork : Int
    , star : Int
    , watch : Int
    }


type alias Issue =
    { number : Int
    , title : String
    , state : String
    }


reposDecoder : Decoder (List Repo)
reposDecoder =
    D.list repoDecoder


repoDecoder : Decoder Repo
repoDecoder =
    D.map7 Repo
        (D.field "name" D.string)
        (D.field "description" D.string)
        (D.maybe (D.field "language" D.string))
        (D.at [ "owner", "login" ] D.string)
        (D.field "forks" D.int)
        (D.field "stargazers_count" D.int)
        (D.field "watchers_count" D.int)


issuesDecoder : Decoder (List Issue)
issuesDecoder =
    D.list issueDecoder


issueDecoder : Decoder Issue
issueDecoder =
    D.map3 Issue
        (D.field "number" D.int)
        (D.field "title" D.string)
        (D.field "state" D.string)
