// import { Chart } from 'chart.js';
import * as firebase from 'firebase';
import * as firebaseui from 'firebaseui';
import * as M from 'M'; //  tslint-disable-line
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import User from './User';
require('../css/styles.scss'); // tslint:disable-line no-var-requires

const config = require('./_config'); // tslint:disable-line no-var-requires

// firebase使用準備
firebase.initializeApp(config);

// firebase認証準備
const auth = firebase.auth();

// firestore使用準備
const db = firebase.firestore();

// // ローカルストレージに保存するためのキー
// const STORAGE_KEY = 'insaneHandouts';

// // ローカルストレージから前回値を読み出し
// const flags: string = localStorage[STORAGE_KEY] === undefined ? '' : localStorage.insaneHandouts;
const flags = null;

// elmのＤＯＭを作成する元となるＤＯＭ要素
const mountNode: HTMLElement = document.getElementById('main')!;

// 前回値を初期値として与える
const app = Elm.Main.init({ node: mountNode, flags });

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
  const uiConfig = {
    signInSuccessUrl: '/mypage', // ログイン成功時の遷移先
    signInOptions: [
      firebase.auth.TwitterAuthProvider.PROVIDER_ID,
    ],
    callbacks: {
      signInSuccessWithAuthResult(authResult, redirectUrl) {
        // User successfully signed in.
        return true;
      },
      uiShown() {
        // The widget is rendered. Hide the loader.
        const elm = document.getElementById('loader');
        if (!elm) {
          return;
        }
        elm.style.display = 'none';
      },
    },
    // 利用規約。こことプライバシーポリシーのURLをhttps:// からのURLに変えると動かなくなることがある
    tosUrl: '/agreement',
    // プライバシーポリシー
    privacyPolicyUrl() {
      window.location.assign('/privacy-policy');
    },
  };
  try {
    const ui = firebaseui.auth.AuthUI.getInstance() || new firebaseui.auth.AuthUI(auth);
    ui.start('#firebaseui-auth-container', uiConfig);
  } catch (e) {
    // 2回目に読み込んだ時に、elmと競合してfirebaseui-auth-containerの要素が取得できなくなるので、再読み込み
    location.reload();
  }
};

// ログインページ遷移時にElmからイベントを取得
app.ports.urlChangeToLoginPage.subscribe(() => {
  auth.onAuthStateChanged((firebaseUser) => {
    let user: User | null = null;
    if (firebaseUser === null) {
      viewLoginPage();
      return;
    }
    user = new User(firebaseUser);
    // const twitterId = firebaseUser.providerData
    // .filter(function(userInfo:firebase.UserInfo){return userInfo.providerId === firebase.auth.TwitterAuthProvider.PROVIDER_ID;})
    // .map(function(userInfo:firebase.UserInfo){return userInfo.uid;})[0];

    const json = JSON.stringify(user);
    // console.log('firebaseuser', firebaseUser);
    // Add a new document in collection "cities"
    // ユーザをDBに追加。
    // db.collection("users").add(user).then(function (docRef) {
    //   console.log("Document written with ID: ", docRef.id);
    // });
    // Add a new document with a generated id. 先にidを作って
    const usersRef = db.collection("users");
    const query = usersRef.where("uid", "==", user.uid);

    query.get().then(function (querySnapshot) {
      if (querySnapshot.size === 0) {
        // データが取得できなければユーザを追加
        const newUserRef = usersRef.doc();
        newUserRef.set({
          uid: user!.uid
          , displayName: user!.displayName
          , createdAt: firebase.firestore.FieldValue.serverTimestamp()
          , updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        return;
      }
      querySnapshot.forEach(function (doc) {
        // doc.data() is never undefined for query doc snapshots
        // console.log(doc.id, " => ", doc.data());

        // 更新日時を更新する
        doc.ref.update({
          updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });

      });
    })
      .catch(function (error) {
        console.log("Error getting documents: ", error);
      });

    // then(function (doc) {
    //   if (doc.exists) {
    //     console.log("Document data:", doc.data());
    //   } else {
    //     // doc.data() will be undefined in this case
    //     console.log("No such document!");
    //   }
    // }).catch(function (error) {
    //   console.log("Error getting document:", error);
    //   // データが取得できなければユーザを追加
    //   const newUserRef = usersRef.doc();
    //   // 後からデータをセットする
    //   newUserRef.set({
    //     uid: user!.uid,
    //     displayName: user!.displayName
    //   });
    // });

    // サインイン情報を伝える。
    app.ports.signedIn.send(json);
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
  console.log('add', json);

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
