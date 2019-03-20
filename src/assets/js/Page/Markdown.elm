module Page.Markdown exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Markdown
import Skeleton exposing (NaviState(..), NavigationMenu, getNavigationPageClass, viewLink, viewMain, viewNav)
import Url
import Url.Builder


type alias Model =
    { fileName : String
    , state : State
    , naviState : NaviState
    }


type State
    = Init
    | Loaded String
    | Error Http.Error


init : String -> ( Model, Cmd Msg )
init fileName =
    -- ページの初期化
    -- 最初のModelを作ると同時に、ページの表示に必要なデータをHttpで取得
    ( Model fileName Init Close
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
    | ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    --- init での Http リクエストの結果が得られたら Model を変更する
    case msg of
        GotMarkdown (Ok markdown) ->
            ( { model | state = Loaded markdown }, Cmd.none )

        GotMarkdown (Err err) ->
            ( { model | state = Error err }, Cmd.none )

        ToggleNavigation ->
            let
                ns =
                    case model.naviState of
                        Close ->
                            Open

                        Open ->
                            Close
            in
            ( { model | naviState = ns }, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    case model.state of
        Init ->
            viewSkeleton (text "Loading ...") naviClass

        Loaded markdown ->
            viewSkeleton (viewHelper markdown) naviClass

        Error e ->
            viewSkeleton (text "error") naviClass



--(text (Debug.toString e))


viewSkeleton : Html Msg -> String -> Skeleton.Details Msg
viewSkeleton html naviClass =
    { title = "プライバシーポリシー"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain html
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , button [ onClick ToggleNavigation, type_ "button", class "navi-btn page-btn" ] [ span [ class "fas fa-bars", title "メニューを開く" ] [] ]
        , button [ onClick ToggleNavigation, type_ "button", class "navi-btn page-btn-close" ] [ span [ class "fas fa-times", title "メニューを閉じる" ] [] ]
        ]
    }


viewHelper : String -> Html msg
viewHelper markdown =
    div []
        [ Markdown.toHtml [ class "content" ] markdown
        ]
