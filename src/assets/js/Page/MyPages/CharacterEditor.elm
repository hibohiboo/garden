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
import Utils.List.Extra exposing (findIndex)
import Utils.Modal as Modal



-- Materializeのイベントを呼び出し


port elementChangeToJs : () -> Cmd msg


port openModalCharacterUpdate : () -> Cmd msg


port closeModalCharacterUpdate : () -> Cmd msg


type Msg
    = InputName String
    | InputKana String
    | InputOrgan String
    | InputOrganCard Card.CardData
    | InputMutagen String
    | InputMutagenCard Card.CardData
    | InputTrait String
    | InputTraitCard Card.CardData
    | InputSkillCard Card.CardData
    | UpdateModal String String (Card.CardData -> Msg)
    | SkillModal
    | OpenModal
    | AddCard


update : Msg -> Character -> EditorModel Msg -> ( ( Character, EditorModel Msg ), Cmd Msg )
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
            ( ( c, editor ), closeModalCharacterUpdate () )

        InputOrganCard card ->
            let
                newCards =
                    setNewDataCards card "器官" char.cards
            in
            update (InputOrgan card.cardName) { char | cards = newCards } editor

        InputMutagen s ->
            let
                c =
                    { char | mutagen = s }
            in
            ( ( c, editor ), closeModalCharacterUpdate () )

        InputMutagenCard card ->
            let
                newCards =
                    setNewDataCards card "変異原" char.cards
            in
            update (InputMutagen card.cardName) { char | cards = newCards } editor

        InputTrait s ->
            let
                c =
                    { char | trait = s }
            in
            ( ( c, editor ), closeModalCharacterUpdate () )

        InputTraitCard card ->
            let
                newCards =
                    setNewDataCards card "特性" char.cards
            in
            update (InputTrait card.cardName) { char | cards = newCards } editor

        InputSkillCard card ->
            let
                maybeIndex =
                    findIndex (\x -> x.cardName == card.cardName) (Array.toList char.cards)

                newCards =
                    case maybeIndex of
                        Just index ->
                            Array.set index card char.cards

                        _ ->
                            Array.push card char.cards
            in
            update (InputTrait card.cardName) { char | cards = newCards } editor

        AddCard ->
            let
                c =
                    { char | cards = Array.push Card.initCard char.cards }
            in
            ( ( c, editor ), elementChangeToJs () )

        -- InputTrait i s ->
        --     let
        --         c =
        --             { char | traits = Array.set i s char.traits }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- DeleteTrait i ->
        --     let
        --         c =
        --             { char | traits = deleteAt i char.traits }
        --     in
        --     ( ( c, editor ), Cmd.none )
        UpdateModal title kind m ->
            let
                filteredCards =
                    if kind == "" then
                        editor.cards

                    else
                        List.filter (\card -> card.kind == kind) editor.cards

                cardElements =
                    div [ class "card-list" ] (List.map (\card -> inputCard card (m card)) filteredCards)

                newEditor =
                    { editor
                        | modalContents = cardElements
                    }
            in
            update OpenModal char newEditor

        SkillModal ->
            let
                filteredCards =
                    List.filter (\card -> card.kind == "共通能力") editor.cards

                cardElements =
                    div [ class "card-list" ] (List.map (\card -> inputCard card (InputSkillCard card)) filteredCards)

                newEditor =
                    { editor
                        | modalContents = cardElements
                    }
            in
            update OpenModal char newEditor

        OpenModal ->
            ( ( char, editor ), openModalCharacterUpdate () )


setNewDataCards : Card.CardData -> String -> Array Card.CardData -> Array Card.CardData
setNewDataCards card kind cards =
    if Array.length cards == 0 then
        Array.fromList [ card ]

    else
        let
            maybeIndex =
                findIndex (\x -> x.kind == kind) (Array.toList cards)
        in
        case maybeIndex of
            Just index ->
                Array.set index card cards

            _ ->
                Array.push card cards



-- 入力エリア


editArea : Character -> EditorModel Msg -> Html Msg
editArea character editor =
    div [ class "character-edit-area" ]
        [ inputArea "name" "名前" character.name InputName
        , inputArea "kana" "フリガナ" character.kana InputKana
        , cardWithInputArea character "organ" "変異器官" "器官" character.organ InputOrgan InputOrganCard
        , cardWithInputArea character "mutagen" "変異原" "変異原" character.mutagen InputMutagen InputMutagenCard
        , cardWithInputArea character "trait" "特性" "特性" character.trait InputTrait InputTraitCard

        -- , inputAreasWithAutocomplete "traits" "特性" character.traits InputTrait AddTrait DeleteTrait "traits" (getNameList editor.traits)
        , skillArea character editor
        , Modal.modalWindow editor.modalTitle editor.modalContents
        ]


skillArea character editor =
    div []
        [ h5 [] [ text "能力" ]
        , div [] [ text "Ti:タイミング/Co:コスト/Ra:射程/Ta:対象/Ef:効果" ]
        , div [ onClick SkillModal, class "waves-effect waves-light btn" ] [ text "カード選択" ]
        ]


getNameList : List ( String, String ) -> List String
getNameList list =
    List.map (\( name, description ) -> name) list


cardWithInputArea : Character -> String -> String -> String -> String -> (String -> Msg) -> (Card.CardData -> Msg) -> Html Msg
cardWithInputArea character name label kind value msg cardMsg =
    div [ class "row" ]
        [ div [ class "col s6" ]
            [ div [ class "input-field" ]
                [ inputArea name label value msg
                ]
            ]
        , div [ class "col s6" ]
            [ modalCardOpenButton UpdateModal "カード選択" kind cardMsg
            ]
        ]



-- カードをクリックすると変異器官を更新する


inputCard : Card.CardData -> Msg -> Html Msg
inputCard card msg =
    div [ onClick msg ] [ Card.cardView card ]



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
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg, autocomplete True, list listId, disabled True ] []
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


modalCardOpenButton : (String -> String -> (Card.CardData -> Msg) -> msg) -> String -> String -> (Card.CardData -> Msg) -> Html msg
modalCardOpenButton modalMsg title kind cardMsg =
    div [ onClick (modalMsg title kind cardMsg), class "waves-effect waves-light btn" ] [ text title ]
