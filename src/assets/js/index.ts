// import { Chart } from 'chart.js';
// import * as firebase from 'firebase';
// import * as firebaseui from 'firebaseui';
import FireBaseBackEnd from './FireBaseBackEnd';
import * as M from 'M'; //  tslint-disable-line
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import User from './User';
require('../css/styles.scss'); // tslint:disable-line no-var-requires

// const config = require('./_config'); // tslint:disable-line no-var-requires

// firebase使用準備
// firebase.initializeApp(config);
const fireBase = new FireBaseBackEnd();
// firebase認証準備
const auth = fireBase.auth;;

// firestore使用準備
const db = fireBase.db;

// // ローカルストレージに保存するためのキー
// const STORAGE_KEY = 'insaneHandouts';

// // ローカルストレージから前回値を読み出し
// const flags: string = localStorage[STORAGE_KEY] === undefined ? '' : localStorage.insaneHandouts;
const flags = null;

// elmのＤＯＭを作成する元となるＤＯＭ要素
const mountNode: HTMLElement = document.getElementById('main')!;

// 前回値を初期値として与える
const app = Elm.Main.init({ node: mountNode, flags });

// DBのユーザ情報。
let userRef; // nullで初期化すると、Object is possibly 'null'.のエラーが発生。 firebase.firestore.DocumentReference | null

// elmのspa構築後に、dom要素に対してイベントを設定
app.ports.initializedToJs.subscribe(() => {
  // elmの構築したDOMにmaterializeを適用
  M.updateTextFields();
});

// ページ遷移後に呼ばれる
app.ports.urlChangeToJs.subscribe(() => {
  // 新しく構築されたDOMにmaterializeを適用
  M.updateTextFields();
});

// ログインが必要なときにfirebaseuiを使って要素を準備する
const viewLoginPage = () => {

};

// ログインページ遷移時にElmからイベントを取得
app.ports.urlChangeToLoginPage.subscribe(() => {
  auth.onAuthStateChanged(async (firebaseUser) => {
    let user: User | null = null;
    if (firebaseUser === null) {
      viewLoginPage();
      return;
    }
    user = new User(firebaseUser);
    // const twitterId = firebaseUser.providerData
    // .filter(function(userInfo:firebase.UserInfo){return userInfo.providerId === firebase.auth.TwitterAuthProvider.PROVIDER_ID;})
    // .map(function(userInfo:firebase.UserInfo){return userInfo.uid;})[0];


    // console.log('firebaseuser', firebaseUser);

    // usersコレクションへの参照を取得
    const usersRef = db.collection("users");

    // usersコレクションからログインユーザの情報を取得する条件を設定
    const query = usersRef.where("uid", "==", user.uid);

    // データベースのユーザ情報
    let dbuser;

    // ユーザを取得
    const querySnapshot = await query.get();

    await querySnapshot.forEach(function (doc) {
      // doc.data() is never undefined for query doc snapshots
      // console.log(doc.id, " => ", doc.data());
      // ユーザ情報取得
      userRef = doc.ref;
      dbuser = doc.data();

      // 更新日時を更新する
      userRef.update({
        updatedAt: fireBase.getTimestamp()
      });
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
    }
    // console.log(dbuser)

    const json = JSON.stringify({
      uid: dbuser.uid
      , displayName: dbuser.displayName
    });
    // console.log(json)
    // サインイン情報を伝える。
    app.ports.signedIn.send(json);
    const testJson = JSON.stringify([{
      kana: "kana"
      , name: "なまえ"
    },
    {
      kana: ""
      , name: ""
    }]);

    app.ports.getCharacters.send(testJson);
  });
});

// elm -> js
// サインアウト
app.ports.signOut.subscribe(() => {
  auth.signOut().then(() => {
    // console.log("Signed out.");
  });
});

// キャラクター新規作成
app.ports.saveNewCharacter.subscribe(json => {

  if (userRef === undefined) {
    alert('セッションが切れました。申し訳ないですが、もう一度ログインしなおしてください。');
    location.href = '/mypage/';
  }
  const data = JSON.parse(json);
  data.createdAt = fireBase.getTimestamp();
  data.updatedAt = fireBase.getTimestamp();
  userRef.collection('characters').add(data);
});

// キャラクター情報取得
app.ports.getCharacter.subscribe(id => {
  console.log(id);
});

// app.ports.initialize.subscribe(() => {
// });
// app.ports.toJs.subscribe((data: string) => {
//   // localStorage[STORAGE_KEY] = data;

//   // // 本文がなければ、ストレージから削除してしまう
//   // if(data.trim().length == 0){
//   //   localStorage.removeItem(STORAGE_KEY);
//   // }
// });
