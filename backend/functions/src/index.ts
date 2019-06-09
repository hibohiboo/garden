
import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
import characterRouter from './api/routes/characterRouter';
import { firestore } from './api/model/firestore';

const app = express();
app.use(cors({ origin: true }));

// register routes
app.use('/api/v1', characterRouter);

export const itemApi = functions.https.onRequest(app);


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