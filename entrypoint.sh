#!/bin/bash
set -e

CUSTOM_CERT_DIR="/etc/custom-ca-certs" # 利用者が証明書をマウントするディレクトリ

if [ -d "$CUSTOM_CERT_DIR" ] && [ "$(ls -A $CUSTOM_CERT_DIR)" ]; then
  echo "Custom CA certificates found in $CUSTOM_CERT_DIR. Updating CA store..."
  # .crt, .pem, .cer ファイルをコピー対象とする (必要に応じて拡張子を追加/変更)
  find "$CUSTOM_CERT_DIR" -type f \( -name "*.crt" -o -name "*.pem" -o -name "*.cer" \) -print0 | \
    xargs -0 -I {} cp {} /usr/local/share/ca-certificates/
  update-ca-certificates
  echo "CA certificates updated."
else
  echo "No custom CA certificates found in $CUSTOM_CERT_DIR or directory is empty."
fi

# 各コンポーネントのノード数を環境変数から取得、未設定または空文字の場合はデフォルト値を使用
PD_COUNT="${PD_NODE_COUNT:-1}"
KV_COUNT="${KV_NODE_COUNT:-1}"
DB_COUNT="${DB_NODE_COUNT:-1}"
TIFLASH_COUNT="${TIFLASH_NODE_COUNT:-0}"

# TIDBバージョンはDockerfileのENVから引き継がれる
# (TIDB_VERSION 環境変数が設定されている前提)

# コマンドを組み立てる
COMMAND_ARGS=(
    playground
    "${TIDB_VERSION}"
    --pd "${PD_COUNT}"
    --kv "${KV_COUNT}"
    --db "${DB_COUNT}"
    --tiflash "${TIFLASH_COUNT}"
    --host "0.0.0.0"
)

echo "Executing command: tiup ${COMMAND_ARGS[*]}"
exec tiup "${COMMAND_ARGS[@]}"
