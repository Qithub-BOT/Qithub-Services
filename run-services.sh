#!/bin/bash
#  Qithub サーバーのサービス・コンテナを起動するスクリプト
# =============================================================================
#   このスクリプトを実行すると、必要事項を確認/読み込みを行ってから
#   docker-compose で Qithub サーバーの各種サービス用の Docker コンテナが実行さ
#   れます。

#  Functions
# -----------------------------------------------------------------------------
function echoErrorConfigMissing () {
    cat << 'HEREDOC'
ERROR: Configuration file not found.

  1. Clone the following repo in this directory.
    $ git clone https://github.com/Qithub-BOT/Qithub-Config.git
  2. Copy the template as "ENV_VALUES".
    $ cp ./Qithub-Config/ENV_VALUES.tpl ./Qithub-Config/ENV_VALUES
  3. Edit the file "ENV_VALUES" and fill the needed variables.
    $ vi ./Qithub-Config/ENV_VALUES
  4. Then re-run the script.

HEREDOC
}

function updateConfig () {
    echo -n '- Updating configuration files ... '
    (cd $path_dir_config && git pull origin)
}

#  パスやファイル名の設定
# -----------------------------------------------------------------------------
name_dir_config='Qithub-Config'
name_file_config='ENV_VALUES'

path_dir_current=$(cd $(dirname $0); pwd)
path_dir_config="${path_dir_current}/${name_dir_config}"
path_file_config="${path_dir_config}/${name_file_config}"

#  環境変数の読み込み（コンテナに渡す環境変数です）
# -----------------------------------------------------------------------------
if [ ! -f $path_file_config ]; then
    echoErrorConfigMissing
    exit 1
fi

# 設定ファイルの読み込み
updateConfig
source $path_file_config

# デバッグモード未設定の場合のポカよけ
IS_MODE_DEBUG=${IS_MODE_DEBUG:-'true'}
export IS_MODE_DEBUG

if [ $IS_MODE_DEBUG = "true" ]; then
    # デバッグモード時の設定
    echo '- Server is in debug mode.'
    MSTDN_ACCESSTOKEN=$TOKEN_MASTODON_DEV
else
    # 本番モード時の設定
    echo '- Server is in production mode.'
    MSTDN_ACCESSTOKEN=$TOKEN_MASTODON_PROD
fi
export MSTDN_ACCESSTOKEN

# サービスコンテナの起動
echo -n '- Booting containers ... '
docker-compose up \
    --detach \
    --build \
    --remove-orphans
