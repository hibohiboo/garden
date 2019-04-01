port module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Character exposing (..)
import Url
import Url.Builder


port elementChangeToJs : () -> Cmd msg


type Msg
    = InputName String
    | InputKana String
    | InputOrgan String
    | AddTrait
    | InputTrait Int String
    | DeleteTrait Int


update : Msg -> Character -> ( Character, Cmd Msg )
update msg char =
    let
        deleteAt i arrays =
            let
                len =
                    Array.length arrays

                head =
                    Array.slice 0 i arrays

                tail =
                    Array.slice (i + 1) len arrays
            in
            Array.append head tail
    in
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

        InputOrgan s ->
            let
                c =
                    { char | organ = s }
            in
            ( c, Cmd.none )

        AddTrait ->
            let
                c =
                    { char | traits = Array.push "" char.traits }
            in
            ( c, elementChangeToJs () )

        InputTrait i s ->
            let
                c =
                    { char | traits = Array.set i s char.traits }
            in
            ( c, Cmd.none )

        DeleteTrait i ->
            let
                c =
                    { char | traits = deleteAt i char.traits }
            in
            ( c, Cmd.none )



-- 入力エリア


editArea : Character -> EditorModel -> Html Msg
editArea character editor =
    div [ class "character-edit-area" ]
        [ inputArea "name" "名前" character.name InputName
        , inputArea "kana" "フリガナ" character.kana InputKana
        , inputAreaWithAutocomplete "organ" "変異器官" character.organ InputOrgan "organs" (getNameList editor.organs)
        , inputAreasWithAutocomplete "traits" "特性" character.traits InputTrait AddTrait DeleteTrait "traits" (getNameList editor.traits)
        ]


getNameList : List ( String, String ) -> List String
getNameList list =
    List.map (\( name, description ) -> name) list



-- 単純な入力


inputArea : String -> String -> String -> (String -> msg) -> Html msg
inputArea fieldId labelName val toMsg =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg ] []
        , label [ for fieldId ] [ text labelName ]
        ]



-- 単純な入力。オートコンプリート付き


inputAreaWithAutocomplete : String -> String -> String -> (String -> msg) -> String -> List String -> Html msg
inputAreaWithAutocomplete fieldId labelName val toMsg listId autocompleteList =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg, autocomplete True, list listId ] []
        , label [ for fieldId ] [ text labelName ]
        , datalist [ id listId ]
            (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
        ]



-- オートコンプリート付き可変の入力欄


inputAreasWithAutocomplete : String -> String -> Array String -> (Int -> String -> msg) -> msg -> (Int -> msg) -> String -> List String -> Html msg
inputAreasWithAutocomplete fieldId labelName arrays updateMsg addMsg deleteMsg listId autocompleteList =
    div []
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateAreaWithAutocomplete i fieldId labelName v updateMsg deleteMsg listId) arrays
                , addButton labelName addMsg
                ]
            )
        , datalist [ id listId ]
            (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
        ]


updateAreaWithAutocomplete : Int -> String -> String -> String -> (Int -> String -> msg) -> (Int -> msg) -> String -> Html msg
updateAreaWithAutocomplete index fieldId labelName val updateMsg deleteMsg listId =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s10" ]
            [ div [ class "input-field" ]
                [ input [ placeholder labelName, id fid, type_ "text", class "validate", value val, onInput (updateMsg index), autocomplete True, list listId ] []
                , label [ for fid ] [ text labelName ]
                ]
            ]
        , div [ class "col s2" ]
            [ deleteButton deleteMsg index
            ]
        ]



-- 可変の入力欄


inputAreas : String -> String -> Array String -> (Int -> String -> msg) -> msg -> (Int -> msg) -> Html msg
inputAreas fieldId labelName arrays updateMsg addMsg deleteMsg =
    div []
        [ div []
            (List.concat
                [ Array.toList <| Array.indexedMap (\i v -> updateArea i fieldId labelName v updateMsg deleteMsg) arrays
                , addButton labelName addMsg
                ]
            )
        ]



-- インデックス付きの編集


updateArea : Int -> String -> String -> String -> (Int -> String -> msg) -> (Int -> msg) -> Html msg
updateArea index fieldId labelName val updateMsg deleteMsg =
    let
        fid =
            fieldId ++ String.fromInt index
    in
    div [ class "row" ]
        [ div [ class "col s11" ]
            [ div [ class "input-field" ]
                [ input [ placeholder labelName, id fid, type_ "text", class "validate", value val, onInput (updateMsg index) ] []
                , label [ for fid ] [ text labelName ]
                ]
            ]
        , div [ class "col s1" ]
            [ deleteButton deleteMsg index
            ]
        ]



-- 削除ボタン


deleteButton : (Int -> msg) -> Int -> Html msg
deleteButton deleteMsg index =
    button [ class "btn-small waves-effect waves-light grey", onClick (deleteMsg index) ] [ i [ class "material-icons" ] [ text "delete" ] ]



-- 追加ボタン


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]
