module Models.Enemy exposing (EditorModel, Enemy, EnemyId, PageState(..), StorageState(..), UserId, addEnemyCard, closeModal, decodeFromValue, defaultEditorModel, defaultEnemy, deleteEnemyCard, encodeCrudValue, encodeEnemyToValue, enemiesDecoderFromFireStoreApi, enemiesDecoderFromFireStoreApiJson, enemyDecoder, enemyDecoderFromFireStoreApi, enemyDecoderFromFireStoreApiHealper, enemyDecoderFromFireStoreApiJson, getEnemyFromListId, getEnemyFromSession, getSampleEnemiesFromSession, justEnemyId, setEnemyActivePower, setEnemyCardCost, setEnemyCardDescription, setEnemyCardEffect, setEnemyCardImageCreatorName, setEnemyCardImageCreatorSite, setEnemyCardImageCreatorUrl, setEnemyCardImageData, setEnemyCardMaxRange, setEnemyCardName, setEnemyCardRange, setEnemyCardTags, setEnemyCardTarget, setEnemyCardTiming, setEnemyDegreeOfThreat, setEnemyIsPublished, setEnemyKana, setEnemyMemo, setEnemyName, setEnemyTags, showModal)

import Array exposing (Array)
import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Tag as Tag exposing (Tag)
import Session
import Utils.ModalWindow as Modal
import Utils.Util exposing (deleteAt)


type alias EnemyId =
    String


type alias UserId =
    String


type alias Enemy =
    { storeUserId : String
    , enemyId : EnemyId
    , name : String
    , kana : String
    , activePower : Int
    , memo : String
    , degreeOfThreat : Int
    , tags : List Tag
    , cards : Array CardData
    , cardImage : String
    , cardImageData : String
    , cardImageCreatorName : String
    , cardImageCreatorSite : String
    , cardImageCreatorUrl : String
    , isPublished : Bool
    }


defaultEnemy : Enemy
defaultEnemy =
    Enemy "" "" "" "" 0 "" 0 [] Array.empty "" "" "" "" "" False


setEnemyName : String -> Enemy -> Enemy
setEnemyName name enemy =
    { enemy | name = name }


setEnemyKana : String -> Enemy -> Enemy
setEnemyKana s enemy =
    { enemy | kana = s }


setEnemyActivePower : String -> Enemy -> Enemy
setEnemyActivePower s enemy =
    { enemy | activePower = Maybe.withDefault 0 <| String.toInt <| s }


setEnemyMemo : String -> Enemy -> Enemy
setEnemyMemo s enemy =
    { enemy | memo = s }


setEnemyDegreeOfThreat : String -> Enemy -> Enemy
setEnemyDegreeOfThreat s enemy =
    { enemy | degreeOfThreat = Maybe.withDefault 0 <| String.toInt <| s }


setEnemyCardImageData : String -> Enemy -> Enemy
setEnemyCardImageData s enemy =
    { enemy | cardImageData = s }


setEnemyCardImageCreatorName : String -> Enemy -> Enemy
setEnemyCardImageCreatorName s enemy =
    { enemy | cardImageCreatorName = s }


setEnemyCardImageCreatorSite : String -> Enemy -> Enemy
setEnemyCardImageCreatorSite s enemy =
    { enemy | cardImageCreatorSite = s }


setEnemyCardImageCreatorUrl : String -> Enemy -> Enemy
setEnemyCardImageCreatorUrl s enemy =
    { enemy | cardImageCreatorUrl = s }


setEnemyIsPublished : Bool -> Enemy -> Enemy
setEnemyIsPublished b enemy =
    { enemy | isPublished = b }


setEnemyTags : String -> Enemy -> Enemy
setEnemyTags s enemy =
    { enemy | tags = Tag.tagsFromString s }


addEnemyCard : Card.CardData -> Enemy -> Enemy
addEnemyCard card enemy =
    { enemy | cards = Array.push card enemy.cards }


deleteEnemyCard : Int -> Enemy -> Enemy
deleteEnemyCard i enemy =
    { enemy | cards = deleteAt i enemy.cards }


setEnemyCardName : Int -> String -> Enemy -> Enemy
setEnemyCardName index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardName index s }


setEnemyCardTiming : Int -> String -> Enemy -> Enemy
setEnemyCardTiming index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardTiming index s }


setEnemyCardCost : Int -> String -> Enemy -> Enemy
setEnemyCardCost index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardCost index s }


setEnemyCardRange : Int -> String -> Enemy -> Enemy
setEnemyCardRange index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardRange index s }


setEnemyCardMaxRange : Int -> String -> Enemy -> Enemy
setEnemyCardMaxRange index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardMaxRange index s }


setEnemyCardTarget : Int -> String -> Enemy -> Enemy
setEnemyCardTarget index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardTarget index s }


setEnemyCardEffect : Int -> String -> Enemy -> Enemy
setEnemyCardEffect index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardEffect index s }


setEnemyCardDescription : Int -> String -> Enemy -> Enemy
setEnemyCardDescription index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardDescription index s }


setEnemyCardTags : Int -> String -> Enemy -> Enemy
setEnemyCardTags index s enemy =
    { enemy | cards = enemy.cards |> Card.updateCardTags index s }


getEnemyFromListId : String -> List Enemy -> Maybe Enemy
getEnemyFromListId id list =
    case List.filter (\enemy -> id == enemy.enemyId) list of
        x :: xs ->
            Just x

        _ ->
            Nothing


getEnemyFromSession : Session.Data -> String -> Maybe Enemy
getEnemyFromSession session enemyId =
    Session.getEnemy session enemyId
        |> Maybe.andThen enemyDecoderFromFireStoreApiJson


enemyDecoderFromFireStoreApiJson : String -> Maybe Enemy
enemyDecoderFromFireStoreApiJson json =
    case D.decodeString enemyDecoderFromFireStoreApi json of
        Err a ->
            Nothing

        Ok m ->
            Just m


getSampleEnemiesFromSession : Session.Data -> List Enemy
getSampleEnemiesFromSession session =
    Session.getEnemiesFromJson session
        |> Maybe.andThen enemiesDecoderFromFireStoreApiJson
        |> (\list ->
                case list of
                    Just l ->
                        l

                    Nothing ->
                        []
           )


enemiesDecoderFromFireStoreApiJson : String -> Maybe (List Enemy)
enemiesDecoderFromFireStoreApiJson json =
    case D.decodeString enemiesDecoderFromFireStoreApi json of
        Err a ->
            Nothing

        Ok m ->
            Just m


enemiesDecoderFromFireStoreApi : Decoder (List Enemy)
enemiesDecoderFromFireStoreApi =
    D.at [ "documents" ] <| D.list enemyDecoderFromFireStoreApi


enemyDecoderFromFireStoreApi : Decoder Enemy
enemyDecoderFromFireStoreApi =
    FSApi.fields enemyDecoderFromFireStoreApiHealper


enemyDecoderFromFireStoreApiHealper : Decoder Enemy
enemyDecoderFromFireStoreApiHealper =
    D.succeed Enemy
        |> required "storeUserId" FSApi.string
        |> required "enemyId" FSApi.string
        |> required "name" FSApi.string
        |> optional "kana" FSApi.string ""
        |> optional "activePower" FSApi.int 4
        |> optional "memo" FSApi.string ""
        |> optional "degreeOfThreat" FSApi.int 1
        |> optional "tags" Tag.tagsDecoderFromFireStoreApi []
        |> optional "cards" (FSApi.array Card.cardDecoderFromFireStoreApi) (Array.fromList [])
        |> optional "cardImage" FSApi.string ""
        |> optional "cardImageData" FSApi.string ""
        |> optional "cardImageCreatorName" FSApi.string ""
        |> optional "cardImageCreatorSite" FSApi.string ""
        |> optional "cardImageCreatorUrl" FSApi.string ""
        |> optional "isPublished" FSApi.bool False


enemyDecoder : Decoder Enemy
enemyDecoder =
    D.succeed Enemy
        |> required "storeUserId" D.string
        |> required "enemyId" D.string
        |> required "name" D.string
        |> required "kana" D.string
        |> optional "activePower" D.int 4
        |> optional "memo" D.string ""
        |> optional "degreeOfThreat" D.int 1
        |> required "tags" (D.list Tag.tagDecoder)
        |> optional "cards" (D.array Card.cardDecoderFromJson) (Array.fromList [])
        |> optional "cardImage" D.string ""
        |> optional "cardImageData" D.string ""
        |> optional "cardImageCreatorName" D.string ""
        |> optional "cardImageCreatorSite" D.string ""
        |> optional "cardImageCreatorUrl" D.string ""
        |> optional "isPublished" D.bool False


decodeFromValue : D.Value -> Enemy
decodeFromValue value =
    case D.decodeValue enemyDecoder value of
        Err _ ->
            defaultEnemy

        Ok enemy ->
            enemy


justEnemyId : Maybe String -> String
justEnemyId enemyId =
    case enemyId of
        Just s ->
            s

        Nothing ->
            ""


type PageState
    = Create
    | Update


type StorageState
    = CreateEnemy UserId Enemy
    | UpdateEnemy UserId Enemy
    | DeleteEnemy UserId EnemyId
    | ReadEnemy UserId EnemyId


type alias EditorModel msg =
    { editingEnemy : Enemy
    , isCreateState : Bool
    , cards : List Card.CardData
    , searchCardTagName : String
    , modalTitle : String
    , modalContents : Modal.ModalContents msg
    , modalState : Modal.ModalState
    , isShowCardDetail : Bool
    , sampleEnemies : List Enemy
    }


defaultEditorModel : EditorModel msg
defaultEditorModel =
    EditorModel defaultEnemy True [] "エネミー" "" Modal.defaultModalContents Modal.Close False []


showModal : EditorModel msg -> EditorModel msg
showModal modal =
    { modal | modalState = Modal.Open }


closeModal : EditorModel msg -> EditorModel msg
closeModal modal =
    { modal | modalState = Modal.Close }


encodeEnemyToValue : Enemy -> E.Value
encodeEnemyToValue c =
    E.object
        [ ( "storeUserId", E.string c.storeUserId )
        , ( "enemyId", E.string c.enemyId )
        , ( "name", E.string c.name )
        , ( "kana", E.string c.kana )
        , ( "activePower", E.int c.activePower )
        , ( "memo", E.string c.memo )
        , ( "tags", E.list Tag.encodeTagToValue c.tags )
        , ( "cards", E.array Card.encodeCardToValue c.cards )
        , ( "cardImage", E.string c.cardImage )
        , ( "cardImageData", E.string c.cardImageData )
        , ( "degreeOfThreat", E.int c.degreeOfThreat )
        , ( "cardImageCreatorName", E.string c.cardImageCreatorName )
        , ( "cardImageCreatorSite", E.string c.cardImageCreatorSite )
        , ( "cardImageCreatorUrl", E.string c.cardImageCreatorUrl )
        ]


encodeCrudValue : StorageState -> E.Value
encodeCrudValue state =
    case state of
        CreateEnemy userId enemy ->
            E.object
                [ ( "state", E.string "Create" )
                , ( "storeUserId", E.string userId )
                , ( "enemy", encodeEnemyToValue enemy )
                ]

        UpdateEnemy userId enemy ->
            E.object
                [ ( "state", E.string "Update" )
                , ( "storeUserId", E.string userId )
                , ( "enemyId", E.string enemy.enemyId )
                , ( "enemy", encodeEnemyToValue enemy )
                ]

        DeleteEnemy userId enemyId ->
            E.object
                [ ( "state", E.string "Delete" )
                , ( "storeUserId", E.string userId )
                , ( "enemyId", E.string enemyId )
                ]

        ReadEnemy userId enemyId ->
            E.object
                [ ( "state", E.string "Read" )
                , ( "storeUserId", E.string userId )
                , ( "enemyId", E.string enemyId )
                ]
