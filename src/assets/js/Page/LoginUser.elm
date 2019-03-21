module Page.LoginUser exposing (Model, Msg(..), init, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms
import Page.MyPages.User exposing(..)

type alias Model =
    { naviState : NaviState,
      user: Maybe User
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
        SignedIn s -> ({model | user = Just (User "test" "aaa")}, Cmd.none)


view : Model -> Skeleton.Details Msg
view model =
    let
        -- ナビゲーションの状態によってページに持たせるクラスを変える
        naviClass =
            getNavigationPageClass
                model.naviState
    in
    { title = "マイページ"
    , attrs = [ class naviClass ]
    , kids =
        [ viewMain (viewTopPage model)
        , viewNav [ NavigationMenu "" "トップ", NavigationMenu "rulebook" "ルールブック" ]
        , openNavigationButton ToggleNavigation
        , closeNavigationButton ToggleNavigation
        ]
    }


viewTopPage : Model -> Html msg
viewTopPage  model =
    case model.user of 
      Nothing ->
        div [ class "" ]
            [ h1 [] [ text "マイページ" ]
            , div [] [ text "ユーザページの利用にはログインをお願いしております。" ]
            , div []
                [ text "現在、Twitterでログイン可能です。"
                ]
            , div [ id "firebaseui-auth-container", lang "ja" ] []
            , div [ id "loader" ] [ text "Loading ..." ]
            ]
      _ -> div[][text "test"]
