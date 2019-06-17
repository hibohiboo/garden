module Tests exposing (cardTest, getText, sheet, suite, unitTest)

import Dict exposing (Dict)
import Expect
import FirestoreApi as FSApi
import GoogleSpreadSheetApi as GSApi
import Models.Card as Card
import Models.CardId as CardId exposing (CardId)
import Models.Tag exposing (Tag)
import Route exposing (..)
import Test exposing (..)
import Url
import Utils.TextStrings as Tx



----


unitTest : Test
unitTest =
    describe "simple unit test"
        [ test "Inc adds one" <|
            \() ->
                1
                    |> Expect.equal 1
        ]


{-| テストケースを簡単に書くためのヘルパー関数
-}
testParse : String -> String -> Maybe Route -> Test
testParse name path expectedRoute =
    test name <|
        \_ ->
            Url.fromString ("http://example.com" ++ path)
                |> Maybe.andThen Route.parse
                |> Expect.equal expectedRoute


suite : Test
suite =
    describe "Route"
        [ testParse "shold parse Top" "/" (Just Route.Top)
        , testParse "shold parse Top with quesies" "/?dummy=value" (Just Route.Top)
        , testParse "shold parse Top with hash" "/#dumy" (Just Route.Top)
        , testParse "shold parse RuleBook" "/rulebook" (Just (Route.RuleBook Nothing))
        , testParse "shold parse RuleBook with hash" "/rulebook#first" (Just (Route.RuleBook (Just "first")))
        , testParse "shold parse PrivacyPolicy" "/privacy-policy" (Just Route.PrivacyPolicy)
        , testParse "shold parse Agreement" "/agreement" (Just Route.Agreement)
        , testParse "shold parse LoginUser" "/mypage" (Just Route.LoginUser)
        , testParse "shold parse CreateCharacter" "/mypage/character/create/aaa" (Just (Route.CharacterCreate "aaa"))
        , testParse "shold parse UpdateCharacter" "/mypage/character/edit/aaa/bbb" (Just (Route.CharacterUpdate "aaa" "bbb"))
        , testParse "shold parse Inavalid path" "/foo/bar/baz" Nothing
        ]


sheet : Test
sheet =
    describe "GoogleSpreadSheet"
        [ test "配列をレコードに入れるテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.tupleDecodeFromString "[\"a\", \"b\"]" of
                            Ok a ->
                                a

                            Err _ ->
                                Tuple.pair "" ""

                    expect =
                        ( "a", "b" )
                in
                Expect.equal actual expect
        , test "配列の配列を処理するテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.tuplesDecodeFromString "[[\"a\", \"b\"],[\"c\", \"d\"]]" of
                            Ok a ->
                                a

                            Err _ ->
                                [ Tuple.pair "a" "b" ]

                    expect =
                        [ Tuple.pair "a" "b", Tuple.pair "c" "d" ]
                in
                Expect.equal actual expect
        , test "オブジェクトの中の配列を処理するテスト" <|
            \_ ->
                let
                    actual =
                        case GSApi.tuplesInObjectDecodeFromString "{\"values\":[[\"a\", \"b\"],[\"c\", \"d\"]]}" of
                            Ok a ->
                                a

                            Err _ ->
                                []

                    expect =
                        [ Tuple.pair "a" "b", Tuple.pair "c" "d" ]
                in
                Expect.equal actual expect
        ]


getText : Test
getText =
    describe "TextStrings"
        [ describe "getText"
            [ test "値を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.getText (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "test" "default value"

                        expect =
                            "test"
                    in
                    Expect.equal actual expect
            , test "値がなければデフォルト値を取得するテスト" <|
                \_ ->
                    let
                        actual =
                            Tx.getText (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "bb" "default value"

                        expect =
                            "default value"
                    in
                    Expect.equal actual expect
            ]
        , test "スプレッドから取得した結果をディクショナリにするテスト" <|
            \_ ->
                let
                    actual =
                        GSApi.dictFromSpreadSheet "{\"values\":[[\"a\", \"b\"],[\"c\", \"d\"]]}"

                    expect =
                        Dict.fromList [ ( "a", "b" ), ( "c", "d" ) ]
                in
                Expect.equal actual expect
        ]


cardTest : Test
cardTest =
    describe "Card"
        [ describe "parser"
            [ test " a:1 形式のテキストをタプルで取得する" <|
                \_ ->
                    let
                        actual =
                            GSApi.parseTupleBySplitCollonString "a:1"

                        expect =
                            ( "a", 1 )
                    in
                    Expect.equal actual expect
            , test "デコーダを使ってタプルで取得する" <|
                \_ ->
                    let
                        actual =
                            case GSApi.tuplesIntDecodeFromString "\"a:1\"" of
                                Ok a ->
                                    a

                                Err err ->
                                    ( Debug.toString err, 0 )

                        expect =
                            ( "a", 1 )
                    in
                    Expect.equal actual expect
            , test "複数のタグを取得する" <|
                \_ ->
                    let
                        actual =
                            GSApi.parseTuplesBySplitCommmaString "a:1,b:2"

                        expect =
                            [ ( "a", 1 ), ( "b", 2 ) ]
                    in
                    Expect.equal actual expect
            , test "デコーダを使って複数のタグを取得する" <|
                \_ ->
                    let
                        actual =
                            case GSApi.decodeTuplesBySplitCommmaString "\"a:1,b:2\"" of
                                Ok a ->
                                    a

                                Err err ->
                                    [ ( Debug.toString err, 0 ) ]

                        expect =
                            [ ( "a", 1 ), ( "b", 2 ) ]
                    in
                    Expect.equal actual expect
            , test "デコーダを使って文字から数字を取得する" <|
                \_ ->
                    let
                        actual =
                            case GSApi.decodeIntFromString "\"1\"" of
                                Ok a ->
                                    a

                                Err err ->
                                    0

                        expect =
                            1
                    in
                    Expect.equal actual expect
            , test "デコーダを使ってCardで取得する" <|
                \_ ->
                    let
                        json =
                            """
            [
              "B-001",
              "走る",
              "能力",
              "基本能力",
              "10",
              "アクション",
              "4",
              "0",
              "0",
              "自身",
              "1",
              "移動1",
              "逃げてもいいし、向かってもいい。",
              "移動:0,基本能力:0",
              "/assets/images/card/main/run.png",
              "ヒューマンピクトグラム2.0",
              "http://pictogram2.com/",
              "/assets/images/card/frame/report.gif",
              "",
              "",
              "0"
            ]
  """

                        actual =
                            case Card.cardDecodeFromString json of
                                Ok a ->
                                    a

                                Err err ->
                                    let
                                        model =
                                            Card.initCard
                                    in
                                    { model | cardName = Debug.toString err }

                        expect =
                            Card.CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" 10 "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "" 0
                    in
                    Expect.equal actual expect
            , test "デコーダを使ってCardのリストを取得する" <|
                \_ ->
                    let
                        json =
                            """
{
  "range": "cardList!A2:T10",
  "majorDimension": "ROWS",
  "values": [
            [
              "B-001",
              "走る",
              "能力",
              "基本能力",
              "10",
              "アクション",
              "4",
              "0",
              "0",
              "自身",
              "1",
              "移動1",
              "逃げてもいいし、向かってもいい。",
              "移動:0,基本能力:0",
              "/assets/images/card/main/run.png",
              "ヒューマンピクトグラム2.0",
              "http://pictogram2.com/",
              "/assets/images/card/frame/report.gif",
              "",
              "",
              "0"
            ],
            [
              "B-001",
              "走る",
              "能力",
              "基本能力",
              "10",
              "アクション",
              "4",
              "0",
              "0",
              "自身",
              "1",
              "移動1",
              "逃げてもいいし、向かってもいい。",
              "移動:0,基本能力:0",
              "/assets/images/card/main/run.png",
              "ヒューマンピクトグラム2.0",
              "http://pictogram2.com/",
              "/assets/images/card/frame/report.gif",
              "",
              "",
              "0"
            ]
    ]
}
 """

                        actual =
                            case Card.cardDataListDecodeFromJson json of
                                Ok a ->
                                    a

                                Err err ->
                                    let
                                        model =
                                            Card.initCard
                                    in
                                    [ { model | cardName = Debug.toString err } ]

                        expect =
                            let
                                card =
                                    Card.CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" 10 "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "" 0
                            in
                            [ card, card ]
                    in
                    Expect.equal actual expect
            ]
        ]


getFirestoreApiJson : Test
getFirestoreApiJson =
    describe "FirestoreApi"
        [ describe "getText"
            [ test "値を取得するテスト" <|
                \_ ->
                    let
                        source =
                            """
{
  "documents": [
    {
      "name": "projects/garden-2a6de/databases/(default)/documents/publish/all/characters/05TsdJiaAyAPH8RLgsqt",
      "fields": {
        "labo": {
          "stringValue": "旧第一研究所"
        },
        "name": {
          "stringValue": "狐狸"
        },
        "characterId": {
          "stringValue": "05TsdJiaAyAPH8RLgsqt"
        }
      },
      "createTime": "2019-06-15T00:13:36.394340Z",
      "updateTime": "2019-06-15T00:13:36.394340Z"
    },
    {
      "name": "projects/garden-2a6de/databases/(default)/documents/publish/all/characters/iUjHq8ohVTI0tmftm1gW",
      "fields": {
        "labo": {
          "stringValue": ""
        },
        "name": {
          "stringValue": "にゅー"
        },
        "characterId": {
          "stringValue": "iUjHq8ohVTI0tmftm1gW"
        }
      },
      "createTime": "2019-06-15T00:22:36.133995Z",
      "updateTime": "2019-06-15T00:22:36.133995Z"
    }
  ]
}
                        """

                        actual =
                            Tx.getText (Dict.fromList [ ( "test", "test" ), ( "a", "b" ) ]) "test" "default value"

                        expect =
                            "test"
                    in
                    Expect.equal actual expect
            ]
        , test "valueを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.stringFromJson "name" """{"fields": {"name": {"stringValue": "test"}}"""

                    expect =
                        "test"
                in
                Expect.equal actual expect
        ]
