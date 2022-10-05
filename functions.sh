function work() {
  z "$W0RK_D1R3CT0RY/$1" && \
  figlet -fslant "Let's code </>" && \
  echo "Directory: $(pwd)"
}

function tsh() {
  ssh $@ -t tmux -u new -As d3v
}

function ipinfo() {
  curl -s "https://api.ipgeolocation.io/ipgeo?$([[ -v 1 ]]&&echo "ip=$1&")include=hostname" \
    -H 'referer: https://ipgeolocation.io/' \
  | jq
}

function ipinfo_min() {
  ipinfo $1 | jq '{ip,city,country_name,state_prov,loc:(.longitude+", "+.latitude),org:(.asn+" "+.organization),time:.time_zone.current_time,timezone:.time_zone.name}'
}

function ghc() {
  local _path=$(python3 -c "from urllib.parse import urlparse;path=urlparse('$1').path;print(path if '/' in path else '')")
  if [[ -n "$_path" ]]; then
    printf "\x1b[33m[i]\x1b[0m ghc [$_path]..."
    local clone_path="$W0RK_D1R3CT0RY/$_path"
    if [[ -d $clone_path ]]; then
      echo "\x1b[32m[exists]\x1b[0m"
    else
      echo "\x1b[36m[cloning]\x1b[0m"
      git clone -o upstream "git@github.com:$_path.git" "$clone_path" ${@:2} || return 1
    fi
    work "$_path"
  else
    echo '\x1b[31m[!]\x1b[0m invalid repo dir'
    return 1
  fi
}

function pw() {
  tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c ${1:-18}
}

# yoctoⓃ to Ⓝ
# y2n 694370026221312834841707777        -> 694.370026 Ⓝ
# echo 694370026221312834841707777 | y2n -> 694.370026 Ⓝ
function y2n() {
  if [ "$#" -gt 0 ]; then val=$1; else val=$(< /dev/stdin); fi
  echo "$val" | tr -d '\n' | awk '{print "scale=6;"$1"/10^24"}' | bc | xargs -n1 printf "%'f" | sed -e 's/0*$//' -e 's/\.$//' | awk '{print $1" Ⓝ"}'
}

# unicode to character
# echo 65 | u2c -> A
# u2c 123 125   -> {}
function u2c() {
  if [ "$#" -gt 0 ]; then val=($@); else val=($(< /dev/stdin)); fi
  printf '%b' $(printf '\\x%x' $val)
}

function tokens() {
  node "$W0RK_D1R3CT0RY"/miraclx/near-tokens/main.js $@
}

function tkn() {
  tokens $@ | tee "$W0RK_D1R3CT0RY"/miraclx/near-tokens/history/"$(($(date "+%s")/3600))"
}

function prices() {
  tokens $@ | (sleep .5; head -n 10)
}

function slrx() {
  alacritty --class 'sptlrx' -t "Spotify Lyrics" -e sptlrx --before "faint,italic"
}

function near_faucet() {
  account=`openssl rand -hex 16`

  xh https://helper.testnet.near.org/account \
    newAccountId="$account" \
    newAccountPublicKey=ed25519:Fp4FLrXufbDNDgHd8QwcWB5c5Yx3a6kQuvodxqYy3EC4

  NEAR_ENV=testnet near delete "$account" $1 \
    --seedPhrase "music pill foam among review orchard basic quit sauce calm message link"

  rm -rvf "$HOME"/.near-credentials/testnet/"$account".json
}

function unescape_string() {         
  printf '%b' "$(</dev/stdin)"
}

function pathy_has() {
  case ":$1:" in
    *:"$2":*) return 0;;
    *) return 1;;
  esac
}

function pathadd() {
  [[ -z "$2" ]] && 2="$1" && 1=""

  if pathy_has "$1" "$2"; then
    echo "$1"
  else
    echo "$2${1:+:$1}"
  fi
}

function capture_outputs() {
  outputs="$($* 2> >(STDERR="$(cat)"; declare -p STDERR) > >(STDOUT="$(cat)"; declare -p STDOUT))"
  echo "$outputs"$'\n'"(return $?)"
}

# Pushes to a remote branch, avoiding tags if we're on a PR
#
# $ gh alias set 'push' -s 'bash -c "source $HOME/.dotfiles/functions; gh_push $*"'
#
# $ gh push [GIT PUSH OPTIONS]
function gh_push() {(
  set -e
  if eval "$(capture_outputs gh pr view --json state -q '.state')"; then
    if [[ "$STDOUT" == 'OPEN' ]]; then
      echo -e "\x1b[38;5;244m$ git push --no-follow-tags $@\x1b[0m"
      git push --no-follow-tags $@
    fi
    echo "PR State: $STDOUT"
  elif [[ "$STDERR" == 'no pull requests found for branch'* ]]; then
    echo -e "\x1b[38;5;244m$ git push $@\x1b[0m"
    git push $@
  else echo "Error: $STDERR"
  fi
  return 1
)}

function extract_handles() {
  ggrep -ioP '@[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,38}' | sort -u
}

function humanify() {
  xargs | # convert newline separated list to space separated list
  sed 's/ /, /g' | # replace spaces with commas
  sed 's/\(.*\), \(.*\)$/\1 and \2/' # replace last comma with 'and'
}

# To generate automated release notes for a GitHub release
#
# $ pbpaste | extract_handles | humanify
# @iTranscend, @joel-u410, @joshuajbouw, @medvedNick and @miraclx

# near_staking_deposits a.near
# {
#  "a.near": {
#    "total": 5603.161000798527,
#    "validators": {
#      "zavodil.poolv1.near": 2626.058084426484,
#      "astro-stakers.poolv1.near": 2977.1029163720427
#    }
#  }
# }
function near_staking_deposits() {
  for account in $@; do
    xh -I "https://api.kitwallet.app/staking-deposits/$account" \
    | jq '
      [
        .[]
        | .deposit |= tonumber
        | select(.deposit > 0)
        | (.deposit /= pow(10; 24))
        | {(.validator_id): (.deposit)}
      ] | add
      | { "'"$account"'": { validators: ., total: values | add } }'
  done | jq -s add
}

# near_staking_balance zavodil.poolv1.near a.near b.near
# {
#   "a.near": 2739.359779726929,
#   "b.near": 371.3468091092036
# }
function near_staking_balance() {
  for account in ${@:2}; do
    xh -I https://rpc.mainnet.near.org \
      jsonrpc=2.0 id=dontcare method=query \
      params:='{
        "request_type": "call_function",
        "finality": "optimistic",
        "account_id": "'"$1"'",
        "method_name": "get_account_staked_balance",
        "args_base64": "'$(echo -n '{"account_id":"'"$account"'"}' | base64)'"
      }' \
      | jq -r '.result.result[]' \
      | u2c \
      | jq '{ "'"$account"'": (tonumber / pow(10; 24)) }'
  done | jq -s add
}

# initialize a semaphore with a given number of tokens
# https://unix.stackexchange.com/a/216475/514123
__open_sem(){
  mkfifo pipe-$$
  exec 3<>pipe-$$
  rm pipe-$$
  local i=$1
  for _ in {1..$i}; do
    printf 000 >&3
  done
}

# $ near_staking_info a.near
# {
#   "a.near": {
#     "total": {
#       "deposit": 5603.161000798527,
#       "reward": 220.7145258963833,
#       "staked": 5823.87552669491
#     },
#     "validators": {
#       "astro-stakers.poolv1.near": {
#         "deposit": 2977.1029163720427,
#         "reward": 107.41283059593843,
#         "staked": 3084.515746967981
#       },
#       "zavodil.poolv1.near": {
#         "deposit": 2626.058084426484,
#         "reward": 113.30169530044486,
#         "staked": 2739.359779726929
#       }
#     }
#   }
# }
function near_staking_info() {
  local files=()

  local N=5
  __open_sem $N

  local pidfile="$(mktemp)"

  for account in $@; do
    # acquire the semaphore
    read -u 3 -k 3 x && ((0==x)) || {
      for pid in "${pids[@]}"; do
        kill "$pid"
        lsof -p "$pid" +r 1 &>/dev/null
      done
      return $x
    }

    local file="$(mktemp)"
    files+=("$file")
    (
      (
        local deposits="$(near_staking_deposits "$account" | jq -r '.["'"$account"'"]')"
        if [[ "$deposits" == 'null' ]]; then
          echo '{"'"$account"'": null}' > "$file"
        else
          local validators="$(jq -r .validators <<< "$deposits")"
          for validator in $(jq -r 'keys[]' <<< "$validators"); do
            local deposit="$(jq -r '.["'"$validator"'"]' <<< "$validators")"
            near_staking_balance "$validator" "$account" \
            | jq -r '
              .["'"$account"'"]
              | {
                "'"$validator"'": {
                  deposit: '"$deposit"',
                  reward: [. - '"$deposit"', 0] | max,
                  staked: .
                }
              }'
          done \
          | jq -s '
            add
            | {
              "'"$account"'": {
                validators: .,
                total: map(to_entries)
                  | add
                  | group_by(.key)
                  | map({
                    key: .[0].key,
                    value: map(.value) | add
                  })
                  | from_entries
              }
            }' > "$file"
        fi
        # release the semaphore
        printf '%.3d' $? >&3
      ) &
      echo $! >> "$pidfile"
    )
  done

  while read -r pid; do
    lsof -p "$pid" +r 1 &>/dev/null
  done < "$pidfile"

  rm "$pidfile"

  for file in ${files[@]}; do
    cat "$file"
    rm "$file"
  done \
  | jq -s --indent 4 '
    add
    | {
      accounts: .,
      total: map(.total | select(. != null) | to_entries)
        | add
        | group_by(.key)
        | map({
          key: .[0].key,
          value: map(.value) | add
        })
        | from_entries
    }'
}

# --- end --- #