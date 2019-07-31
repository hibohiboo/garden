module Page.Views.LoginPage exposing (loginPage)

import Html exposing (..)
import Html.Attributes exposing (..)


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
