
import * as functions from 'firebase-functions';

// メモ： functions/package.jsonを書き換えるときは、docker/firebase/functions/package.jsonも同様に書き換えること。

export const hello = functions.https.onRequest((request, response) => {
  response.status(200).send("Hello World")
});
