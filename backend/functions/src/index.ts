
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp(functions.config().firebase);
const firestore = admin.firestore();

// メモ： functions/package.jsonを書き換えるときは、docker/firebase/functions/package.jsonも同様に書き換えること。


interface Post {
  readonly title: string;
  readonly body: string;
}

interface RootPost extends Post {
  authorRef?: FirebaseFirestore.DocumentReference;
}

export const onUsersPostCreate = functions.firestore.document('/users/{userId}/characters/{characterId}').onCreate(async (snapshot, context) => {
  await copyToRootWithUsersPostSnapshot(snapshot, context);
});
export const onUsersPostUpdate = functions.firestore.document('/users/{userId}/characters/{characterId}').onUpdate(async (change, context) => {
  await copyToRootWithUsersPostSnapshot(change.after, context);
});

async function copyToRootWithUsersPostSnapshot(snapshot: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) {
  const characterId = snapshot.id;
  const userId = context.params.userId;
  const post = snapshot.data() as RootPost;
  post.authorRef = firestore.collection('users').doc(userId);
  await firestore.collection('characters').doc(characterId).set(post, { merge: true });
}