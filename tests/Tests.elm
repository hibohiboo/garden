module Tests exposing (cardTest, getFirestoreApiJson, getText, sheet, suite, unitTest)

import Array
import Dict exposing (Dict)
import Expect
import FirestoreApi as FSApi
import GoogleSpreadSheetApi as GSApi
import Json.Decode as D
import Models.Card as Card
import Models.CardId as CardId exposing (CardId)
import Models.Character as Character
import Models.CharacterListItem as CharacterListItem exposing (CharacterListItem)
import Models.Tag as Tag exposing (Tag)
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
                            Card.CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" 10 "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "" 0 False False
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
                                    Card.CardData (CardId.fromString "B-001") "走る" "能力" "基本能力" 10 "アクション" 4 0 0 "自身" 1 "移動1" "逃げてもいいし、向かってもいい。" [ Tag "移動" 0, Tag "基本能力" 0 ] "/assets/images/card/main/run.png" "ヒューマンピクトグラム2.0" "http://pictogram2.com/" "/assets/images/card/frame/report.gif" "" "" 0 False False
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
            [ test "キャラクターリストのアイテムを取得するテスト" <|
                \_ ->
                    let
                        source =
                            """
{"documents":
  [
    {
      "name": "projects/garden-2a6de/databases/(default)/documents/publish/all/characters/iUjHq8ohVTI0tmftm1gW",
      "fields": {
        "labo": {
          "stringValue": "研究所"
        },
        "name": {
          "stringValue": "にゅー"
        },
        "characterId": {
          "stringValue": "testId"
        }
      },
      "createTime": "2019-06-15T00:22:36.133995Z",
      "updateTime": "2019-06-15T00:22:36.133995Z"
    }
  ]
}
                        """

                        actual =
                            case D.decodeString CharacterListItem.characterListDecoder source of
                                Ok item ->
                                    item

                                Err e ->
                                    [ CharacterListItem (D.errorToString e) "" "" ]

                        expect =
                            [ CharacterListItem "testId" "にゅー" "研究所" ]
                    in
                    Expect.equal actual expect
            ]
        , test "キャラクターリストを取得するテスト" <|
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
          "stringValue": "aaa"
        }
      },
      "createTime": "2019-06-15T00:13:36.394340Z",
      "updateTime": "2019-06-15T00:13:36.394340Z"
    },
    {
      "name": "projects/garden-2a6de/databases/(default)/documents/publish/all/characters/iUjHq8ohVTI0tmftm1gW",
      "fields": {
        "labo": {
          "stringValue": "研究所"
        },
        "name": {
          "stringValue": "にゅー"
        },
        "characterId": {
          "stringValue": "testId"
        }
      },
      "createTime": "2019-06-15T00:22:36.133995Z",
      "updateTime": "2019-06-15T00:22:36.133995Z"
    }
  ]
}
                        """

                    actual =
                        CharacterListItem.characterListFromJson source

                    expect =
                        [ CharacterListItem "aaa" "狐狸" "旧第一研究所", CharacterListItem "testId" "にゅー" "研究所" ]
                in
                Expect.equal actual expect
        , test "stringを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.stringFromJson "name" """{"fields": {"name": {"stringValue": "test"}}}"""

                    expect =
                        "test"
                in
                Expect.equal actual expect
        , test "intを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.intFromJson "ap" """{"fields": {"ap": {"integerValue": "5"}}}"""

                    expect =
                        5
                in
                Expect.equal actual expect
        , test "timestampを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.timestampFromJson "name" """{"fields": {"name": {"timestampValue": "2019-06-15T01:25:14.040Z"}}}"""

                    expect =
                        "2019-06-15T01:25:14.040Z"
                in
                Expect.equal actual expect
        , test "boolを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.boolFromJson "name" """{"fields": {"name": {"booleanValue": true}}}"""

                    expect =
                        True
                in
                Expect.equal actual expect
        , test "複数のフィールドを取得するテスト" <|
            \_ ->
                let
                    tupleDecoder =
                        D.at [ "fields" ] (D.map2 Tuple.pair (D.at [ "x" ] FSApi.bool) (D.at [ "y" ] FSApi.string))

                    actual =
                        case D.decodeString tupleDecoder """{"fields": {"x": {"booleanValue": true}, "y": {"stringValue":"a"}}}""" of
                            Ok tuple ->
                                tuple

                            Err _ ->
                                ( False, "b" )

                    expect =
                        ( True, "a" )
                in
                Expect.equal actual expect

        -- TODO:
        , test "arrayを取得するテスト" <|
            \_ ->
                let
                    actual =
                        FSApi.arrayFromJson "name" """
                  {
                    "tags": {
                      "arrayValue": {
                        "values": [
                          {
                            "mapValue": {
                              "fields": {
                                "level": {
                                  "integerValue": "0"
                                },
                                "name": {
                                  "stringValue": "移動"
                                }
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                        """

                    expect =
                        True
                in
                Expect.equal actual expect
        , describe "キャラクターをStoreApiから取得"
            [ test "キャラクターを取得するテスト" <|
                \_ ->
                    let
                        actualResult =
                            D.decodeString Character.characterDecoderFromFireStoreApi """
{
  "name": "projects/garden-2a6de/databases/(default)/documents/characters/05TsdJiaAyAPH8RLgsqt",
  "fields": {
    "storeUserId": {
      "stringValue": "GTujnJoQ7wE1eOvHlfe0"
    },
    "characterId": {
      "stringValue": "05TsdJiaAyAPH8RLgsqt"
    },
    "name": {
      "stringValue": "狐狸"
    },
    "organ": {
      "stringValue": "脚"
    },
    "trait": {
      "stringValue": "身体強化"
    },
    "mutagen": {
      "stringValue": "血"
    },
    "activePower": {
      "integerValue": "4"
    }
  }
}
                        """

                        actual =
                            case actualResult of
                                Ok r ->
                                    r

                                Err _ ->
                                    Character.initCharacter "GTujnJoQ7wE1eOvHlfe0"

                        expect =
                            Character.Character "GTujnJoQ7wE1eOvHlfe0" "05TsdJiaAyAPH8RLgsqt" "狐狸" "" "脚" "身体強化" "血" (Array.fromList []) "" "" "" 4 False "" "" "" "" "" "" ""
                    in
                    Expect.equal actual expect
            , test "タグを取得するテスト" <|
                \_ ->
                    let
                        actualResult =
                            D.decodeString (D.at [ "tags" ] Tag.tagsDecoderFromFireStoreApi) """
{
  "tags": {
    "arrayValue": {
      "values": [
        {
          "mapValue": {
            "fields": {
              "name": {
                "stringValue": "移動"
              },
              "level": {
                "integerValue": "0"
              }
            }
          }
        },
        {
          "mapValue": {
            "fields": {
              "level": {
                "integerValue": "0"
              },
              "name": {
                "stringValue": "基本能力"
              }
            }
          }
        }
      ]
    }
  }
}
                        """

                        actual =
                            case actualResult of
                                Ok r ->
                                    r

                                Err _ ->
                                    []

                        expect =
                            [ Tag "移動" 0, Tag "基本能力" 0 ]
                    in
                    Expect.equal actual expect
            , test "カードを取得するテスト" <|
                \_ ->
                    let
                        actualResult =
                            D.decodeString (D.at [ "cards" ] <| FSApi.array Card.cardDecoderFromFireStoreApi) """
{
"cards": {
      "arrayValue": {
        "values": [
        {
          "mapValue": {
            "fields": {
              "maxRange": {
                "integerValue": "0"
              },
              "imgFrame": {
                "stringValue": "/assets/images/card/frame/report.gif"
              },
              "timing": {
                "stringValue": "アクション"
              },
              "frameByName": {
                "stringValue": ""
              },
              "deleteFlag": {
                "integerValue": "0"
              },
              "cardType": {
                "stringValue": "能力"
              },
              "cardName": {
                "stringValue": "走る"
              },
              "cost": {
                "integerValue": "4"
              },
              "maxLevel": {
                "integerValue": "1"
              },
              "exp": {
                "integerValue": "0"
              },
              "range": {
                "integerValue": "0"
              },
              "description": {
                "stringValue": "逃げてもいいし、向かってもいい。君たちは何処にだっていける。一歩ずつではあるけれど。"
              },
              "kind": {
                "stringValue": "基本能力"
              },
              "illustedByName": {
                "stringValue": "ヒューマンピクトグラム2.0"
              },
              "effect": {
                "stringValue": "移動1"
              },
              "imgMain": {
                "stringValue": "/assets/images/card/main/run.png"
              },
              "target": {
                "stringValue": "自身"
              },
              "frameByUrl": {
                "stringValue": ""
              },
              "illustedByUrl": {
                "stringValue": "http://pictogram2.com/"
              },
              "cardId": {
                "stringValue": "B000"
              },
              "tags": {
                "arrayValue": {
                  "values": [
                    {
                      "mapValue": {
                        "fields": {
                          "name": {
                            "stringValue": "移動"
                          },
                          "level": {
                            "integerValue": "0"
                          }
                        }
                      }
                    },
                    {
                      "mapValue": {
                        "fields": {
                          "level": {
                            "integerValue": "0"
                          },
                          "name": {
                            "stringValue": "基本能力"
                          }
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      ]
    }
  }
}
                        """

                        actual =
                            case actualResult of
                                Ok r ->
                                    r

                                Err _ ->
                                    Array.empty

                        expect =
                            Array.fromList [ Card.initCard ]
                    in
                    Expect.equal "" ""
            ]
        ]
