module Page.Markdown exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Markdown
import Skeleton
import Url
import Url.Builder


type alias Model =
    { fileName : String
    , state : State
    }


type State
    = Init
    | Loaded String
    | Error Http.Error


init : String -> ( Model, Cmd Msg )
init fileName =
    -- ページの初期化
    -- 最初のModelを作ると同時に、ページの表示に必要なデータをHttpで取得
    ( Model fileName Init
    , getMarkdown GotMarkdown fileName
    )


getMarkdown : (Result Http.Error String -> msg) -> String -> Cmd msg
getMarkdown toMsg fileName =
    Http.get
        { url = markdownUrl fileName
        , expect = Http.expectString toMsg
        }


markdownUrl : String -> String
markdownUrl fileName =
    Url.Builder.absolute [ "assets", "markdown", fileName ] []


type Msg
    = GotMarkdown (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    --- init での Http リクエストの結果が得られたら Model を変更する
    case msg of
        GotMarkdown (Ok markdown) ->
            ( { model | state = Loaded markdown }, Cmd.none )

        GotMarkdown (Err err) ->
            ( { model | state = Error err }, Cmd.none )


view : Model -> Skeleton.Details msg
view model =
    case model.state of
        Init ->
            viewSkeleton (text "Loading ...")

        Loaded markdown ->
            viewSkeleton (viewHelper markdown)

        Error e ->
            viewSkeleton (text "error")



--(text (Debug.toString e))


viewSkeleton : Html msg -> Skeleton.Details msg
viewSkeleton html =
    { title = "プライバシーポリシー"
    , attrs = []
    , kids =
        [ html
        ]
    }


viewHelper : String -> Html msg
viewHelper markdown =
    div []
        [ Markdown.toHtml [ class "content" ] markdown
        ]
