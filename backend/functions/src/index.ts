
import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
// firestoreのgetapiから直接取得するようにしたため、以下は不要
// import characterRouter from './api/routes/characterRouter';
import { firestore } from './api/model/firestore';

const app = express();
app.use(cors({ origin: true }));

// register routes

// app.use('/api/v1', characterRouter);

// export const itemApi = functions.https.onRequest(app);


// メモ： functions/package.jsonを書き換えるときは、docker/firebase/functions/package.jsonも同様に書き換えること。
interface Character {
  uid?: string;
  characterId: string;
  name: string;
  labo: string;
  isPublished: boolean;
}

interface RootCharacter extends Character {
  authorRef?: FirebaseFirestore.DocumentReference;
}

export const onUsersCharacterCreate = functions.firestore.document('/users/{userId}/characters/{characterId}').onCreate(async (snapshot, context) => {
  if (!context) { return; }
  await copyToRootWithUsersCharacterSnapshot(snapshot, context);
});
export const onUsersCharacterUpdate = functions.firestore.document('/users/{userId}/characters/{characterId}').onUpdate(async (change, context) => {
  if (!context) { return; }
  await copyToRootWithUsersCharacterSnapshot(change.after, context);
});
export const onUsersCharacterDelete = functions.firestore.document('/users/{userId}/characters/{characterId}').onDelete(async (snapshot, context) => {
  if (!context) { return; }
  const characterId = snapshot.id;
  await firestore.collection('publish').doc('all').collection('characters').doc(characterId).delete();
  await firestore.collection('characters').doc(characterId).delete();
});

async function copyToRootWithUsersCharacterSnapshot(snapshot: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) {
  const characterId = snapshot.id;
  const userId = context.params.userId;
  const character = snapshot.data() as RootCharacter;
  delete character.uid;
  character.authorRef = firestore.collection('users').doc(userId);
  await firestore.collection('characters').doc(characterId).set(character, { merge: true });
  if (character.isPublished) {
    const publishChar = {
      characterId: character.characterId,
      name: character.name,
      labo: character.labo
    }
    await firestore.collection('publish').doc('all').collection('characters').doc(characterId).set(publishChar);
  } else {
    await firestore.collection('publish').doc('all').collection('characters').doc(characterId).delete();
  }
}