port module Page.SandBox exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Navigation
import GoogleSpreadSheetApi as GSAPI
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Models.SandBox.Card as Card
import Session
import Skeleton exposing (viewLink, viewMain)
import Task exposing (..)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (viewNav)
import Utils.TextStrings as Tx


type alias Model =
    { session : Session.Data
    , googleSheetApiKey : String
    , cards : List Card.CardData
    , searchCardKind : String
    }


init : Session.Data -> String -> String -> ( Model, Cmd Msg )
init session apiKey id =
    let
        cards =
            case Session.getUserCards session of
                Just json ->
                    case Card.cardDataListDecodeFromJson json of
                        Ok list ->
                            list

                        Err _ ->
                            []

                _ ->
                    []

        cmd =
            if cards == [] then
                Session.fetchUserCards GotCards apiKey

            else
                Cmd.none
    in
    ( Model session apiKey cards "", Cmd.batch [ cmd ] )


initModel : Session.Data -> String -> Model
initModel session apiKey =
    Model session apiKey [] ""


view : Model -> Skeleton.Details Msg
view model =
    { title = "お試し"
    , attrs = []
    , kids =
        [ viewMain (viewSandBox model.cards)
        , viewNav []
        ]
    }


type Msg
    = NoOp
    | GotCards (Result Http.Error String)


viewSandBox : List Card.CardData -> Html Msg
viewSandBox cards =
    div []
        [ h4 [] [ text "ユーザカードページ" ]
        , p [] [ text "ここでは自由にカード作成のおためしができます。" ]
        , p [] [ text "以下のGoogleスプレッドシートを編集したのち、このページを読み込みなおしてください。" ]
        , p []
            [ a [ href "https://docs.google.com/spreadsheets/d/1JFGLFnPtBfPJdt7YccFSxki2MsqNUzUQmlyIGX4gyZE/edit#gid=0", target "_blank" ] [ text "google spread sheet" ]
            ]
        , p [] [ text "良識を守ってお使いください。" ]
        , div [ class "card-list" ] (List.map Card.cardView cards)
        , p [ style "font-size" "0.5rem" ] [ text "著作権を侵害するような行為は禁止いたします。ユーザが作成したデータの責任はユーザが負います。" ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotCards (Ok json) ->
            ( updateCardListModel model json Session.addUserCards, Cmd.none )

        GotCards (Err _) ->
            ( model, Cmd.none )


updateCardListModel : Model -> String -> (Session.Data -> String -> Session.Data) -> Model
updateCardListModel model json addSession =
    case Card.cardDataListDecodeFromJson json of
        Ok cards ->
            let
                filteredCards =
                    if model.searchCardKind == "" then
                        List.filter (\card -> card.kind /= "" && card.deleteFlag == 0) cards

                    else
                        List.filter (\card -> card.kind == model.searchCardKind && card.deleteFlag == 0) cards
            in
            { model
                | cards = filteredCards
                , session = addSession model.session json
            }

        Err _ ->
            model
