import * as firebase from 'firebase';
import * as firebaseui from 'firebaseui';

export default class FireBaseBackEnd {
  public auth;
  public db;
  public storage;

  /**
   * FireBaseを使用する準備を行う
   * @param {string} name
   * @param {number} age
   * @memberof FireBase
   */
  constructor() {
    // requireは静的必須
    const config = require('./_config'); // tslint:disable-line no-var-requires

    // firebase使用準備
    firebase.initializeApp(config);

    // firebase認証準備
    this.auth = firebase.auth();

    // firestore使用準備
    this.db = firebase.firestore();

    this.storage = firebase.storage();
  }

  public getTimestamp() {
    return firebase.firestore.FieldValue.serverTimestamp();
  }

  public createLoginUi() {
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
      const ui = firebaseui.auth.AuthUI.getInstance() || new firebaseui.auth.AuthUI(this.auth);
      ui.start('#firebaseui-auth-container', uiConfig);
    } catch (e) {
      // 2回目に読み込んだ時に、elmと競合してfirebaseui-auth-containerの要素が取得できなくなるので、再読み込み
      location.reload();
    }
  };


}