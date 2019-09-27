module Models.BattleSheet exposing
    ( BattleSheetCharacter
    , BattleSheetEnemy
    , BattleSheetItem
    , BattleSheetModel
    , BattleSheetMsg(..)
    , CountAreaItem
    , TabState(..)
    , decodeBattleSheetFromJson
    , encodeBattleSheetToJson
    , getCountAreaItems
    , getCountNotDamagedUnUsedCard
    , getIndexedCharacterCard
    , getIndexedEnemyCard
    , initBatlleSheetCharacter
    , initBatlleSheetEnemy
    , initBattleSheetModel
    , initCountAreaItem
    , initPageToken
    , maxAreaCount
    , updateBatlleSheetItemActivePower
    , updateBatlleSheetItemCardDamaged
    , updateBatlleSheetItemCardRandomDamaged
    , updateBatlleSheetItemCardUnUsedAll
    , updateBatlleSheetItemCardUsed
    , updateBatlleSheetItemIsDisplay
    , updateBatlleSheetItemName
    , updateBatlleSheetItemPosition
    )

import Array exposing (Array)
import Html exposing (Html, text)
import Http
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, required)
import Json.Encode as E
import Models.Card as Card exposing (CardData)
import Models.Character as Character exposing (Character)
import Models.EnemyListItem as EnemyListItem exposing (EnemyListItem)
import Session
import Utils.ModalWindow as Modal


type alias BattleSheetModel =
    { session : Session.Data
    , sheetName : String

    -- モーダルダイアログで選択用のリスト
    , enemyList : List EnemyListItem
    , characterList : List Character
    , charactersPageToken : String
    , count : Int
    , modalState : Modal.ModalState

    -- 選択したキャラクター・エネミーのリスト
    , enemies : Array BattleSheetEnemy
    , characters : Array BattleSheetCharacter
    , openCountAreaNumber : Int
    , modalTitle : String
    , modalContents : Html BattleSheetMsg
    , tab : TabState
    }


maxAreaCount =
    20


initPageToken : String
initPageToken =
    ""


initBattleSheetModel : Session.Data -> List EnemyListItem -> List Character -> BattleSheetModel
initBattleSheetModel session enemyList characterList =
    BattleSheetModel session "" enemyList characterList initPageToken 0 Modal.Close Array.empty Array.empty maxAreaCount "" (text "") InputTab


type BattleSheetMsg
    = GotEnemies (Result Http.Error String)
    | GotCharacters (Result Http.Error String)
    | GetNextCharacters
    | InputSheetName String
    | InputCount String
    | IncreaseCount
    | DecreaseCount
    | OpenModal
    | CloseModal
    | OpenEnemyModal
    | InputEnemy EnemyListItem
    | OpenCharacterModal
    | InputCharacter Character
    | AddEnemy
    | DeleteEnemy Int
    | UpdateEnemyName Int String
    | UpdateEnemyActivePower Int String
    | UpdateEnemyPosition Int String
    | AddCharacter
    | DeleteCharacter Int
    | UpdateCharacterName Int String
    | UpdateCharacterActivePower Int String
    | UpdateCharacterPosition Int String
    | UpdateOpenCountAreaNumber Int
    | SetInputTab
    | SetCardTab
    | SetPositionTab
    | SetSummaryTab
    | SetAllTab
    | ToggleCharacterCardSkillsDisplay Int
    | ToggleCharacterSkillCardUsed Int Int
    | ToggleCharacterSkillCardDamaged Int Int
    | ToggleEnemyCardSkillsDisplay Int
    | ToggleEnemySkillCardUsed Int Int
    | ToggleEnemySkillCardDamaged Int Int
    | GotBattleSheet String
    | UnUsedAll
    | RandomCharacterDamage Int
    | RandomCharacterDamaged Int Int


type alias BattleSheetItem a =
    { a | name : String, count : Int, activePower : Int, position : Int, isDisplaySkills : Bool, notDamagedCardNumber : Int }


type TabState
    = InputTab
    | CardTab
    | PositionTab
    | SummaryTab
    | AllTab


type alias BattleSheetEnemy =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , cardImage : String
    , data : Maybe EnemyListItem
    , isDisplaySkills : Bool
    , notDamagedCardNumber : Int
    }


type alias BattleSheetCharacter =
    { name : String
    , count : Int
    , activePower : Int
    , position : Int
    , cardImage : String
    , data : Maybe Character
    , isDisplaySkills : Bool
    , notDamagedCardNumber : Int
    }


type alias CountAreaItem =
    { characters : List String
    , enemies : List String
    }


encodeBattleSheetToJson : BattleSheetModel -> String
encodeBattleSheetToJson model =
    -- エンコード後のインデント0。
    model |> encodeBattleSheetToValue |> E.encode 0


encodeBattleSheetToValue : BattleSheetModel -> E.Value
encodeBattleSheetToValue model =
    E.object
        [ ( "sheetName", E.string model.sheetName )
        , ( "count", E.int model.count )
        , ( "enemies", E.array encodeBattleSheetEnemy model.enemies )
        , ( "characters", E.array encodeBattleSheetCharacter model.characters )
        ]


encodeBattleSheetEnemy : BattleSheetEnemy -> E.Value
encodeBattleSheetEnemy enemy =
    E.object
        [ ( "name", E.string enemy.name )
        , ( "count", E.int enemy.count )
        , ( "activePower", E.int enemy.activePower )
        , ( "cardImage", E.string enemy.cardImage )
        , ( "position", E.int enemy.position )
        , ( "data", encodeEnemyListItem enemy.data )
        , ( "notDamagedCardNumber", E.int enemy.notDamagedCardNumber )
        ]


encodeEnemyListItem : Maybe EnemyListItem -> E.Value
encodeEnemyListItem maybeItem =
    case maybeItem of
        Just enemy ->
            EnemyListItem.encodeEnemyListItem enemy

        Nothing ->
            E.null


encodeBattleSheetCharacter : BattleSheetCharacter -> E.Value
encodeBattleSheetCharacter item =
    E.object
        [ ( "name", E.string item.name )
        , ( "count", E.int item.count )
        , ( "activePower", E.int item.activePower )
        , ( "cardImage", E.string item.cardImage )
        , ( "position", E.int item.position )
        , ( "data", encodeCharacter item.data )
        , ( "notDamagedCardNumber", E.int item.notDamagedCardNumber )
        ]


encodeCharacter : Maybe Character -> E.Value
encodeCharacter maybeItem =
    case maybeItem of
        Just char ->
            Character.encodeCharacterToValue char

        Nothing ->
            E.null


decodeBattleSheetFromJson : String -> Result D.Error BattleSheetModel
decodeBattleSheetFromJson json =
    D.decodeString battleSheetDecoder json


battleSheetDecoder : Decoder BattleSheetModel
battleSheetDecoder =
    D.succeed BattleSheetModel
        |> hardcoded Session.empty
        |> required "sheetName" D.string
        |> hardcoded []
        |> hardcoded []
        |> hardcoded ""
        |> optional "count" D.int 0
        |> hardcoded Modal.Close
        |> optional "enemies" (D.array battleSheetEnemyDecoder) Array.empty
        |> optional "characters" (D.array battleSheetCharacterDecoder) Array.empty
        |> hardcoded 0
        |> hardcoded ""
        |> hardcoded (text "")
        |> hardcoded InputTab


battleSheetEnemyDecoder : Decoder BattleSheetEnemy
battleSheetEnemyDecoder =
    D.succeed BattleSheetEnemy
        |> required "name" D.string
        |> required "count" D.int
        |> required "activePower" D.int
        |> required "position" D.int
        |> optional "cardImage" D.string ""
        |> optional "data" (D.maybe EnemyListItem.enemyListItemDecoder) Nothing
        |> hardcoded True
        |> optional "notDamagedCardNumber" D.int 0


battleSheetCharacterDecoder : Decoder BattleSheetCharacter
battleSheetCharacterDecoder =
    D.succeed BattleSheetCharacter
        |> required "name" D.string
        |> required "count" D.int
        |> required "activePower" D.int
        |> required "position" D.int
        |> optional "cardImage" D.string ""
        |> optional "data" (D.maybe Character.characterDecoder) Nothing
        |> hardcoded True
        |> optional "notDamagedCardNumber" D.int 0


initCountAreaItem : CountAreaItem
initCountAreaItem =
    CountAreaItem [] []


initBatlleSheetEnemy : BattleSheetEnemy
initBatlleSheetEnemy =
    BattleSheetEnemy "" 0 0 1 "" Nothing True 0


initBatlleSheetCharacter : BattleSheetCharacter
initBatlleSheetCharacter =
    BattleSheetCharacter "" 0 0 1 "" Nothing True 0


updateBatlleSheetItemName : Int -> String -> Array { a | name : String } -> Array { a | name : String }
updateBatlleSheetItemName index name enemies =
    case Array.get index enemies of
        Just oldEnemy ->
            let
                enemy =
                    { oldEnemy | name = name }
            in
            Array.set index enemy enemies

        Nothing ->
            enemies


updateBatlleSheetItemActivePower : Int -> String -> Array { a | activePower : Int } -> Array { a | activePower : Int }
updateBatlleSheetItemActivePower index ap enemies =
    case Array.get index enemies of
        Just oldEnemy ->
            let
                iAp =
                    ap |> String.toInt |> Maybe.withDefault 0

                enemy =
                    { oldEnemy | activePower = iAp }
            in
            Array.set index enemy enemies

        Nothing ->
            enemies


updateBatlleSheetItemPosition : Int -> String -> Array { a | position : Int } -> Array { a | position : Int }
updateBatlleSheetItemPosition index stVal items =
    case Array.get index items of
        Just oldItem ->
            let
                val =
                    stVal |> String.toInt |> Maybe.withDefault 0
            in
            Array.set index { oldItem | position = val } items

        Nothing ->
            items


updateBatlleSheetItemIsDisplay : Int -> Array { a | isDisplaySkills : Bool } -> Array { a | isDisplaySkills : Bool }
updateBatlleSheetItemIsDisplay index items =
    case Array.get index items of
        Just oldItem ->
            Array.set index { oldItem | isDisplaySkills = not oldItem.isDisplaySkills } items

        Nothing ->
            items


updateBatlleSheetItemCardUsed : Int -> Int -> Array { a | data : Maybe { b | cards : Array CardData } } -> Array { a | data : Maybe { b | cards : Array CardData } }
updateBatlleSheetItemCardUsed itemIndex skillIndex items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                data =
                    oldItem.data |> Maybe.andThen (updateCardUsed skillIndex)
            in
            Array.set itemIndex { oldItem | data = data } items

        Nothing ->
            items


updateBatlleSheetItemCardUnUsedAll : Array { a | data : Maybe { b | cards : Array CardData } } -> Array { a | data : Maybe { b | cards : Array CardData } }
updateBatlleSheetItemCardUnUsedAll items =
    items |> Array.map (\item -> { item | data = item.data |> Maybe.andThen updateCardUnUsedAll })


updateCardUnUsedAll : { b | cards : Array CardData } -> Maybe { b | cards : Array CardData }
updateCardUnUsedAll data =
    let
        cards =
            data.cards |> Array.map (\card -> { card | isUsed = False })
    in
    Just { data | cards = cards }


updateCardUsed : Int -> { b | cards : Array CardData } -> Maybe { b | cards : Array CardData }
updateCardUsed index data =
    case Array.get index data.cards of
        Just card ->
            let
                cards =
                    Array.set index { card | isUsed = not card.isUsed } data.cards
            in
            Just { data | cards = cards }

        Nothing ->
            Nothing


updateBatlleSheetItemCardDamaged : Int -> Int -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int } -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int }
updateBatlleSheetItemCardDamaged itemIndex skillIndex items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                data =
                    oldItem.data |> Maybe.andThen (updateCardDamaged skillIndex)

                notDamagedCardNumber =
                    data |> Maybe.andThen (\d -> Just (Card.getNotDamagedCardNumber d.cards)) |> Maybe.withDefault 0
            in
            Array.set itemIndex { oldItem | data = data, notDamagedCardNumber = notDamagedCardNumber } items

        Nothing ->
            items


updateCardDamaged : Int -> { b | cards : Array CardData } -> Maybe { b | cards : Array CardData }
updateCardDamaged index data =
    case Array.get index data.cards of
        Just card ->
            let
                cards =
                    Array.set index { card | isDamaged = not card.isDamaged } data.cards
            in
            Just { data | cards = cards }

        Nothing ->
            Nothing



-- ランダムでスキルを破壊


getCountNotDamagedUnUsedCard : Int -> Array { a | data : Maybe { b | cards : Array CardData } } -> Int
getCountNotDamagedUnUsedCard itemIndex items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                data =
                    oldItem.data
            in
            data |> Maybe.andThen (\d -> Just (Card.getNotDamagedUnUsedCardNumber d.cards)) |> Maybe.withDefault 0

        _ ->
            0



-- ランダムダメージの対象のインデックスを取得して更新


updateBatlleSheetItemCardRandomDamaged : Int -> Int -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int } -> Array { a | data : Maybe { b | cards : Array CardData }, notDamagedCardNumber : Int }
updateBatlleSheetItemCardRandomDamaged itemIndex damageNumber items =
    case Array.get itemIndex items of
        Just oldItem ->
            let
                skillIndex =
                    oldItem.data |> Maybe.andThen (\d -> Just (findCountIndex damageNumber (\card -> not card.isUsed && not card.isDamaged) <| Array.toList d.cards)) |> Maybe.withDefault 0

                _ =
                    Debug.log "decodeUser" skillIndex

                data =
                    oldItem.data |> Maybe.andThen (updateCardDamaged skillIndex)

                notDamagedCardNumber =
                    data |> Maybe.andThen (\d -> Just (Card.getNotDamagedCardNumber d.cards)) |> Maybe.withDefault 0
            in
            Array.set itemIndex { oldItem | data = data, notDamagedCardNumber = notDamagedCardNumber } items

        Nothing ->
            items


findCountIndex : Int -> (a -> Bool) -> List a -> Int
findCountIndex =
    findIndexHelp 0 0


findIndexHelp : Int -> Int -> Int -> (a -> Bool) -> List a -> Int
findIndexHelp cntIndex index cnt predicate list =
    case list of
        [] ->
            -1

        x :: xs ->
            if predicate x && (cnt - 1) == cntIndex then
                index

            else if predicate x then
                findIndexHelp (cntIndex + 1) (index + 1) cnt predicate xs

            else
                findIndexHelp cntIndex (index + 1) cnt predicate xs



--


getCountAreaItems : List Int -> Array BattleSheetCharacter -> Array BattleSheetEnemy -> List CountAreaItem
getCountAreaItems counts characters enemies =
    List.map
        (\i ->
            CountAreaItem (filterActivePower i characters) (filterActivePower i enemies)
        )
        counts


filterActivePower : Int -> Array { a | activePower : Int, name : String } -> List String
filterActivePower i characters =
    characters
        |> Array.toList
        |> List.filter (\x -> x.activePower == i)
        |> List.map (\x -> x.name)


getIndexedCharacterCard : Array BattleSheetCharacter -> List ( Int, BattleSheetCharacter )
getIndexedCharacterCard characters =
    characters
        |> Array.indexedMap (\i x -> ( i, x ))
        |> Array.toList
        |> List.filter (\( i, x ) -> x.data /= Nothing)



--      |> List.map (\( i, x ) -> ( i, Maybe.withDefault (Character.initCharacter "") x.data ))


getIndexedEnemyCard : Array BattleSheetEnemy -> List ( Int, BattleSheetEnemy )
getIndexedEnemyCard enemies =
    enemies
        |> Array.indexedMap (\i x -> ( i, x ))
        |> Array.toList
        |> List.filter (\( i, x ) -> x.data /= Nothing)
