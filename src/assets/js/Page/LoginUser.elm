port module Page.LoginUser exposing (Model, Msg(..), init, initModel, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as D
import Models.Character exposing (..)
import Models.User exposing (..)
import Session
import Skeleton exposing (viewLink, viewMain)
import Url
import Url.Builder
import Utils.NavigationMenu exposing (NaviState(..), NavigationMenu, closeNavigationButton, getNavigationPageClass, openNavigationButton, toggleNavigationState, viewNav)


port signOut : () -> Cmd msg


port signedIn : (String -> msg) -> Sub msg


port getCharacters : String -> Cmd msg


port gotCharacters : (String -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ signedIn SignedIn
        , gotCharacters GotCharacters
        ]


type alias Model =
    { session : Session.Data
    , naviState : NaviState
    , user : Maybe User
    , characters : List Character
    }


init : Session.Data -> ( Model, Cmd Msg )
init session =
    ( initModel session
    , Cmd.none
    )


initModel : Session.Data -> Model
initModel session =
    Model session Close Nothing []


type Msg
    = ToggleNavigation
    | SignedIn String
    | SignOut
    | GotCharacters String


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
                    ( { model | user = Just user }, getCharacters user.storeUserId )

        SignOut ->
            ( model, signOut () )

        GotCharacters s ->
            case D.decodeString (D.list characterDecoder) s of
                Err a ->
                    ( model, Cmd.none )

                Ok char ->
                    ( { model | characters = char }, Cmd.none )


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
            myPage user model.characters


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


myPage : User -> List Character -> Html Msg
myPage user characters =
    div [ class "mypage" ]
        [ h1 [ class "header" ] [ text (user.displayName ++ "さんのマイページ") ]
        , button [ class "signout-button", onClick SignOut, type_ "button" ] [ span [] [ text "サインアウト" ] ]
        , div [ class "character-area" ]
            [ a [ href (Url.Builder.absolute [ "mypage", "character", "create", user.storeUserId ] []), class "waves-effect waves-light btn", style "width" "250px" ]
                [ i [ class "small material-icons" ] [ text "add" ]
                , text "キャラクター新規作成"
                ]
            , characterListWrapper characters
            ]
        ]


characterListWrapper characters =
    div [ class "row" ]
        [ div [ class "col m6 s12" ]
            [ characterList characters ]
        ]


characterList characters =
    div [ class "collection with-header" ]
        (div [ class "collection-header" ] [ text "作成したPC一覧" ]
            :: List.map characterListItem characters
        )


characterListItem char =
    div [ class "collection-item" ]
        [ a [ href (Url.Builder.absolute [ "character", "view", char.characterId ] []) ]
            [ text char.name
            ]
        , a [ href (Url.Builder.absolute [ "mypage", "character", "edit", char.storeUserId, char.characterId ] []), class "secondary-content btn-floating btn-small waves-effect waves-light red" ]
            [ i [ class "material-icons" ] [ text "edit" ]
            ]
        ]
