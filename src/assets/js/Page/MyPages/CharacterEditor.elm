module Page.MyPages.CharacterEditor exposing (Msg(..), editArea, update)

import Array exposing (Array)
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onChange)
import Models.Card as Card
import Models.Character exposing (Character)
import Models.CharacterEditor exposing (EditorModel)
import Models.Tag exposing (Tag)
import Page.Views.CharacterEditorView as CharacterEditorView exposing (updateCardArea)
import Task
import Url
import Url.Builder
import Utils.List.Extra exposing (findIndex)
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


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
    | OpenCommonSkillModal
    | OpenTraitSkillModal
    | OpenItemModal
    | OpenModal
    | AddCard
    | DeleteCard Int
    | CloseModal
    | InputReason String
    | InputLabo String
    | InputMemo String
    | InputAP String
    | TogglePublish
    | ImageRequested
    | ImageSelected File
    | ImageLoaded (Result LoadErr String)
    | CharacterImageRequested
    | CharacterImageSelected File
    | CharacterImageLoaded (Result LoadErr String)
    | InputImageCreatorName String
    | InputImageCreatorSite String
    | InputImageCreatorUrl String
    | ToggleShowCardDetail
    | UpdateCardName Int String
    | UpdateCardTiming Int String
    | UpdateCardCost Int String


type LoadErr
    = ErrToUrlFailed
    | ErrInvalidFile


update : Msg -> Character -> EditorModel Msg -> ( ( Character, EditorModel Msg ), Cmd Msg )
update msg char editor =
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
            ( ( c, { editor | modalState = Modal.Close } ), Cmd.none )

        InputOrganCard card ->
            let
                newCards =
                    setNewDataCards card "器官" char.cards

                newActivePower =
                    Card.getActivePower newCards
            in
            update (InputOrgan card.cardName) { char | cards = newCards, activePower = newActivePower } editor

        InputMutagen s ->
            let
                c =
                    { char | mutagen = s }
            in
            ( ( c, { editor | modalState = Modal.Close } ), Cmd.none )

        InputMutagenCard card ->
            let
                newCards =
                    setNewDataCards card "変異原" char.cards

                newActivePower =
                    Card.getActivePower newCards
            in
            update (InputMutagen card.cardName) { char | cards = newCards, activePower = newActivePower } editor

        InputTrait s ->
            let
                c =
                    { char | trait = s }
            in
            ( ( c, { editor | modalState = Modal.Close } ), Cmd.none )

        InputTraitCard card ->
            let
                newCards =
                    setNewDataCards card "特性" char.cards

                newActivePower =
                    Card.getActivePower newCards
            in
            update (InputTrait card.cardName) { char | cards = newCards, activePower = newActivePower } editor

        InputSkillCard card ->
            let
                newCards =
                    Array.push card char.cards

                newActivePower =
                    Card.getActivePower newCards

                c =
                    { char | cards = newCards, activePower = newActivePower }
            in
            ( ( c, { editor | modalState = Modal.Close } ), Cmd.none )

        AddCard ->
            let
                newCards =
                    Array.push Card.initCard char.cards

                newActivePower =
                    Card.getActivePower newCards

                c =
                    { char | cards = newCards, activePower = newActivePower }
            in
            ( ( c, editor ), Cmd.none )

        DeleteCard i ->
            let
                newCards =
                    deleteAt i char.cards

                newActivePower =
                    Card.getActivePower newCards

                c =
                    { char | cards = newCards, activePower = newActivePower }
            in
            ( ( c, editor ), Cmd.none )

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

        OpenCommonSkillModal ->
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

        OpenItemModal ->
            let
                filteredCards =
                    List.filter (\card -> card.cardType == "アイテム") editor.cards

                cardElements =
                    div [ class "card-list" ] (List.map (\card -> inputCard card (InputSkillCard card)) filteredCards)

                newEditor =
                    { editor
                        | modalContents = cardElements
                    }
            in
            update OpenModal char newEditor

        OpenTraitSkillModal ->
            let
                tagNameList =
                    Card.getTraitList char.cards

                filteredCards =
                    List.filter (\card -> List.member card.kind tagNameList) editor.cards

                cardElements =
                    div [ class "card-list" ] (List.map (\card -> inputCard card (InputSkillCard card)) filteredCards)

                newEditor =
                    { editor
                        | modalContents = cardElements
                    }
            in
            update OpenModal char newEditor

        OpenModal ->
            ( ( char, { editor | modalState = Modal.Open } ), Cmd.none )

        CloseModal ->
            ( ( char, { editor | modalState = Modal.Close } ), Cmd.none )

        InputReason s ->
            let
                c =
                    { char | reason = s }
            in
            ( ( c, editor ), Cmd.none )

        InputLabo s ->
            let
                c =
                    { char | labo = s }
            in
            ( ( c, editor ), Cmd.none )

        InputMemo s ->
            let
                c =
                    { char | memo = s }
            in
            ( ( c, editor ), Cmd.none )

        InputAP s ->
            let
                c =
                    { char | activePower = s |> String.toInt |> Maybe.withDefault 0 }
            in
            ( ( c, editor ), Cmd.none )

        TogglePublish ->
            let
                c =
                    { char | isPublished = not char.isPublished }
            in
            ( ( c, editor ), Cmd.none )

        ImageRequested ->
            ( ( char, editor )
            , Select.file expectedTypes ImageSelected
            )

        -- 1M 以上のファイルはアップロードしない
        ImageSelected file ->
            if File.size file < 1048576 then
                ( ( char, editor )
                , Task.attempt ImageLoaded <| File.toUrl file
                )

            else
                ( ( char, editor )
                , Cmd.none
                )

        ImageLoaded result ->
            case result of
                Ok content ->
                    let
                        c =
                            { char | cardImageData = content }
                    in
                    ( ( c, editor )
                    , Cmd.none
                    )

                Err error ->
                    -- ( { model
                    --     | error = Just error
                    --     , status = Default
                    --   }
                    -- , Cmd.none
                    -- )
                    ( ( char, editor )
                    , Cmd.none
                    )

        CharacterImageRequested ->
            ( ( char, editor )
            , Select.file expectedTypes CharacterImageSelected
            )

        CharacterImageSelected file ->
            if File.size file < 1048576 then
                ( ( char, editor )
                , Task.attempt CharacterImageLoaded <| File.toUrl file
                )

            else
                ( ( char, editor )
                , Cmd.none
                )

        CharacterImageLoaded result ->
            case result of
                Ok content ->
                    let
                        c =
                            { char | characterImageData = content }
                    in
                    ( ( c, editor )
                    , Cmd.none
                    )

                Err error ->
                    ( ( char, editor )
                    , Cmd.none
                    )

        InputImageCreatorName s ->
            ( ( { char | cardImageCreatorName = s }, editor ), Cmd.none )

        InputImageCreatorSite s ->
            ( ( { char | cardImageCreatorSite = s }, editor ), Cmd.none )

        InputImageCreatorUrl s ->
            ( ( { char | cardImageCreatorUrl = s }, editor ), Cmd.none )

        ToggleShowCardDetail ->
            ( ( char, { editor | isShowCardDetail = not editor.isShowCardDetail } ), Cmd.none )

        UpdateCardName index name ->
            ( ( { char | cards = char.cards |> Card.updateCardName index name }, editor ), Cmd.none )

        UpdateCardTiming index value ->
            ( ( { char | cards = char.cards |> Card.updateCardTiming index value }, editor ), Cmd.none )

        UpdateCardCost index value ->
            ( ( { char | cards = char.cards |> Card.updateCardCost index value }, editor ), Cmd.none )


expectedTypes : List String
expectedTypes =
    [ "image/png", "image/jpeg", "image/gif" ]


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
        , skillArea character editor
        , Modal.view editor.modalTitle editor.modalContents editor.modalState CloseModal
        , div [ class "input-field" ]
            [ input [ placeholder "行動力", id "activePower", type_ "number", class "validate", value (String.fromInt character.activePower), onInput InputAP ] []
            , label [ class "active", for "activePower" ] [ text "行動力" ]
            ]
        , inputAreaWithAutocomplete "reason" "収容理由" character.reason InputReason "reasonList" (List.map (\( t, d ) -> t) editor.reasons)
        , inputArea "labo" "研究所" character.labo InputLabo
        , div [ class "input-field" ]
            [ textarea [ placeholder "メモ", id "memo", class "materialize-textarea", value character.memo, onInput InputMemo, style "height" "200px", style "overflow-y" "auto" ] []
            , label [ class "active", for "memo" ] [ text "メモ" ]
            ]
        , div [ class "input-field" ]
            [ div [] [ text "他の人にシートを公開する場合は以下にチェック" ]
            , div [] [ label [] [ input [ type_ "checkbox", checked character.isPublished, onClick TogglePublish ] [], span [] [ text "公開する" ] ] ]
            ]
        , div [ class "input-field" ]
            [ div [] [ text "カードイメージ" ]
            , div [] [ text "(74×94px推奨。1Mb未満。)" ]
            , inputCardImageArea character
            ]
        , div [ class "input-field" ]
            [ div [] [ text "キャラクターイメージ" ]
            , div [] [ text "(1Mb未満。)" ]
            , inputCharacterImageArea character
            ]
        , inputArea "cardImageCreatorName" "画像作者" character.cardImageCreatorName InputImageCreatorName
        , inputArea "cardImageCreatorSite" "画像作者サイト名" character.cardImageCreatorSite InputImageCreatorSite
        , inputArea "cardImageCreatorUrl" "画像作者サイトURL" character.cardImageCreatorUrl InputImageCreatorUrl
        ]


inputCardImageArea : Character -> Html Msg
inputCardImageArea model =
    case model.cardImageData of
        "" ->
            button [ onClick ImageRequested ] [ text "Upload image" ]

        content ->
            img
                [ class "cardImage", src content, width 74, height 94 ]
                []


inputCharacterImageArea : Character -> Html Msg
inputCharacterImageArea model =
    case model.characterImageData of
        "" ->
            button [ onClick CharacterImageRequested ] [ text "Upload image" ]

        content ->
            img
                [ class "characterImage", src content ]
                []


skillArea character editor =
    div [ style "padding-bottom" "5px" ]
        [ h5 [] [ text "能力" ]
        , div [] [ label [] [ input [ type_ "checkbox", checked editor.isShowCardDetail, onClick ToggleShowCardDetail ] [], span [] [ text "詳細を表示" ] ] ]
        , div [ class (Models.CharacterEditor.cardDetailClass editor.isShowCardDetail) ]
            [ text "Ti:タイミング/Co:コスト/Ra:射程/Ta:対象" ]
        , div []
            (List.concat
                [ [ div [ style "padding" "5px" ] (addButton "共通能力" OpenCommonSkillModal) ]
                , [ div [ style "padding" "5px" ] (addButton "特性能力" OpenTraitSkillModal) ]
                , [ div [ style "padding" "5px" ] (addButton "アイテム" OpenItemModal) ]
                , List.reverse <| Array.toList <| Array.indexedMap (\i card -> updateCardAreaWithMsg i editor.isShowCardDetail card) character.cards
                ]
            )
        ]


updateCardAreaWithMsg : Int -> (Bool -> Card.CardData -> Html Msg)
updateCardAreaWithMsg i =
    updateCardArea (DeleteCard i) (UpdateCardName i) (UpdateCardTiming i) (UpdateCardCost i) ("card_" ++ String.fromInt i)


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
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onChange toMsg ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        ]



-- 単純な入力。オートコンプリート付き


inputAreaWithAutocomplete : String -> String -> String -> (String -> msg) -> String -> List String -> Html msg
inputAreaWithAutocomplete fieldId labelName val toMsg listId autocompleteList =
    div [ class "input-field" ]
        [ input [ placeholder labelName, id fieldId, type_ "text", class "validate", value val, onInput toMsg, autocomplete True, list listId ] []
        , label [ class "active", for fieldId ] [ text labelName ]
        , datalist [ id listId ]
            (List.map (\s -> option [ value s ] [ text s ]) autocompleteList)
        ]



-- 追加ボタン


addButton : String -> msg -> List (Html msg)
addButton labelName addMsg =
    [ text (labelName ++ "を追加  ")
    , button [ class "btn-floating btn-small waves-effect waves-light green", onClick addMsg ] [ i [ class "material-icons" ] [ text "add" ] ]
    ]


modalCardOpenButton : (String -> String -> (Card.CardData -> Msg) -> msg) -> String -> String -> (Card.CardData -> Msg) -> Html msg
modalCardOpenButton modalMsg title kind cardMsg =
    div [ onClick (modalMsg title kind cardMsg), class "waves-effect waves-light btn" ] [ text title ]



-- TODO: ドラッグアンドドロップ https://elm-lang.org/examples/drag-and-drop
