#!/bin/bash

craig_dir="/craig/"
init_system=$(ps --no-headers -o comm 1)
REDIS_START_TIMEOUT_S=35
POSTGRESQL_START_TIMEOUT_S=35
NODE_VERSION="18.18.2"


warning() {
    echo "[Craig][Warning]: $1"
}

error() {
    echo "[Craig][Error]: $1" >&2
}

info() {
    echo "[Craig][Info]: $1"
}


start_redis() {

  local start_time_s
  local current_time_s

  # otherwise 'redis-server' will not be found if this function
  # is ran separately
  source ~/.nvm/nvm.sh || true
  nvm use $NODE_VERSION

  # start redis and check if it is running, timeout if it hasn't started
  info "Starting Redis server..."

  if ! redis-cli ping | grep -q "PONG"
  then
    if [[ $init_system == "systemd" ]]
    then
      sudo systemctl enable --now redis-server # is disabled by default
    else
      sudo /etc/init.d/redis-server start #in case there is no systemd. In the future we can check sysv, systemd and others
    fi
    start_time_s=$(date +%s)

    while ! redis-cli ping | grep -q "PONG"
    do
      current_time_s=$(date +%s)
      sleep 1 # otherwise we get a bunch of connection refused errors

      if [[ $current_time_s-$start_time_s -ge $REDIS_START_TIMEOUT_S ]]
      then
        error "Redis server is not running or not accepting connections"
        info "Make sure Redis was successfully installed and rerun this script"
        info "You can also try increasing the REDIS_START_TIMEOUT_S value (currently $REDIS_START_TIMEOUT_S seconds)"
        exit 1
      fi
    done 
  fi

}


start_postgresql() {

  local start_time_s
  local current_time_s

  info "Starting PostgreSQL server..."

  if ! pg_isready
  then
    if [[ $init_system ==  "systemd" ]]
    then
      sudo systemctl enable --now postgresql # is enabled by default
    else
      sudo /etc/init.d/postgresql start #in case there is no systemd. In the future we can check sysv, systemd and others
    fi

    start_time_s=$(date +%s)

    while ! pg_isready
    do
      current_time_s=$(date +%s)
      sleep 1 # otherwise we get a bunch of connection refused errors

      if [[ $current_time_s-$start_time_s -ge $POSTGRESQL_START_TIMEOUT_S ]]
      then
        error "PostgreSQL server is not running or not accepting connections"
        info "Make sure PostgreSQL was successfully installed and rerun this script"
        info "You can also try increasing the POSTGRESQL_START_TIMEOUT_S value (currently $POSTGRESQL_START_TIMEOUT_S seconds)"
        exit 1
      fi
    done 
  fi
}





start_app(){

  # otherwise 'pm2' will not be found if this function
  # is ran separately
  source ~/.nvm/nvm.sh || true
  nvm use $NODE_VERSION

  info "Starting Craig..."

  cd "$craig_dir/apps/bot" && pm2 start "ecosystem.config.js"
  cd "$craig_dir/apps/dashboard" && pm2 start "ecosystem.config.js"
  cd "$craig_dir/apps/download" && pm2 start "ecosystem.config.js"
  cd "$craig_dir/apps/tasks" && pm2 start "ecosystem.config.js"

  pm2 save

  cd "$craig_dir"
}

start_redis
start_postgresql
start_app
pm2 logs