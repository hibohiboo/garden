port module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Character exposing (..)
import Url
import Url.Builder
import Utils.Terms as Terms


type Msg
    = InputName String
    | InputKana String


update : Msg -> Character -> ( Character, Cmd Msg )
update msg char =
    case msg of
        InputName s ->
            let
                c =
                    { char | name = s }
            in
            ( c, Cmd.none )

        InputKana s ->
            let
                c =
                    { char | kana = s }
            in
            ( c, Cmd.none )


editArea : Character -> Html Msg
editArea character =
    div [ class "character-edit-area" ]
        [ div [ class "input-field" ]
            [ input [ placeholder "名前", id "name", type_ "text", class "validate", value character.name, onInput InputName ] []
            , label [ for "name" ] [ text "名前" ]
            ]
        , div [ class "input-field" ]
            [ input [ placeholder "フリガナ", id "kana", type_ "text", class "validate", value character.kana, onInput InputKana ] []
            , label [ for "kana" ] [ text "フリガナ" ]
            ]
        ]
