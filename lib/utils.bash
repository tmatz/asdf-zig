plugin_dir() {
  echo $(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
}

plugin_name() {
  basename "$(plugin_dir)"
}

cache_dir() {
  echo "$(plugin_dir)"/cache
}

get_index() {
  mkdir -p "$(cache_dir)"

  curl --fail \
    --silent \
    --location https://ziglang.org/download/index.json \
    --output "$(cache_dir)"/index.json.new \
    --time-cond "$(cache_dir)"/index.json

  if [ -f "$(cache_dir)"/index.json.new ]; then
    mv "$(cache_dir)"/index.json{.new,}
    json_parse "$(cat "$(cache_dir)"/index.json)" \
      >"$(cache_dir)"/parsed_index.txt
  fi
}

query_index_entry() {
  local keys="\"$1\""
  shift
  for arg in "$@"; do
    keys="$keys,\"$arg\""
  done

  <"$(cache_dir)"/parsed_index.txt \
    grep "\[$keys\]" |
    awk 'NR==1 { print $2 }' |
    tr -d '"'
}
