// グローバル変数。webpack.DefinePluginで定義。環境変数から読み出し
declare var GOOGLE_SHEET_API_KEY: string;

const _GOOGLE_SHEET_API_KEY = GOOGLE_SHEET_API_KEY;

export { _GOOGLE_SHEET_API_KEY as GOOGLE_SHEET_API_KEY };
