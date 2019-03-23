#!/bin/bash

# このシェルスクリプトのディレクトリの絶対パスを取得。
bin_dir=$(cd $(dirname $0) && pwd)

# docker-composeの起動。 OAuth用に9005. サンプルアプリ用に5000ポートを開放。
cd $bin_dir/../../docker && docker-compose run -p 9005:9005 -p 5000:5000 garden_firebase sh -c 'cd /app/functions && npm run serve'
