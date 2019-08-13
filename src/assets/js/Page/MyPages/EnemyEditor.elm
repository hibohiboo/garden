module Page.MyPages.EnemyEditor exposing (Msg(..), createEditArea, deleteModal, editArea, update)

import Array exposing (Array)
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onChange)
import Models.Card as Card
import Models.Enemy as Enemy exposing (EditorModel, Enemy, PageState)
import Models.Tag exposing (Tag)
import Page.Views.EnemyEditor as EnemyEditorView
import Page.Views.Modal exposing (confirmDelete)
import Task
import Url
import Url.Builder
import Utils.List.Extra exposing (findIndex)
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


type Msg
    = InputName String
    | InputKana String
    | InputActivePower String
    | InputMemo String
    | InputDegreeOfThreat String
    | InputCardImageCreatorName String
    | InputCardImageCreatorSite String
    | InputCardImageCreatorUrl String
    | AddEmptyCard
    | DeleteCard Int
    | InputSkillCard Card.CardData
    | InputTags String
    | InputSearchTagName String
    | OpenSkillModal
    | OpenModal
    | CloseModal
    | TogglePublish
    | ImageRequested
    | ImageSelected File
    | ImageLoaded (Result LoadErr String)
    | ToggleShowCardDetail
    | UpdateCardName Int String
    | UpdateCardTiming Int String
    | UpdateCardCost Int String
    | UpdateCardRange Int String
    | UpdateCardMaxRange Int String
    | UpdateCardTarget Int String
    | UpdateCardEffect Int String
    | UpdateCardDescription Int String
    | UpdateCardTags Int String
    | DeleteConfirm
    | CancelConfirm
    | Delete
    | InputSampleCharacter String


type LoadErr
    = ErrToUrlFailed
    | ErrInvalidFile


update : Msg -> EditorModel Msg -> ( EditorModel Msg, Cmd Msg )
update msg editor =
    let
        enemy =
            editor.editingEnemy
    in
    case msg of
        InputSampleCharacter id ->
            case Enemy.getEnemyFromListId id editor.sampleEnemies of
                Just newEnemy ->
                    ( { editor | editingEnemy = newEnemy }, Cmd.none )

                Nothing ->
                    ( editor, Cmd.none )

        InputName s ->
            ( { editor | editingEnemy = Enemy.setEnemyName s enemy }, Cmd.none )

        InputKana s ->
            ( { editor | editingEnemy = Enemy.setEnemyKana s enemy }, Cmd.none )

        InputTags s ->
            ( { editor | editingEnemy = Enemy.setEnemyTags s enemy }, Cmd.none )

        InputActivePower s ->
            ( { editor | editingEnemy = Enemy.setEnemyActivePower s enemy }, Cmd.none )

        InputMemo s ->
            ( { editor | editingEnemy = Enemy.setEnemyMemo s enemy }, Cmd.none )

        InputDegreeOfThreat s ->
            ( { editor | editingEnemy = Enemy.setEnemyDegreeOfThreat s enemy }, Cmd.none )

        InputCardImageCreatorName s ->
            ( { editor | editingEnemy = Enemy.setEnemyCardImageCreatorName s enemy }, Cmd.none )

        InputCardImageCreatorSite s ->
            ( { editor | editingEnemy = Enemy.setEnemyCardImageCreatorSite s enemy }, Cmd.none )

        InputCardImageCreatorUrl s ->
            ( { editor | editingEnemy = Enemy.setEnemyCardImageCreatorUrl s enemy }, Cmd.none )

        TogglePublish ->
            ( { editor | editingEnemy = Enemy.setEnemyIsPublished (not enemy.isPublished) enemy }, Cmd.none )

        AddEmptyCard ->
            ( { editor | editingEnemy = Enemy.addEnemyCard Card.initCard enemy }, Cmd.none )

        DeleteCard i ->
            ( { editor | editingEnemy = Enemy.deleteEnemyCard i enemy }, Cmd.none )

        InputSkillCard card ->
            update CloseModal { editor | editingEnemy = Enemy.addEnemyCard card enemy }

        InputSearchTagName s ->
            ( { editor | searchCardTagName = s }, Cmd.none )

        OpenSkillModal ->
            let
                filteredCards =
                    if editor.searchCardTagName == "" then
                        editor.cards

                    else
                        Card.filterByName editor.searchCardTagName editor.cards

                cardElements =
                    div [ class "card-list" ] (List.map (\card -> inputCard card (InputSkillCard card)) filteredCards)
            in
            update OpenModal { editor | modalContents = cardElements }

        OpenModal ->
            ( { editor | modalState = Modal.Open }, Cmd.none )

        CloseModal ->
            ( { editor | modalState = Modal.Close }, Cmd.none )

        ImageRequested ->
            ( editor, Select.file expectedTypes ImageSelected )

        ImageSelected file ->
            if File.size file < 1048576 then
                ( editor, Task.attempt ImageLoaded <| File.toUrl file )

            else
                ( editor, Cmd.none )

        ImageLoaded result ->
            case result of
                Ok content ->
                    ( { editor | editingEnemy = Enemy.setEnemyCardImageData content enemy }, Cmd.none )

                Err error ->
                    ( editor, Cmd.none )

        ToggleShowCardDetail ->
            ( { editor | isShowCardDetail = not editor.isShowCardDetail }, Cmd.none )

        UpdateCardName index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardName index value enemy }, Cmd.none )

        UpdateCardTiming index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardTiming index value enemy }, Cmd.none )

        UpdateCardCost index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardCost index value enemy }, Cmd.none )

        UpdateCardRange index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardRange index value enemy }, Cmd.none )

        UpdateCardMaxRange index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardMaxRange index value enemy }, Cmd.none )

        UpdateCardTarget index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardTarget index value enemy }, Cmd.none )

        UpdateCardEffect index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardEffect index value enemy }, Cmd.none )

        UpdateCardDescription index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardDescription index value enemy }, Cmd.none )

        UpdateCardTags index value ->
            ( { editor | editingEnemy = Enemy.setEnemyCardTags index value enemy }, Cmd.none )

        DeleteConfirm ->
            let
                showModal =
                    Enemy.showModal editor

                e =
                    { showModal | modalContents = confirmDelete CancelConfirm Delete "エネミー" }
            in
            ( e, Cmd.none )

        CancelConfirm ->
            ( Enemy.closeModal editor, Cmd.none )

        Delete ->
            update CloseModal editor


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


createEditArea : EditorModel Msg -> Html Msg
createEditArea editor =
    div []
        [ EnemyEditorView.selectSampleEnemiesField "サンプルエネミー" "sampleEnemy" "" InputSampleCharacter editor.sampleEnemies
        , editor |> editAreaWithMsg
        , Modal.view editor.modalTitle editor.modalContents editor.modalState CloseModal
        ]


editArea : EditorModel Msg -> Html Msg
editArea editor =
    div []
        [ editor |> editAreaWithMsg
        , Modal.view editor.modalTitle editor.modalContents editor.modalState CloseModal
        ]


editAreaWithMsg =
    EnemyEditorView.editArea InputName InputKana InputTags InputDegreeOfThreat InputActivePower InputMemo ImageRequested InputCardImageCreatorName InputCardImageCreatorSite InputCardImageCreatorUrl TogglePublish InputSearchTagName OpenSkillModal ToggleShowCardDetail DeleteCard UpdateCardName UpdateCardTiming UpdateCardCost UpdateCardRange UpdateCardMaxRange UpdateCardTarget UpdateCardEffect UpdateCardDescription UpdateCardTags



-- inputCardImageArea : Enemy -> Html Msg
-- inputCardImageArea model =
--     case model.cardImageData of
--         "" ->
--             button [ onClick ImageRequested ] [ text "Upload image" ]
--         content ->
--             img
--                 [ class "cardImage", src content, width 74, height 94 ]
--                 []
-- skillArea enemy editor =
--     div [ style "padding-bottom" "5px" ]
--         [ h5 [] [ text "能力" ]
--         , div [] [ label [] [ input [ type_ "checkbox", checked editor.isShowCardDetail, onClick ToggleShowCardDetail ] [], span [] [ text "詳細を表示" ] ] ]
--         , div [ class (Models.Card.cardDetailClass editor.isShowCardDetail) ]
--             [ text "Ti:タイミング/Co:コスト/Ra:射程/MRa:最大射程/Ta:対象" ]
--         , div []
--             (List.concat
--                 [ [ div [ style "padding" "5px" ] (addButton "共通能力" OpenCommonSkillModal) ]
--                 , [ div [ style "padding" "5px" ] (addButton "特性能力" OpenTraitSkillModal) ]
--                 , [ div [ style "padding" "5px" ] (addButton "アイテム" OpenItemModal) ]
--                 , List.reverse <| Array.toList <| Array.indexedMap (\i card -> updateCardAreaWithMsg i editor.isShowCardDetail card) enemy.cards
--                 ]
--             )
--         ]
-- updateCardAreaWithMsg : Int -> (Bool -> Card.CardData -> Html Msg)
-- updateCardAreaWithMsg i =
--     updateCardArea (DeleteCard i) (UpdateCardName i) (UpdateCardTiming i) (UpdateCardCost i) (UpdateCardRange i) (UpdateCardMaxRange i) (UpdateCardTarget i) (UpdateCardEffect i) (UpdateCardDescription i) (UpdateCardTags i) ("card_" ++ String.fromInt i)


getNameList : List ( String, String ) -> List String
getNameList list =
    List.map (\( name, description ) -> name) list



-- cardWithInputArea : Enemy -> String -> String -> String -> String -> (String -> Msg) -> (Card.CardData -> Msg) -> Html Msg
-- cardWithInputArea enemy name label kind value msg cardMsg =
--     div [ class "row" ]
--         [ div [ class "col s6" ]
--             [ div [ class "input-field" ]
--                 [ inputArea name label value msg
--                 ]
--             ]
--         , div [ class "col s6" ]
--             [ modalCardOpenButton UpdateModal "カード選択" kind cardMsg
--             ]
--         ]


inputCard : Card.CardData -> msg -> Html msg
inputCard card msg =
    div [ onClick msg ] [ Card.cardView card ]



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


deleteModal =
    div [ style "padding" "20px 0" ]
        [ button [ onClick DeleteConfirm, class "btn waves-effect waves-light red", type_ "button", name "delete" ]
            [ text "削除"
            , i [ class "material-icons right" ] [ text "delete" ]
            ]
        ]
