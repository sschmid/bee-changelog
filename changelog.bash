#!/usr/bin/env bash

changelog::_new() {
  echo "# changelog => $(changelog::_deps)"
  echo 'CHANGELOG_PATH=CHANGELOG.md
CHANGELOG_CHANGES=CHANGES.md
CHANGELOG_URL=https://github.com/sschmid/bee-changelog
CHANGELOG_TAG_PREFIX=""
CHANGELOG_TAG_SUFFIX=""'
}

changelog::_deps() {
  echo "version"
}

changelog::merge() {
  assert_file CHANGELOG_CHANGES
  local insert_changes_pattern="## \[Unreleased\]" insert_link_pattern="\[Unreleased\]:"
  local tmp_changes="${CHANGELOG_CHANGES}.tmp" tmp_link="link.tmp" prev_version version
  prev_version=$(grep --color=never "\[Unreleased\]:" CHANGELOG.md | grep -o -E --color=never "\d+\.\d+\.\d+")
  version="$(version::read)"

  {
    echo
    echo "## [${version}] - $(date +%Y-%m-%d)"
    cat "${CHANGELOG_CHANGES}"
  } > "${tmp_changes}"

  {
    echo "[Unreleased]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}...HEAD"
    echo "[${version}]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${prev_version}${CHANGELOG_TAG_SUFFIX}...${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}"
  } > "${tmp_link}"

  sed -i .bak \
    -e "/${insert_changes_pattern}/r ${tmp_changes}" \
    -e "/${insert_link_pattern}.*/r ${tmp_link}" \
    -e "/${insert_link_pattern}/d" \
    "${CHANGELOG_PATH}"

  rm "${CHANGELOG_PATH}.bak" "${tmp_changes}" "${tmp_link}"
}
