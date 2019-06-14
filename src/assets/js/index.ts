
import FireBaseBackEnd from './FireBaseBackEnd';
// import * as M from 'M'; //  tslint-disable-line
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import User from './User';
import { GOOGLE_SHEET_API_KEY } from "./constants";
require('../css/styles.scss'); // tslint:disable-line no-var-requires

// firebase使用準備
const fireBase = new FireBaseBackEnd();

// firebase認証準備
const auth = fireBase.auth;;

// firestore使用準備
const db = fireBase.db;

// ローカルストレージに保存するためのキー
const STORAGE_KEY = 'gardenLoginData';

const flags = JSON.stringify({
  googleSheetApiKey: GOOGLE_SHEET_API_KEY
});

// elmのＤＯＭを作成する元となるＤＯＭ要素
const mountNode: HTMLElement = document.getElementById('main')!;

// 初期値を与える
const app = Elm.Main.init({ node: mountNode, flags });

// DBのユーザ情報。
let userData;  // nullで初期化すると、Object is possibly 'null'.のエラーが発生。 firebase.firestore.DocumentReference | null
if (localStorage[STORAGE_KEY] !== undefined) {
  const json = localStorage[STORAGE_KEY];
  userData = JSON.parse(json);
}
// ログインが必要なときにfirebaseuiを使って要素を準備する
const viewLoginPage = () => {
  fireBase.createLoginUi();
};

// ログインページ遷移時にElmからイベントを取得
app.ports.urlChangeToLoginPage.subscribe(() => {
  //認証を行う。
  auth.onAuthStateChanged(async (firebaseUser) => {
    let user: User | null = null;
    if (firebaseUser === null) {
      viewLoginPage();
      return;
    }
    // ローカルストレージからユーザ情報を読み出し
    if (localStorage[STORAGE_KEY] !== undefined) {
      const json = localStorage[STORAGE_KEY];

      // サインイン情報を伝える。
      app.ports.signedIn.send(json);

      userData = JSON.parse(json);
      return;
    }

    // ローカルストレージにユーザ情報がなければデータを更新する

    user = new User(firebaseUser);
    // const twitterId = firebaseUser.providerData
    // .filter(function(userInfo:firebase.UserInfo){return userInfo.providerId === firebase.auth.TwitterAuthProvider.PROVIDER_ID;})
    // .map(function(userInfo:firebase.UserInfo){return userInfo.uid;})[0];

    // usersコレクションへの参照を取得
    const usersRef = db.collection("users");

    // usersコレクションからログインユーザの情報を取得する条件を設定
    const query = usersRef.where("uid", "==", user.uid);

    // データベースのユーザ情報
    let dbuser;
    let userRef;
    let storeUserId;

    // ユーザを取得
    const querySnapshot = await query.get();

    await querySnapshot.forEach(function (doc) {
      // ユーザ情報取得
      userRef = doc.ref;
      dbuser = doc.data();
      storeUserId = doc.id;

      //   // 更新日時を更新する
      //   userRef.update({
      //     updatedAt: fireBase.getTimestamp()
      //   });
    });

    if (querySnapshot.size === 0) {
      // 取得できなければユーザを追加
      userRef = usersRef.doc();
      dbuser = {
        uid: user!.uid
        , maxCharacter: 5
        , displayName: user!.displayName
        , createdAt: fireBase.getTimestamp()
        , updatedAt: fireBase.getTimestamp()
      };
      userRef.set(dbuser);

      storeUserId = userRef.id;
    }
    // console.log(dbuser)
    userData = {
      uid: dbuser.uid
      , displayName: dbuser.displayName
      , storeUserId: storeUserId
    };

    const json = JSON.stringify(userData);

    // ローカルストレージにユーザ情報を保存
    localStorage[STORAGE_KEY] = json;

    // サインイン情報を伝える。
    app.ports.signedIn.send(json);
  });
});

type Character = {
  name: string,
  kana: string
}

// firestoreからユーザの持つキャラクターを取得
app.ports.getCharacters.subscribe(async storeUserId => {
  const querySnapshot = await db.collection("users").doc(storeUserId).collection('characters').get();
  const characters: Character[] = [];
  await querySnapshot.forEach((doc) => {
    const character = doc.data();
    character.storeUserId = storeUserId;
    character.characterId = doc.id;
    characters.push(character);
  });
  app.ports.gotCharacters.send(JSON.stringify(characters));
});

// elm -> js
// サインアウト
app.ports.signOut.subscribe(() => {
  auth.signOut().then(() => {
    // console.log("Signed out.");
    localStorage.removeItem(STORAGE_KEY);
  });
});

// キャラクター新規作成
app.ports.saveNewCharacter.subscribe(async json => {
  const data = JSON.parse(json);
  const userRef = db.collection("users").doc(data.storeUserId);
  data.createdAt = fireBase.getTimestamp();
  data.updatedAt = fireBase.getTimestamp();
  data.uid = userData.uid;
  await userRef.collection('characters').add(data);
  app.ports.createdCharacter.send(true);
});

// キャラクター情報取得
app.ports.getCharacter.subscribe(async data => {
  const storeUserId: string = data[0];
  const characterId: string = data[1];
  const characterRef = await db.collection("users").doc(storeUserId).collection('characters').doc(characterId).get();
  const character = characterRef.data();
  character.storeUserId = storeUserId;
  character.characterId = characterId;
  app.ports.gotCharacter.send(JSON.stringify(character));
});

// キャラクター更新
app.ports.updateCharacter.subscribe(async json => {
  const character = JSON.parse(json);
  const characterRef = await db.collection("users").doc(character.storeUserId).collection('characters').doc(character.characterId);
  character.updatedAt = fireBase.getTimestamp();

  character.uid = userData.uid;
  await characterRef.update(character);
  app.ports.updatedCharacter.send(true);
});

// ローカルストレージに、キャラクターのデータカードの使用済/負傷を保存
app.ports.saveCardState.subscribe(obj => {
  localStorage[obj.characterId] = JSON.stringify(obj.states);
});

app.ports.getCardState.subscribe(characterId => {
  const json = localStorage[characterId];
  if (json === undefined) {
    return;
  }
  app.ports.gotCardState.send(json);
});