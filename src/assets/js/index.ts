// import { Chart } from 'chart.js';
import * as firebase from 'firebase';
import * as firebaseui from 'firebaseui';
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import User from './User';
require('../css/styles.scss'); // tslint:disable-line no-var-requires

const config = require('./_config'); // tslint:disable-line no-var-requires

// firebase使用準備
firebase.initializeApp(config);
// firebase認証準備
const auth = firebase.auth();

// ローカルストレージに保存するためのキー
const STORAGE_KEY = 'insaneHandouts';

// elmのＤＯＭを作成する元となるＤＯＭ要素
const mountNode: HTMLElement = document.getElementById('main')!;

// ローカルストレージから前回値を読み出し
const flags: string = localStorage[STORAGE_KEY] === undefined ? '' : localStorage.insaneHandouts;

// 前回値を初期値として与える
const app = Elm.Main.init({ node: mountNode, flags });

// elmのspa構築後に、dom要素に対してイベントを設定
app.ports.initializedToJs.subscribe(() => {

});

// ログインページ遷移時にイベントを伝える
app.ports.urlChangeToLoginPage.subscribe(() => {

  auth.onAuthStateChanged((firebaseUser) => {
    let user: User | null = null;
    if (firebaseUser) {
      user = new User(firebaseUser);
      // const twitterId = firebaseUser.providerData
      // .filter(function(userInfo:firebase.UserInfo){return userInfo.providerId === firebase.auth.TwitterAuthProvider.PROVIDER_ID;})
      // .map(function(userInfo:firebase.UserInfo){return userInfo.uid;})[0];
    }
    const json = JSON.stringify(user);
    console.log('firebaseuser', firebaseUser);
    console.log(user);
    // elm -> js
    // app.ports.logout.subscribe(() => {
    //   auth.signOut().then(() => {
    //     // console.log("Signed out.");
    //   });
    // });
  });
  const uiConfig = {
    signInSuccessUrl: '/',
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
    tosUrl: '/agreement.html',
    // プライバシーポリシー
    privacyPolicyUrl() {
      window.location.assign('/privacy-policy');
    },
  };

  // 認証ui使用準備
  const ui = new firebaseui.auth.AuthUI(auth);

  ui.start('#firebaseui-auth-container', uiConfig);
  console.log(ui);
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
