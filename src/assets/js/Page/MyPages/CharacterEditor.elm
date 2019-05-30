port module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Models.Card as Card
import Models.Character exposing (..)
import Models.CharacterEditor exposing (..)
import Url
import Url.Builder
import Utils.Modal as Modal



-- Materializeのイベントを呼び出し


port elementChangeToJs : () -> Cmd msg


port openModalCharacterUpdate : () -> Cmd msg


type Msg
    = InputName String
    | InputKana String
    | InputOrgan String
    | AddTrait
    | InputTrait Int String
    | DeleteTrait Int
    | UpdateModal String String
    | OpenModal


update : Msg -> Character -> EditorModel msg -> ( ( Character, EditorModel msg ), Cmd Msg )
update msg char editor =
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
            ( ( c, editor ), Cmd.none )

        InputKana s ->
            let
                c =
                    { char | kana = s }
            in
            ( ( c, editor ), Cmd.none )

        InputOrgan s ->
            let
                c =
                    { char | organ = s }
            in
            ( ( c, editor ), Cmd.none )

        AddTrait ->
            let
                c =
                    { char | traits = Array.push "" char.traits }
            in
            ( ( c, editor ), elementChangeToJs () )

        InputTrait i s ->
            let
                c =
                    { char | traits = Array.set i s char.traits }
            in
            ( ( c, editor ), Cmd.none )

        DeleteTrait i ->
            let
                c =
                    { char | traits = deleteAt i char.traits }
            in
            ( ( c, editor ), Cmd.none )

        UpdateModal title kind ->
            let
                filteredCards =
                    if editor.searchCardKind == "" then
                        editor.cards

                    else
                        List.filter (\card -> card.kind == editor.searchCardKind) editor.cards

                newEditor =
                    { editor
                        | modalContents = Card.cardList filteredCards
                    }
            in
            update OpenModal char newEditor

        OpenModal ->
            ( ( char, editor ), openModalCharacterUpdate () )



-- 入力エリア


editArea : Character -> EditorModel Msg -> Html Msg
editArea character editor =
    div [ class "character-edit-area" ]
        [ inputArea "name" "名前" character.name InputName
        , inputArea "kana" "フリガナ" character.kana InputKana
        , modalCardOpenButton UpdateModal "変異器官" ""
        , inputAreaWithAutocomplete "organ" "変異器官" character.organ InputOrgan "organs" (getNameList editor.organs)
        , inputAreasWithAutocomplete "traits" "特性" character.traits InputTrait AddTrait DeleteTrait "traits" (getNameList editor.traits)
        , Modal.modalWindow editor.modalTitle editor.modalContents
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
                [ Array.toList <| Array.indexedMap (\i v -> updateAreaWithAutoComplete i fieldId labelName v updateMsg deleteMsg listId) arrays
                , addButton labelName addMsg
                ]
            )
        , datalist [ id listId ]
            (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
        ]


updateAreaWithAutoComplete : Int -> String -> String -> String -> (Int -> String -> msg) -> (Int -> msg) -> String -> Html msg
updateAreaWithAutoComplete index fieldId labelName val updateMsg deleteMsg listId =
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


modalCardOpenButton : (String -> String -> msg) -> String -> String -> Html msg
modalCardOpenButton modalMsg title kind =
    a [ onClick (modalMsg title kind), class "waves-effect waves-light btn", href "#" ] [ text title ]
