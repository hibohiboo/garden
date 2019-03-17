module Page.User exposing (Model, Msg, init, update, view)

import GitHub exposing (Issue, Repo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Skelton exposing (viewLink)
import Url
import Url.Builder


type alias Model =
    { userName : String
    , state : State
    }


type State
    = Init
    | Loaded (List Repo)
    | Error Http.Error


init : String -> ( Model, Cmd Msg )
init userName =
    -- ページの初期化
    -- 最初のModelを作ると同時に、ページの表示に必要なデータをHttpで取得
    ( Model userName Init
    , GitHub.getRepos GotRepos userName
    )


type Msg
    = GotRepos (Result Http.Error (List Repo))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    --- init での Http リクエストの結果が得られたら Model を変更する
    case msg of
        GotRepos (Ok repos) ->
            ( { model | state = Loaded repos }, Cmd.none )

        GotRepos (Err err) ->
            ( { model | state = Error err }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.state of
        Init ->
            text "Loading ..."

        Loaded repos ->
            viewUserPage repos

        Error e ->
            text (Debug.toString e)


viewUserPage : List Repo -> Html msg
viewUserPage repos =
    ul []
        -- ユーザの持っているリポジトリのURLを一覧で表示
        (repos
            |> List.map (\repo -> viewLink (Url.Builder.absolute [ repo.owner, repo.name ] []))
        )
