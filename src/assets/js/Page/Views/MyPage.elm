module Page.Views.MyPage exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Models.Character exposing (..)
import Models.User exposing (..)
import Url
import Url.Builder


view : User -> List Character -> msg -> Html msg
view user characters signOut =
    div [ class "mypage" ]
        [ h1 [ class "header" ] [ text (user.displayName ++ "さんのマイページ") ]
        , button [ class "signout-button", onClick signOut, type_ "button" ] [ span [] [ text "サインアウト" ] ]
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
