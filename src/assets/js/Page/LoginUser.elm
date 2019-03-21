module Page.LoginUser exposing (Model, Msg(..), init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.MyPages.User exposing (..)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


type alias Model =
    { naviState : NaviState
    , user : Maybe User
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )


initModel : Model
initModel =
    Model Close Nothing


type Msg
    = ToggleNavigation
    | SignedIn String


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
                    ( { model | user = Just user }, Cmd.none )


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "マイページ"
    , attrs = [ class naviClass, class "mypage" ]
    , kids =
        [ viewMain (viewMainPage model)
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewMainPage : Model -> Html msg
viewMainPage model =
    case model.user of
        Nothing ->
            loginPage

        Just user ->
            myPage user


loginPage : Html msg
loginPage =
    div [ class "" ]
        [ h1 [] [ text "マイページ" ]
        , div [] [ text "ユーザページの利用にはログインをお願いしております。" ]
        , div []
            [ text "現在、Twitterでログイン可能です。"
            ]
        , div [ id "firebaseui-auth-container", lang "ja" ] []
        , div [ id "loader" ] [ text "Loading ..." ]
        ]


myPage : User -> Html msg
myPage user =
    div [ class "" ]
        [ h1 [ class "header" ] [ text (user.displayName ++ "さんのマイページ") ]
        ]
