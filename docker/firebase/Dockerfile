FROM node:8.16.0-alpine 

# コンテナ上の作業ディレクトリ作成
WORKDIR /app

# 後で確認出来るようにpackage.jsonを作成
RUN npm init -y

# firebase
RUN yarn global add firebase-tools
RUN yarn add --dev firebase-tools

RUN sed -i -e "s/\(\"scripts\": {\)/\1\n    \"firebase\": \"firebase\", /g" /app/package.json

# firebase function 
COPY functions /app/functions

# functions用のモジュールをインストールしておく。
RUN cd /app/functions && yarn add firebase-admin
RUN cd /app/functions && yarn add firebase-functions@latest
RUN cd /app/functions && yarn add --dev tslint
RUN cd /app/functions && yarn add --dev typescript

# ローカルでfunctionを実行するために必要
RUN yarn global add @google-cloud/functions-emulator --ignore-engines
RUN cd /app/functions && yarn add --dev firebase-functions-test