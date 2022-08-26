#!/bin/bash

set -euo pipefail

su-exec ${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var} fixuid

chown_dir() {
  dir=$1
  if [[ -d ${dir} ]] && [[ "$(stat -c %u:%g ${dir})" != "${FIXUID}:${FIXGID}" ]]; then
    echo chown $dir
    chown sycamore:sycamore $dir
  fi
}

chown_dir /usr/local/bundle
chown_dir /home/sycamore/.local/share/gem
chown_dir /home/sycamore/.gem

if [ "$(which "$1")" = '' ]; then
  if [ "$(ls -A /usr/local/bundle/bin)" = '' ]; then
    echo 'command not in path and bundler not initialized'
    echo 'running bundle install'
    su-exec sycamore bundle install
  fi
fi

if [ "$1" = 'bundle' ]; then
  set -- su-exec sycamore "$@"
elif ls /usr/local/bundle/bin | grep -q "\b$1\b"; then
  set -- su-exec sycamore bundle exec "$@"

  su-exec sycamore bash -c 'bundle check || bundle install'
fi

exec "$@"
