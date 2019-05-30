module Models.CardId exposing (CardId, decoder, encodeIdToValue, fromString, toString)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E


type CardId
    = CardId String


{-| `CardId` 型の値を作成する唯一の方法

    fromString ""
    --> Nothing

    fromString "B-001"
    --> Just (CardId "B-001")

-}
fromString : String -> Maybe CardId
fromString s =
    if String.length s /= 0 then
        Just (CardId s)

    else
        Nothing


{-| `CardId` 型の値を文字列に変換する唯一の方法
-}
toString : CardId -> String
toString (CardId s) =
    s


decoder : Decoder (Maybe CardId)
decoder =
    D.map fromString D.string


encodeIdToValue : Maybe CardId -> E.Value
encodeIdToValue id =
    case id of
        Just cardId ->
            E.string (toString cardId)

        Nothing ->
            E.string ""
