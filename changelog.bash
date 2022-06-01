: "${CHANGELOG_PATH:=CHANGELOG.md}"
: "${CHANGELOG_CHANGES:=CHANGES.md}"
: "${CHANGELOG_TAG_PREFIX:=""}"
: "${CHANGELOG_TAG_SUFFIX:=""}"

CHANGELOG_INSERT_CHANGES_PATTERN="## \[Unreleased\]"
CHANGELOG_INSERT_LINK_PATTERN="\[Unreleased\]:"
CHANGELOG_TMP_CHANGES="${CHANGELOG_CHANGES}.tmp"
CHANGELOG_TMP_LINK="link.tmp"

changelog::help() {
  cat << 'EOF'
template:

  CHANGELOG_PATH=CHANGELOG.md # default
  CHANGELOG_CHANGES=CHANGES.md # default
  CHANGELOG_URL=https://github.com/sschmid/bee-changelog
  CHANGELOG_TAG_PREFIX="" # default
  CHANGELOG_TAG_SUFFIX="" # default

usage:

  merge     Merge the current version and timestamp as well as the
            content of the file CHANGELOG_CHANGES into CHANGELOG_PATH
  release   Create a new release with the current version and timestamp
            as well as the content of [Unreleased] in CHANGELOG_PATH
EOF
}

changelog::merge() {
  if [[ ! -f "${CHANGELOG_CHANGES}" ]]; then
    bee::log_error "${CHANGELOG_CHANGES} not found!"
    exit 1
  fi

  cat << EOF > "${CHANGELOG_TMP_CHANGES}"

## [$(semver::read)] - $(date +%Y-%m-%d)
$(< "${CHANGELOG_CHANGES}")
EOF

  _insert_changes
}

changelog::release() {
  cat << EOF > "${CHANGELOG_TMP_CHANGES}"

## [$(semver::read)] - $(date +%Y-%m-%d)
EOF

  _insert_changes
}

_insert_changes() {
  local prev_version version
  prev_version=$(grep --color=never "\[Unreleased\]:" "${CHANGELOG_PATH}" | grep -o -E --color=never "\d+\.\d+\.\d+")
  version="$(semver::read)"

  cat << EOF > "${CHANGELOG_TMP_LINK}"
[Unreleased]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}...HEAD
[${version}]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${prev_version}${CHANGELOG_TAG_SUFFIX}...${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}
EOF

  sed -i .bak \
    -e "/${CHANGELOG_INSERT_CHANGES_PATTERN}/r ${CHANGELOG_TMP_CHANGES}" \
    -e "/${CHANGELOG_INSERT_LINK_PATTERN}.*/r ${CHANGELOG_TMP_LINK}" \
    -e "/${CHANGELOG_INSERT_LINK_PATTERN}/d" \
    "${CHANGELOG_PATH}"

  rm "${CHANGELOG_PATH}.bak" "${CHANGELOG_TMP_CHANGES}" "${CHANGELOG_TMP_LINK}"
}
