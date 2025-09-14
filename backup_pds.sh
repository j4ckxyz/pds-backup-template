#!/usr/bin/env bash
set -euo pipefail

# Backup all repositories hosted on a PDS.
# Usage: ./backup_pds.sh https://pds.example.com

PDS="${1%/}"
DATE=$(date -u +%F)

goat() {
    go run github.com/bluesky-social/indigo/cmd/goat@latest "$@"
}

mkdir -p users blobs plc pds

(goat pds describe "$PDS" || true) > pds/describe.json

handles=()
cursor=""
while :; do
    url="$PDS/xrpc/com.atproto.sync.listRepos?limit=1000"
    [[ -n $cursor ]] && url+="&cursor=$cursor"
    resp=$(curl -fsSL "$url")

    repos=$(echo "$resp" | jq -c '.repos[]')
    while IFS= read -r repo; do
        did=$(echo "$repo" | jq -r '.did')
        handle=$(echo "$repo" | jq -r '.handle')
        handles+=("$handle")
        dir="users/$handle"
        mkdir -p "$dir"
        echo "$repo" > "$dir/info.json"

        car="$dir/$DATE.car"
        curl -fsSL "$PDS/xrpc/com.atproto.sync.getRepo?did=$did" -o "$car"
        ls "$dir"/*.car 2>/dev/null | sort | head -n -7 | xargs -r rm --

        if [[ $did == did:plc:* ]]; then
            goat plc data "$did" > "plc/${did#did:plc:}.json" || true
            goat plc history "$did" > "plc/${did#did:plc:}_history.jsonc" || true
        fi
    done <<<"$repos"

    cursor=$(echo "$resp" | jq -r '.cursor // empty')
    [[ -z $cursor ]] && break
    sleep 1
done

# Only export blobs on the first day of the month
if [[ $(date +%d) == "01" ]]; then
    for handle in "${handles[@]}"; do
        mkdir -p "blobs/$handle"
        goat blob export --pds-host "$PDS" -o "blobs/$handle" "$handle" || true
    done
fi
