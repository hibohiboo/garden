module Page.Views.Modal exposing (confirmDelete, modalCardOpenButton)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


modalCardOpenButton : msg -> String -> Html msg
modalCardOpenButton modalMsg title =
    div [ onClick modalMsg, class "waves-effect waves-light btn" ] [ text title ]


confirmDelete : msg -> msg -> String -> Html msg
confirmDelete cancelMsg deleteMsg title =
    div []
        [ text (title ++ "を削除しますか？")
        , div []
            [ button [ onClick cancelMsg, class "waves-effect waves-light btn ", style "margin-right" "20px", selected True ] [ text "キャンセル" ]
            , button [ onClick deleteMsg, class "waves-effect waves-light btn red" ] [ text "削除する" ]
            ]
        ]
