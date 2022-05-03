#!/usr/bin/env bash
set -eu -o pipefail

currency=${1:-USD}
# echo $currency
curl -s 'https://www.cbr-xml-daily.ru/daily_json.js' | jq .Valute.$currency.Value 
