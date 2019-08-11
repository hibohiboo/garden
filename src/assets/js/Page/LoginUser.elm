port module Page.LoginUser exposing (Model, Msg(..), init, initModel, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as D
import Models.Character exposing (..)
import Models.Enemy as Enemy exposing (Enemy)
import Models.Pagination as Pagination exposing (Pagination)
import Models.User exposing (..)
import Page.Views.LoginPage exposing (loginPage)
import Page.Views.MyPage as MyPage
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


type alias UserId =
    String


port signOut : () -> Cmd msg


port signedIn : (String -> msg) -> Sub msg


port getCharacters : UserId -> Cmd msg


port gotCharacters : (String -> msg) -> Sub msg


port getEnemies : D.Value -> Cmd msg


port gotEnemies : (D.Value -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ signedIn SignedIn
        , gotCharacters GotCharacters
        , gotEnemies GotEnemies
        ]


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , user : Maybe User
    , characters : List Character
    , enemies : List Enemy
    , enemyPagination : Pagination
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    ( initModel session
    , Cmd.none
    )


initModel : Session.Data -> Model
initModel session =
    Model session Close Nothing [] [] Pagination.empty


type Msg
    = ToggleNavigation
    | SignedIn String
    | SignOut
    | GotCharacters String
    | GotEnemies D.Value
    | GetEnemies


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNavigation ->
            ( { model | naviState = toggleNavigationState model.naviState }, Cmd.none )

        SignedIn s ->
            case decodeUserFromString s of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    let
                        pagination =
                            Pagination.init user.storeUserId

                        cmd =
                            Cmd.batch
                                [ getCharacters user.storeUserId
                                , getEnemies <| Pagination.encodePaginationToValue pagination
                                ]
                    in
                    ( { model | user = Just user, enemyPagination = pagination }, cmd )

        SignOut ->
            ( model, signOut () )

        GotCharacters s ->
            case D.decodeString (D.list characterDecoder) s of
                Err a ->
                    ( model, Cmd.none )

                Ok char ->
                    ( { model | characters = char }, Cmd.none )

        GotEnemies s ->
            case D.decodeValue Pagination.enemyPaginationDecoder s of
                Err a ->
                    ( model, Cmd.none )

                Ok ( nextToken, enemies ) ->
                    ( { model | enemies = List.concat [ model.enemies, enemies ], enemyPagination = Pagination.updateToken nextToken model.enemyPagination }, Cmd.none )

        GetEnemies ->
            ( model, getEnemies <| Pagination.encodePaginationToValue model.enemyPagination )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "マイページ"
    , attrs = [ class naviClass, class "loginpage" ]
    , kids =
        [ viewMain (viewMainPage model)
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewMainPage : Model -> Html Msg
viewMainPage model =
    case model.user of
        Nothing ->
            loginPage

        Just user ->
            MyPage.view user model.characters model.enemies model.enemyPagination.isNext GetEnemies SignOut
