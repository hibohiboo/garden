module Page.Markdown exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Markdown
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias Model =
    { session : Session.Data
    , fileName : String
    , version : Session.Version
    , state : State
    , naviState : NaviState
    }


type State
    = Init
    | Loaded String
    | Error Http.Error


init : Session.Data -> String -> Session.Version -> ( Model, Cmd Msg )
init session fileName version =
    case Session.getMarkdown session fileName version of
        Just markdown ->
            let
                model =
                    Model session fileName version (Loaded markdown) Close
            in
            ( model
            , Cmd.none
            )

        Nothing ->
            -- ページの初期化
            -- 最初のModelを作ると同時に、ページの表示に必要なデータをHttpで取得
            ( Model session fileName version Init Close
            , Session.fetchMarkdown GotMarkdown fileName
            )


type Msg
    = GotMarkdown (Result Http.Error String)
    | ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    --- init での Http リクエストの結果が得られたら Model を変更する
    case msg of
        GotMarkdown (Ok markdown) ->
            ( { model
                | state = Loaded markdown
                , session = Session.addMarkdown model.fileName model.version markdown model.session
              }
            , Cmd.none
            )

        GotMarkdown (Err err) ->
            ( { model | state = Error err }, Cmd.none )

        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )


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
