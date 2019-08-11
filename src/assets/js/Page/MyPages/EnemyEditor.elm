module Page.MyPages.EnemyEditor exposing (Msg(..), deleteModal, editArea, update)

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
    | AddCard
    | InputCardImageCreatorName String
    | InputCardImageCreatorSite String
    | InputCardImageCreatorUrl String
      -- | InputSkillCard Card.CardData
      -- | UpdateModal String String (Card.CardData -> Msg)
      -- | OpenCommonSkillModal
    | OpenModal
      -- | DeleteCard Int
    | CloseModal
      -- | TogglePublish
      -- | ImageRequested
      -- | ImageSelected File
      -- | ImageLoaded (Result LoadErr String)
      -- | EnemyImageRequested
      -- | EnemyImageSelected File
      -- | EnemyImageLoaded (Result LoadErr String)
      -- | ToggleShowCardDetail
      -- | UpdateCardName Int String
      -- | UpdateCardTiming Int String
      -- | UpdateCardCost Int String
      -- | UpdateCardRange Int String
      -- | UpdateCardMaxRange Int String
      -- | UpdateCardTarget Int String
      -- | UpdateCardEffect Int String
      -- | UpdateCardDescription Int String
      -- | UpdateCardTags Int String
    | DeleteConfirm
    | CancelConfirm
    | Delete


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
        InputName s ->
            ( { editor | editingEnemy = Enemy.setEnemyName s enemy }, Cmd.none )

        InputKana s ->
            ( { editor | editingEnemy = Enemy.setEnemyKana s enemy }, Cmd.none )

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

        AddCard ->
            ( { editor | editingEnemy = Enemy.addEnemyCard Card.initCard enemy }, Cmd.none )

        -- InputSkillCard card ->
        --     let
        --         newCards =
        --             Array.push card enemy.cards
        --         newActivePower =
        --             Card.getActivePower newCards
        --         c =
        --             { enemy | cards = newCards, activePower = newActivePower }
        --     in
        --     ( ( c, { editor | modalState = Modal.Close } ), Cmd.none )
        -- AddCard ->
        --     let
        --         newCards =
        --             Array.push Card.initCard enemy.cards
        --         newActivePower =
        --             Card.getActivePower newCards
        --         c =
        --             { enemy | cards = newCards, activePower = newActivePower }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- DeleteCard i ->
        --     let
        --         newCards =
        --             deleteAt i enemy.cards
        --         newActivePower =
        --             Card.getActivePower newCards
        --         c =
        --             { enemy | cards = newCards, activePower = newActivePower }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- UpdateModal title kind m ->
        --     let
        --         filteredCards =
        --             if kind == "" then
        --                 editor.cards
        --             else
        --                 List.filter (\card -> card.kind == kind) editor.cards
        --         cardElements =
        --             div [ class "card-list" ] (List.map (\card -> inputCard card (m card)) filteredCards)
        --         newEditor =
        --             { editor
        --                 | modalContents = cardElements
        --             }
        --     in
        --     update OpenModal enemy newEditor
        -- OpenCommonSkillModal ->
        --     let
        --         filteredCards =
        --             List.filter (\card -> card.kind == "共通能力") editor.cards
        --         cardElements =
        --             div [ class "card-list" ] (List.map (\card -> inputCard card (InputSkillCard card)) filteredCards)
        --         newEditor =
        --             { editor
        --                 | modalContents = cardElements
        --             }
        --     in
        --     update OpenModal enemy newEditor
        OpenModal ->
            ( { editor | modalState = Modal.Open }, Cmd.none )

        CloseModal ->
            ( { editor | modalState = Modal.Close }, Cmd.none )

        -- InputMemo s ->
        --     let
        --         c =
        --             { enemy | memo = s }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- InputAP s ->
        --     let
        --         c =
        --             { enemy | activePower = s |> String.toInt |> Maybe.withDefault 0 }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- TogglePublish ->
        --     let
        --         c =
        --             { enemy | isPublished = not enemy.isPublished }
        --     in
        --     ( ( c, editor ), Cmd.none )
        -- ImageRequested ->
        --     ( ( enemy, editor )
        --     , Select.file expectedTypes ImageSelected
        --     )
        -- ImageSelected file ->
        --     if File.size file < 1048576 then
        --         ( ( enemy, editor )
        --         , Task.attempt ImageLoaded <| File.toUrl file
        --         )
        --     else
        --         ( ( enemy, editor )
        --         , Cmd.none
        --         )
        -- ImageLoaded result ->
        --     case result of
        --         Ok content ->
        --             let
        --                 c =
        --                     { enemy | cardImageData = content }
        --             in
        --             ( ( c, editor )
        --             , Cmd.none
        --             )
        --         Err error ->
        --             ( ( enemy, editor )
        --             , Cmd.none
        --             )
        -- EnemyImageRequested ->
        --     ( ( enemy, editor )
        --     , Select.file expectedTypes EnemyImageSelected
        --     )
        -- EnemyImageSelected file ->
        --     if File.size file < 1048576 then
        --         ( ( enemy, editor )
        --         , Task.attempt EnemyImageLoaded <| File.toUrl file
        --         )
        --     else
        --         ( ( enemy, editor )
        --         , Cmd.none
        --         )
        -- EnemyImageLoaded result ->
        --     case result of
        --         Ok content ->
        --             let
        --                 c =
        --                     { enemy | enemyImageData = content }
        --             in
        --             ( ( c, editor )
        --             , Cmd.none
        --             )
        --         Err error ->
        --             ( ( enemy, editor )
        --             , Cmd.none
        --             )
        -- InputImageCreatorName s ->
        --     ( ( { enemy | cardImageCreatorName = s }, editor ), Cmd.none )
        -- InputImageCreatorSite s ->
        --     ( ( { enemy | cardImageCreatorSite = s }, editor ), Cmd.none )
        -- InputImageCreatorUrl s ->
        --     ( ( { enemy | cardImageCreatorUrl = s }, editor ), Cmd.none )
        -- ToggleShowCardDetail ->
        --     ( ( enemy, { editor | isShowCardDetail = not editor.isShowCardDetail } ), Cmd.none )
        -- UpdateCardName index name ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardName index name }, editor ), Cmd.none )
        -- UpdateCardTiming index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardTiming index value }, editor ), Cmd.none )
        -- UpdateCardCost index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardCost index value }, editor ), Cmd.none )
        -- UpdateCardRange index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardRange index value }, editor ), Cmd.none )
        -- UpdateCardMaxRange index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardMaxRange index value }, editor ), Cmd.none )
        -- UpdateCardTarget index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardTarget index value }, editor ), Cmd.none )
        -- UpdateCardEffect index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardEffect index value }, editor ), Cmd.none )
        -- UpdateCardDescription index value ->
        --     ( ( { enemy | cards = enemy.cards |> Card.updateCardDescription index value }, editor ), Cmd.none )
        -- UpdateCardTags index value ->
        --     let
        --         newCards =
        --             enemy.cards |> Card.updateCardTags index value
        --         newActivePower =
        --             Card.getActivePower newCards
        --         c =
        --             { enemy | cards = newCards, activePower = newActivePower }
        --     in
        --     ( ( c, editor ), Cmd.none )
        DeleteConfirm ->
            let
                showModal =
                    Enemy.showModal editor

                e =
                    { showModal | modalContents = confirmDelete CancelConfirm Delete "エネミー" }
            in
            ( e, Cmd.none )

        CancelConfirm ->
            let
                closeModal =
                    Enemy.closeModal editor
            in
            ( closeModal, Cmd.none )

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


editArea : EditorModel Msg -> Html Msg
editArea editor =
    div []
        [ editor |> EnemyEditorView.editArea InputName
        , Modal.view editor.modalTitle editor.modalContents editor.modalState CloseModal
        ]



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
