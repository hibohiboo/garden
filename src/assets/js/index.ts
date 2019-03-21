// import { Chart } from 'chart.js';
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import * as firebase from 'firebase';
import * as firebaseui from 'firebaseui';
require('../css/styles.scss'); // tslint:disable-line no-var-requires

const config = require('./_config'); // tslint:disable-line no-var-requires
firebase.initializeApp(config);

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
    window.location.assign('/privacy-policy.html');
  },
};
const ui = new firebaseui.auth.AuthUI(firebase.auth());

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
