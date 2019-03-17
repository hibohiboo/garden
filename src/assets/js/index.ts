// import { Chart } from 'chart.js';
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
require('../css/styles.scss'); // tslint:disable-line no-var-requires

// ローカルストレージに保存するためのキー
const STORAGE_KEY = "insaneHandouts";

// elmのＤＯＭを作成する元となるＤＯＭ要素
const mountNode: HTMLElement = document.getElementById('main')!;

// ローカルストレージから前回値を読み出し
const flags: string = localStorage[STORAGE_KEY] === undefined ? "" : localStorage.insaneHandouts;

// 前回値を初期値として与える
const app = Elm.Main.init({ node: mountNode, flags });

// elmのspa構築後に、dom要素に対してイベントを設定
app.ports.initializedToJs.subscribe(() => {
  // ナビゲーションバーの表示/非表示を切り替える
  const pageElement = document.querySelector('.page')!;
  const naviButtons = document.querySelectorAll('.navi-btn')!;
  for (let i = 0, len = naviButtons.length; i < len; i++) {
    const naviButton = naviButtons[i];
    naviButton.addEventListener('click', () => {
      pageElement.classList.toggle('open');
    });
  }

});

// spaで画面遷移が起こった際にjsにイベントを伝える
app.ports.urlChangeToJs.subscribe(() => {
  // ナビゲーションバーを非表示にする
  const pageElement = document.querySelector('.page')!;
  pageElement.classList.remove('open');
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
