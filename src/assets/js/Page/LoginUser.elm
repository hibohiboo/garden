port module Page.LoginUser exposing (Model, Msg(..), init, initModel, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.MyPages.User exposing (..)
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)
import Utils.Terms as Terms


port signOut : () -> Cmd msg



-- サインイン成功メッセージ


port signedIn : (String -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    signedIn SignedIn


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
    | SignOut


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

        SignOut ->
            ( model, signOut () )


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
            myPage user


loginPage : Html msg
loginPage =
    div [ class "" ]
        [ h3 [] [ text "マイページ" ]
        , div [] [ text "ユーザページの利用にはログインをお願いしております。" ]
        , div []
            [ text "現在、Twitterでログイン可能です。"
            ]
        , div [ id "firebaseui-auth-container", lang "ja" ] []
        , div [ id "loader" ] [ text "Loading ..." ]
        ]


myPage : User -> Html Msg
myPage user =
    div [ class "mypage" ]
        [ h1 [ class "header" ] [ text (user.displayName ++ "さんのマイページ") ]
        , button [ class "signout-button", onClick SignOut, type_ "button" ] [ span [] [ text "サインアウト" ] ]
        , div [ class "character-area" ]
            [ a [ href (Url.Builder.absolute [ "mypage", "character", "new" ] []), class "waves-effect waves-light btn", style "width" "250px" ]
                [ i [ class "small material-icons" ] [ text "add" ]
                , text "キャラクター新規作成"
                ]
            , characterListWrapper
            ]
        ]


characterListWrapper =
    div [ class "row" ]
        [ div [ class "col m6 s12" ]
            [ characterList
            ]
        ]


characterList =
    div [ class "collection with-header" ]
        [ div [ class "collection-header" ] [ text "作成したPC一覧" ]
        , div [ class "collection-item" ]
            [ text "キャラクター名"
            , a [ class "secondary-content btn-floating btn-small waves-effect waves-light red" ]
                [ i [ class "material-icons" ] [ text "edit" ]
                ]
            ]
        ]
