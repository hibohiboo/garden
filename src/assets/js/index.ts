
import FireBaseBackEnd from './src_ts/FireBaseBackEnd';
// import * as M from 'M'; //  tslint-disable-line
import { Elm } from './Main'; //  eslint-disable-line import/no-unresolved
import { GOOGLE_SHEET_API_KEY } from "./src_ts/constants";
import { addCharacter, readCharacters, addUser, getCharacter, updateCharacter, deleteCharacter } from './src_ts/crud';
require('../css/styles.scss'); // tslint:disable-line no-var-requires

// firebase使用準備
const fireBase = new FireBaseBackEnd();

// firebase認証準備
const auth = fireBase.auth;;

// firestore使用準備
const db = fireBase.db;

// firebase storage
const storage = fireBase.storage;

// ローカルストレージに保存するためのキー
const STORAGE_KEY = 'gardenLoginData';
const flags = JSON.stringify({ googleSheetApiKey: GOOGLE_SHEET_API_KEY });

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

// ログインページ遷移時にElmからイベントを取得
app.ports.urlChangeToLoginPage.subscribe(() => {
  //認証を行う。
  auth.onAuthStateChanged(async (firebaseUser) => {

    // 認証できなかった場合は、ログインページを準備
    if (firebaseUser === null) {
      fireBase.createLoginUi();
      return;
    }

    // ローカルストレージからユーザ情報を読み出し
    if (localStorage[STORAGE_KEY] !== undefined) {
      const json = localStorage[STORAGE_KEY];
      app.ports.signedIn.send(json); // サインイン情報をelmに伝える。
      userData = JSON.parse(json);
      return;
    }

    userData = await addUser(firebaseUser, db, fireBase.getTimestamp());
    const json = JSON.stringify(userData);
    localStorage[STORAGE_KEY] = json; // ローカルストレージにユーザ情報を保存
    app.ports.signedIn.send(json);  // サインイン情報をelmに伝える。
  });
});


// firestoreからユーザの持つキャラクター一覧を取得
app.ports.getCharacters.subscribe(async storeUserId => {
  const characters = await readCharacters(db, storeUserId);
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
  await addCharacter(json, storage, db, fireBase.getTimestamp(), userData.uid);
  app.ports.createdCharacter.send(true);
});

// キャラクター情報取得
app.ports.getCharacter.subscribe(async data => {
  const storeUserId: string = data[0];
  const characterId: string = data[1];
  const character = await getCharacter(storeUserId, characterId, db);
  app.ports.gotCharacter.send(JSON.stringify(character));
});

// キャラクター更新
app.ports.updateCharacter.subscribe(async json => {
  await updateCharacter(json, storage, db, fireBase.getTimestamp(), userData.uid);
  app.ports.updatedCharacter.send(true);
});

// キャラクター削除
app.ports.deleteCharacter.subscribe(async ({ storeUserId, characterId }) => {
  await deleteCharacter(storeUserId, characterId, db);
  app.ports.deletedCharacter.send(true);
});

// ローカルストレージに、キャラクターのデータカードの使用済/負傷などを保存
app.ports.saveCardState.subscribe(obj => {
  localStorage[obj.characterId] = JSON.stringify({ states: obj.states, ap: obj.ap, currentAp: obj.currentAp });
});

// ローカルストレージに、キャラクターのデータカードの状態を読み出し
app.ports.getCardState.subscribe(characterId => {
  const json = localStorage[characterId];
  if (json === undefined) {
    return;
  }
  app.ports.gotCardState.send(json);
});
const battleSheetLocalStorageId = "battle-sheet-tmp";
app.ports.saveBattleSheet.subscribe(json => {
  // TODO: jsonだけではなく、追加でシートIDを受け取るようにして、シートIDを受け取ったらDBに保存するようにしたい。
  localStorage[battleSheetLocalStorageId] = json;
});

// ローカルストレージから、シートの状態を読み出し
app.ports.getBattleSheet.subscribe(async sheetId => {
  let json = localStorage[battleSheetLocalStorageId];
  if (sheetId !== "") {
    // TODO: DBから読み出し
  }
  if (json === undefined) {
    return;
  }
  app.ports.gotBattleSheet.send(json);
});