module Models.Enemy exposing
    ( EditorModel
    , Enemy
    , PageState(..)
    , StorageState(..)
    , defaultEditorModel
    , defaultEnemy
    , encodeCrudValue
    , setEnemyName
    )

import Array exposing (Array)
import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Tag as Tag exposing (Tag)
import Utils.ModalWindow as Modal


type alias EnemyId =
    String


type alias UserId =
    String


type alias Enemy =
    { storeUserId : String
    , enemyId : EnemyId
    , name : String
    , activePower : Int
    , memo : String
    , cardImage : String
    , cardImageData : String
    , kana : String
    , degreeOfThreat : Int
    , tags : List Tag
    , cards : Array CardData
    , cardImageCreatorName : String
    , cardImageCreatorSite : String
    , cardImageCreatorUrl : String
    }


defaultEnemy : Enemy
defaultEnemy =
    Enemy "" "" "" 0 "" "" "" "" 0 [] Array.empty "" "" ""


setEnemyName : String -> Enemy -> Enemy
setEnemyName name enemy =
    { enemy | name = name }


type PageState
    = Create
    | Read
    | Update


type StorageState
    = CreateEnemy UserId Enemy
    | UpdateEnemy UserId Enemy
    | DeleteEnemy UserId EnemyId


type alias EditorModel msg =
    { editingEnemy : Enemy
    , isCreateState : Bool
    , cards : List Card.CardData
    , searchCardKind : String
    , modalTitle : String
    , modalContents : Modal.ModalContents msg
    , modalState : Modal.ModalState
    , isShowCardDetail : Bool
    }


defaultEditorModel : EditorModel msg
defaultEditorModel =
    EditorModel defaultEnemy True [] "" "" Modal.defaultModalContents Modal.Close False


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
