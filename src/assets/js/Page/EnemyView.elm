module Page.EnemyView exposing (Model, Msg(..), init, update, view)

import Html exposing (text)
import Html.Attributes exposing (class)
import Page.Views.Enemy as EnemyView
import Session
import Skeleton exposing (viewLink, viewMain)


type alias Model =
    { session : Session.Data }


type Msg
    = Nothing


init : Session.Data -> String -> String -> Maybe String -> ( Model, Cmd Msg )
init session apiKey storeUserId characterId =
    ( initModel session apiKey storeUserId, Cmd.none )


initModel session apiKey storeUserId =
    Model session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nothing ->
            ( model, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    { title = "View"
    , attrs = [ class "enemy" ]
    , kids = [ text "" ]
    }
