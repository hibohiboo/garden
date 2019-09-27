module Page.Views.MyPage exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Models.Character exposing (Character)
import Models.Enemy as Enemy exposing (Enemy)
import Models.User exposing (User)
import Url
import Url.Builder


view : User -> List Character -> List Enemy -> Bool -> msg -> msg -> Html msg
view user characters enemies isEnemyNext nextEnemyMsg signOut =
    div [ class "mypage" ]
        [ h1 [ class "header" ] [ text (user.displayName ++ "さんのマイページ") ]
        , button [ class "signout-button", onClick signOut, type_ "button" ] [ span [] [ text "サインアウト" ] ]
        , div [ class "character-area" ]
            [ a [ href (Url.Builder.absolute [ "mypage", "character", "create", user.storeUserId ] []), class "waves-effect waves-light btn", style "width" "250px" ]
                [ i [ class "small material-icons" ] [ text "add" ]
                , text "キャラクター新規作成"
                ]
            , characterListWrapper characters
            , a [ href (Url.Builder.absolute [ "mypage", "enemy", "create", user.storeUserId ] []), class "waves-effect waves-light btn", style "width" "250px" ]
                [ i [ class "small material-icons" ] [ text "add" ]
                , text "エネミー作成"
                ]
            , enemiesWrapper enemies nextEnemyMsg isEnemyNext
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


characterListItem : Character -> Html msg
characterListItem char =
    div [ class "collection-item" ]
        [ a [ href (Url.Builder.absolute [ "character", "view", char.characterId ] []) ]
            [ text char.name
            ]
        , a [ href (Url.Builder.absolute [ "mypage", "character", "edit", char.storeUserId, char.characterId ] []), class "secondary-content btn-floating btn-small waves-effect waves-light red" ]
            [ i [ class "material-icons" ] [ text "edit" ]
            ]
        ]


enemiesWrapper enemies nextEnemyMsg isEnemyNext =
    div [ class "row" ]
        [ div [ class "col m6 s12" ]
            [ enemyList nextEnemyMsg enemies isEnemyNext ]
        ]


enemyList nextEnemyMsg enemies isEnemyNext =
    div [ class "collection with-header" ]
        (List.concat
            [ [ div [ class "collection-header" ] [ text "作成したエネミー一覧" ] ]
            , List.map enemyListItem enemies
            , if isEnemyNext then
                [ button [ class "signout-button", onClick nextEnemyMsg, type_ "button" ] [ span [] [ text "さらに読み込む" ] ] ]

              else
                []
            ]
        )


enemyListItem : Enemy -> Html msg
enemyListItem enemy =
    div [ class "collection-item" ]
        [ a [ href (Url.Builder.absolute [ "enemy", "view", enemy.enemyId ] []) ]
            [ text enemy.name
            ]
        , a [ href (Url.Builder.absolute [ "mypage", "enemy", "edit", enemy.storeUserId, enemy.enemyId ] []), class "secondary-content btn-floating btn-small waves-effect waves-light red" ]
            [ i [ class "material-icons" ] [ text "edit" ]
            ]
        ]
