function work() {
  cd "$W0RK_D1R3CT0RY/$1" && \
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
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c ${1:-18}
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
  if [ "$#" -eq 0 ]; then
    echo "Usage: near_staking_deposits <account_id> [<account_id> ...]" >&2
    return 1
  fi

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

# near_staking_account zavodil.poolv1.near a.near b.near
# {
#   "a.near": {
#     "staked": 0,
#     "unstaked": 350.7035608688779
#   },
#   "b.near": {
#     "staked": 371.3468091092036,
#     "unstaked": 0
#   }
# }
function near_staking_account() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: near_staking_account <validator_id> <account_id> [<account_id> ...]" >&2
    return 1
  fi

  for account in ${@:2}; do
    local result="$(
      xh -I https://rpc.mainnet.near.org \
        jsonrpc=2.0 id=dontcare method=query \
        params:='{
          "request_type": "call_function",
          "finality": "optimistic",
          "account_id": "'"$1"'",
          "method_name": "get_account",
          "args_base64": "'$(echo -n '{"account_id":"'"$account"'"}' | base64)'"
        }'
    )" || return 1

    jq -r '.result.error' <<< "$result" \
      | grep -v '^null$' >/dev/null \
      && jq <<< "$result" \
      && return 1

    jq -r '.result.result[]' <<< "$result" \
      | u2c \
      | jq '{
          "'"$account"'": {
            staked: (.staked_balance | tonumber / pow(10; 24)),
            unstaked: (.unstaked_balance | tonumber / pow(10; 24))
          }
        }'
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

# {
#   "accounts": {
#     "a.near": {
#       "validators": {
#         "astro-stakers.poolv1.near": {
#           "deposit": 2977.1029163720427,
#           "reward": 113.53010517995608,
#           "staked": 3090.633021551999,
#           "unstaked": 0
#         },
#         "zavodil.poolv1.near": {
#           "deposit": 2626.058084426484,
#           "reward": 118.74669581740272,
#           "staked": 2744.804780243887,
#           "unstaked": 0
#         }
#       },
#       "total": {
#         "deposit": 5603.161000798527,
#         "reward": 232.2768009973588,
#         "staked": 5835.437801795886,
#         "unstaked": 0
#       }
#     }
#   },
#   "total": {
#     "deposit": 5603.161000798527,
#     "reward": 232.2768009973588,
#     "staked": 5835.437801795886,
#     "unstaked": 0
#   }
# }
function near_staking_info() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: near_staking_info <account_id> [<account_id> ...]" >&2
    return 1
  fi

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
            near_staking_account "$validator" "$account" \
            | jq -r '
              .["'"$account"'"]
              | {
                "'"$validator"'": (
                  {
                    deposit: '"$deposit"',
                    reward: 0,
                  } + .
                )
                | ( . + { reward: ((.staked // 0) + (.unstaked // 0) - .deposit) } )
                | to_entries
                | map(
                    if .value > 1e-10 then .
                    else . + { value: 0 }
                    end
                  )
                | from_entries
                | ( . + { total: (.staked + .unstaked) } )
              }'
          done \
          | jq -s '
            add
            | {
              "'"$account"'": {
                validators: .,
                sum: (
                  { deposit: 0, reward: 0, staked: 0, unstaked: 0, total: 0 } + (
                    map(to_entries)
                    | add
                    | group_by(.key)
                    | map({
                      key: .[0].key,
                      value: map(.value) | add
                    })
                    | from_entries
                  )
                )
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
      sum: (
        { deposit: 0, reward: 0, staked: 0, unstaked: 0, total: 0 } + (
          [
            map(.sum | select(. != null) | to_entries)
            | add
            | select(. != null)
            | group_by(.key)
            | map({
              key: .[0].key,
              value: map(.value) | add
            })
            | from_entries
          ] | add
        )
      )
    }'
}

export PORTFOLIO_HISTORY="$HOME/.near/stake-history"

# save the portfolio state at the current time and
# show a side-by-side diff with the last most recent state
# does not save the state if there is no change
# $ near_portfolio <- get the current portfolio state and show a diff
# $ near_portfolio 0 <- get a diff of the last two portfolio states
# $ near_portfolio 1 <- get a diff of the two states before the last one
function near_portfolio() {
  if [ -z ${NEAR_PORTFOLIO_ACCOUNTS+x} ]; then
    echo "NEAR_PORTFOLIO_ACCOUNTS is not set"
    return 1
  fi

  if [ -z "$1" ]; then
    local new_file="$PORTFOLIO_HISTORY/$(date +%s).json"
    local portfolio="$(near_staking_info $NEAR_PORTFOLIO_ACCOUNTS[@])"
    <<< "$portfolio" > "$new_file"
  fi

  local two_files=($(ls -1 "$PORTFOLIO_HISTORY" | sort -n | grep -o '^[0-9]*.json$' | tail -n $(( 2 + ${1:-0} )) | head -n 2))

  if [ ${#two_files[@]} -eq 0 ]; then
    echo "\x1b[31mNo portfolio history found\x1b[0m" >&2
    return 1
  elif [ ${#two_files[@]} -eq 2 ]; then
    local cmd="delta -s $PORTFOLIO_HISTORY/${two_files[1]} $PORTFOLIO_HISTORY/${two_files[2]} --paging never --width $(tput cols)"
    echo "\x1b[38;5;244m$ $cmd\x1b[0m" >&2
    local diff
    if diff=$(eval "$cmd"); then :
    else
      bat <<< "$diff"
      return $?
    fi

    if [[ "$new_file" == "$PORTFOLIO_HISTORY/${two_files[2]}" ]]; then
      echo "\x1b[33mNo portfolio state changes, not saving\x1b[0m" >&2
      local cmd="rm $new_file"
      echo "\x1b[38;5;244m$ $cmd\x1b[0m" >&2
      eval "$cmd" || return $?
    fi
  else
  fi

  local cmd="cat $PORTFOLIO_HISTORY/${two_files[1]}"
  echo "\x1b[38;5;244m$ $cmd\x1b[0m" >&2
  eval "$cmd" | jq . --indent 4
}

function docker_clean_images() {
  local cmd="docker images --filter "dangling=true" -q --no-trunc | xargs -r docker rmi"
  echo "\x1b[38;5;244m$ $cmd\x1b[0m" >&2
  eval "$cmd"
}

# --- end --- #
