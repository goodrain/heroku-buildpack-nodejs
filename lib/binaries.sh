install_yarn() {
  local dir="$1"
  local version=${2:-1.x}
  local number
  local url

  echo "Resolving yarn version $version..."
  #if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "https://nodebin.herokai.com/v1/yarn/$platform/latest.txt"); then
  #  fail_bin_install yarn $version;
  #fi
  if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "http://lang.goodrain.me/nodejs/v1/yarn/linux-x64/latest-$version.txt"); then
    fail_bin_install yarn $version;
  fi
  yarn_url="http://lang.goodrain.me/nodejs/yarn/release/yarn-v$number.tar.gz"

  echo "Downloading and installing yarn ($number)..."
  local code=$(curl "$yarn_url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/yarn.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "$yarn_url"
    echo "Unable to download yarn: $code" && false
  fi
  rm -rf $dir
  mkdir -p "$dir"
  # https://github.com/yarnpkg/yarn/issues/770
  if tar --version | grep -q 'gnu'; then
    tar xzf /tmp/yarn.tar.gz -C "$dir" --strip 1 --warning=no-unknown-keyword
  else
    tar xzf /tmp/yarn.tar.gz -C "$dir" --strip 1
  fi
  chmod +x $dir/bin/*
  echo "Installed yarn $(yarn --version)"
}

install_nodejs() {
  local version=${1:-8.x}
  local dir="${2:?}"

  echo "Resolving node version $version..."
  #if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "https://nodebin.herokai.com/v1/node/$platform/latest.txt"); then
  #  fail_bin_install node $version;
  #fi
  if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "http://lang.goodrain.me/nodejs/v1/node/linux-x64/latest-$version.txt"); then
    fail_bin_install node $version;
  fi
  node_url="http://lang.goodrain.me/nodejs/node/release/linux-x64/node-v$number-linux-x64.tar.gz"
  echo "Downloading and installing node $number..."
  local code=$(curl "$node_url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/node.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "$node_url"
    echo "Unable to download node($number): $code" && false
  fi
  tar xzf /tmp/node.tar.gz -C /tmp
  rm -rf "$dir"/*
  mv /tmp/node-v$number-$os-$cpu/* $dir
  chmod +x $dir/bin/*
}

install_iojs() {
  local version=${1:-3.x}
  local dir="$2"

  echo "Resolving iojs version ${version:-(latest stable)}..."
  #if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "https://nodebin.herokai.com/v1/iojs/$platform/latest.txt"); then
  #  fail_bin_install iojs $version;
  #fi
  if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "http://lang.goodrain.me/nodejs/v1/iojs/linux-x64/latest-$version.txt"); then
    fail_bin_install iojs $version;
  fi

  iojs_url="http://lang.goodrain.me/nodejs/iojs/release/v$version/iojs-v$version-linux-x64.tar.gz"
  echo "Downloading and installing iojs $number..."
  local code=$(curl "$iojs_url" --silent --fail --retry 5 --retry-max-time 15 -o /tmp/iojs.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download iojs: $code" && false
  fi
  tar xzf /tmp/iojs.tar.gz -C /tmp
  mv /tmp/iojs-v$number-$os-$cpu/* $dir
  chmod +x $dir/bin/*
}

install_npm() {
  local version="$1"
  local dir="$2"
  local npm_lock="$3"
  local npm_version="$(npm --version)"

  # If the user has not specified a version of npm, but has an npm lockfile
  # upgrade them to npm 5.x if a suitable version was not installed with Node
  if $npm_lock && [ "$version" == "" ] && [ "${npm_version:0:1}" -lt "5" ]; then
    echo "Detected package-lock.json: defaulting npm to version 5.x.x"
    version="5.x.x"
  fi

  if [ "$version" == "" ]; then
    echo "Using default npm version: `npm --version`"
  elif [[ `npm --version` == "$version" ]]; then
    echo "npm `npm --version` already installed with node"
  else
    echo "Bootstrapping npm $version (replacing `npm --version`)..."
    if ! npm install --unsafe-perm --quiet -g "npm@$version" 2>@1>/dev/null; then
      echo "Unable to install npm $version; does it exist?" && false
    fi
    echo "npm `npm --version` installed"
  fi
}
