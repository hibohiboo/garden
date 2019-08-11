module Models.Tag exposing
    ( Tag
    , encodeTagToValue
    , tagDecoder
    , tagsDecoder
    , tagsDecoderFromFireStoreApi
    , tagsDecoderFromJson
    , tagsFromString
    , tagsToString
    , toString
    )

import FirestoreApi as FSApi
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E


type alias Tag =
    { name : String
    , level : Int
    }


empty =
    Tag "" 0


tagsToString : List Tag -> String
tagsToString list =
    list |> List.map toString |> String.join ","


toString : Tag -> String
toString tag =
    if tag.level == 0 then
        tag.name

    else
        tag.name ++ ":" ++ String.fromInt tag.level


tagsFromString : String -> List Tag
tagsFromString value =
    value
        |> String.split ","
        |> List.map fromString
        |> List.filter (\t -> t /= Nothing)
        |> List.map (Maybe.withDefault empty)


fromString : String -> Maybe Tag
fromString str =
    case String.split ":" str of
        [ "" ] ->
            Nothing

        [] ->
            Nothing

        name :: level :: _ ->
            Just <| Tag name (String.toInt level |> Maybe.withDefault 0)

        name :: _ ->
            Just <| Tag name 0


tagsDecoder : Decoder (List Tag)
tagsDecoder =
    D.map
        (\str ->
            String.split "," str
                |> List.filterMap fromString
        )
        D.string


tagsDecoderFromJson : Decoder (List Tag)
tagsDecoderFromJson =
    D.oneOf
        [ D.list tagDecoder
        , D.succeed []
        ]


tagDecoder : Decoder Tag
tagDecoder =
    D.map2 Tag
        (D.field "name" D.string)
        (D.field "level" D.int)


tagsDecoderFromFireStoreApi : Decoder (List Tag)
tagsDecoderFromFireStoreApi =
    D.oneOf
        [ FSApi.list tagDecoderFromFireStoreApi

        -- タグが登録されていないとき、{}が返ってくる。対応しないとデコードに失敗するため、そのような場合のためにデコードができなければ空の配列を返す。
        , D.succeed []
        ]


tagDecoderFromFireStoreApi : Decoder Tag
tagDecoderFromFireStoreApi =
    D.succeed Tag
        |> required "name" FSApi.string
        |> optional "level" FSApi.int 0



-- ==============================================================================================
-- エンコーダ
-- ==============================================================================================


encodeTagToValue : Tag -> E.Value
encodeTagToValue tag =
    E.object
        [ ( "name", E.string tag.name )
        , ( "level", E.int tag.level )
        ]
