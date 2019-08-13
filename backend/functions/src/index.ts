
import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
// firestoreのgetapiから直接取得するようにしたため、以下は不要
// import characterRouter from './api/routes/characterRouter';
import { firestore, bucket } from './api/model/firebase';

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

interface Enemy {
  uid?: string;
  enemyId: string;
  name: string;
  isPublished: boolean;
}

interface RootEnemy extends Enemy {
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
  const results = [];
  // 画像が消せなかったときは無視。
  bucket.file('card-' + characterId).delete().catch();
  bucket.file('character-' + characterId).delete().catch();
  results.push(firestore.collection('publish').doc('all').collection('characters').doc(characterId).delete());
  results.push(firestore.collection('characters').doc(characterId).delete());
  await Promise.all(results);
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

export const onUsersEnemyCreate = functions.firestore.document('/users/{userId}/enemies/{characterId}').onCreate(async (snapshot, context) => {
  if (!context) { return; }
  await copyToRootWithUsersEnemySnapshot(snapshot, context);
});
export const onUsersEnemyUpdate = functions.firestore.document('/users/{userId}/enemies/{characterId}').onUpdate(async (change, context) => {
  if (!context) { return; }
  await copyToRootWithUsersEnemySnapshot(change.after, context);
});
export const onUsersEnemyDelete = functions.firestore.document('/users/{userId}/enemies/{characterId}').onDelete(async (snapshot, context) => {
  if (!context) { return; }
  const characterId = snapshot.id;
  const results = [];
  bucket.file('card-' + characterId).delete().catch();
  bucket.file('character-' + characterId).delete().catch();
  results.push(firestore.collection('publish').doc('all').collection('enemies').doc(characterId).delete());
  results.push(firestore.collection('enemies').doc(characterId).delete());
  await Promise.all(results);
});

async function copyToRootWithUsersEnemySnapshot(snapshot: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) {
  const enemyId = snapshot.id;
  const userId = context.params.userId;
  const enemy = snapshot.data() as RootEnemy;
  delete enemy.uid;
  enemy.authorRef = firestore.collection('users').doc(userId);
  await firestore.collection('enemies').doc(enemyId).set(enemy, { merge: true });
  if (enemy.isPublished) {
    await firestore.collection('publish').doc('all').collection('enemies').doc(enemyId).set(enemy);
  } else {
    await firestore.collection('publish').doc('all').collection('enemies').doc(enemyId).delete();
  }

}