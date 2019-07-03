export default class User {
  public uid: string;
  public displayName: string;
  constructor(user: any) {
    const { uid, displayName } = user;
    this.uid = uid;
    this.displayName = displayName;
  }
}
