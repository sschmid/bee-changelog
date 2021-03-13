#!/usr/bin/env bash

changelog::_new() {
  echo "# changelog => $(changelog::_deps)"
  echo 'CHANGELOG_PATH=CHANGELOG.md
CHANGELOG_CHANGES=CHANGES.md'
}

changelog::_deps() {
  echo "version"
}

changelog::merge() {
  assert_file CHANGELOG_CHANGES
  [[ ! -f "${CHANGELOG_PATH}" ]] && touch "${CHANGELOG_PATH}"
  local tmp="${CHANGELOG_PATH}.tmp" version
  version="$(version::read)"
  echo "## [${version}] - $(date +%Y-%m-%d)" > "${tmp}"
  cat "${CHANGELOG_CHANGES}" >> "${tmp}"
  echo >> "${tmp}"
  cat "${CHANGELOG_PATH}" >> "${tmp}"
  mv "${tmp}" "${CHANGELOG_PATH}"
}
