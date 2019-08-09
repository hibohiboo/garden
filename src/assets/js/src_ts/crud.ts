import User from './User';

/**
 * データベースにユーザを新規登録する
 * 
 * @param firebaseUser 
 * @param db 
 * @param timestamp 
 */
export async function addUser(firebaseUser, db, timestamp) {
  // ローカルストレージにユーザ情報がなければデータを更新する
  const user: User = new User(firebaseUser);
  // const twitterId = firebaseUser.providerData
  // .filter(function(userInfo:firebase.UserInfo){return userInfo.providerId === firebase.auth.TwitterAuthProvider.PROVIDER_ID;})
  // .map(function(userInfo:firebase.UserInfo){return userInfo.uid;})[0];
  const usersRef = db.collection("users"); // usersコレクションへの参照を取得
  const query = usersRef.where("uid", "==", user.uid); // usersコレクションからログインユーザの情報を取得する条件を設定

  // データベースのユーザ情報
  let dbuser;
  let userRef;
  let storeUserId;
  const querySnapshot = await query.get();  // ユーザを取得

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
      , createdAt: timestamp
      , updatedAt: timestamp
    };
    userRef.set(dbuser);

    storeUserId = userRef.id;
  }

  const userData = {
    uid: dbuser.uid
    , displayName: dbuser.displayName
    , storeUserId: storeUserId
  };
  return userData;
};


type Character = {
  name: string,
  kana: string
};

/**
 * ユーザのキャラクターを取得する
 * 
 * @param storeUserId 
 * @param characterId 
 * @param db 
 */
export async function getCharacter(storeUserId, characterId, db) {
  const characterRef = await db.collection("users").doc(storeUserId).collection('characters').doc(characterId).get();
  const character = characterRef.data();
  character.storeUserId = storeUserId;
  character.characterId = characterId;
  return character;
}

/**
 * データベースから指定したユーザのキャラクター一覧を取得する
 * 
 * @param db 
 * @param storeUserId 
 */
export async function readCharacters(db, storeUserId) {
  const querySnapshot = await db.collection("users").doc(storeUserId).collection('characters').get();
  const characters: Character[] = [];
  await querySnapshot.forEach((doc) => {
    const character = doc.data();
    character.storeUserId = storeUserId;
    character.characterId = doc.id;
    characters.push(character);
  });
  return characters;
}

/**
 * データベースにキャラクターを登録する
 * 
 * @param json 
 * @param db 
 * @param timestamp 
 * @param uid 
 */
export async function addCharacter(json: string, storage, db, timestamp, uid) {
  let character = JSON.parse(json);
  const userRef = db.collection("users").doc(character.storeUserId);
  character.createdAt = timestamp;
  character.updatedAt = timestamp;
  character.uid = uid;

  const ref = await userRef.collection('characters').doc();
  character.characterId = ref.id;
  character = await updateCharacterImages(storage, character);
  return await userRef.collection('characters').doc(ref.id).set(character);
}

/**
 * データベースのキャラクターを更新する
 * 
 * @param json 
 * @param db 
 * @param timestamp 
 * @param uid 
 */

export async function updateCharacter(json, storage, db, timestamp, uid) {
  let character = JSON.parse(json);

  character = await updateCharacterImages(storage, character);

  // キャラクター更新
  const characterRef = await db.collection("users").doc(character.storeUserId).collection('characters').doc(character.characterId);
  character.updatedAt = timestamp;

  character.uid = uid;
  await characterRef.update(character);
}

async function updateCharacterImages(storage, character) {
  // 画像アップロード
  await Promise.all([
    updateImages(storage, "card", `card-{character.characterId}`, character.cardImageData, character),
    updateImages(storage, "character", `character-{character.characterId}`, character.characterImageData, character)
  ]);

  return character;
}

/**
 * 画像をストレージに保存して、URLをオブジェクトに設定。
 * オブジェクトから画像データを取り除く。
 * 
 * @param storage 
 * @param objectKey 
 * @param storageKey 
 * @param data 
 * @param target 
 */
async function updateImages(storage, objectKey, storageKey, data, target) {
  if (target[`${objectKey}ImageData`] === "") {
    return target;
  }

  const ref = storage.ref(storageKey);
  await ref.putString(data, 'data_url');
  const url = await ref.getDownloadURL();
  target[`${objectKey}Image`] = url;
  target[`${objectKey}ImageData`] = "";
  return target;
}

/**
 * データベースのキャラクターを削除する
 * 
 * @param storeUserId 
 * @param characterId 
 * @param db 
 */
export async function deleteCharacter(storeUserId, characterId, db) {
  await db.collection("users").doc(storeUserId).collection('characters').doc(characterId).delete();
}

export async function crudEnemy({ state, storeUserId, enemyId, enemy }) {
  console.log(state);
  if (state === "Create") {

  }
}