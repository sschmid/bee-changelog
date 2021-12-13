changelog::help() {
  echo "# changelog => $(changelog::deps | xargs) - https://github.com/sschmid/bee-changelog"
  cat << 'EOF'
CHANGELOG_PATH=CHANGELOG.md # default
CHANGELOG_CHANGES=CHANGES.md # default
CHANGELOG_URL=https://github.com/sschmid/bee-changelog
CHANGELOG_TAG_PREFIX="" # default
CHANGELOG_TAG_SUFFIX="" # default
EOF
}

: "${CHANGELOG_PATH:=CHANGELOG.md}"
: "${CHANGELOG_CHANGES:=CHANGES.md}"
: "${CHANGELOG_TAG_PREFIX:=""}"
: "${CHANGELOG_TAG_SUFFIX:=""}"

changelog::deps() {
  echo "version"
}

changelog::merge() {
  if [[ ! -f "${CHANGELOG_CHANGES}" ]]; then
    bee::log_error "${CHANGELOG_CHANGES} not found!"
    exit 1
  fi

  local insert_changes_pattern="## \[Unreleased\]" insert_link_pattern="\[Unreleased\]:"
  local tmp_changes="${CHANGELOG_CHANGES}.tmp" tmp_link="link.tmp" prev_version version
  prev_version=$(grep --color=never "\[Unreleased\]:" "${CHANGELOG_PATH}" | grep -o -E --color=never "\d+\.\d+\.\d+")
  version="$(version::read)"

  cat << EOF > "${tmp_changes}"

## [${version}] - $(date +%Y-%m-%d)
$(< "${CHANGELOG_CHANGES}")
EOF

  cat << EOF > "${tmp_link}"
[Unreleased]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}...HEAD
[${version}]: ${CHANGELOG_URL}/compare/${CHANGELOG_TAG_PREFIX}${prev_version}${CHANGELOG_TAG_SUFFIX}...${CHANGELOG_TAG_PREFIX}${version}${CHANGELOG_TAG_SUFFIX}
EOF

  sed -i .bak \
    -e "/${insert_changes_pattern}/r ${tmp_changes}" \
    -e "/${insert_link_pattern}.*/r ${tmp_link}" \
    -e "/${insert_link_pattern}/d" \
    "${CHANGELOG_PATH}"

  rm "${CHANGELOG_PATH}.bak" "${tmp_changes}" "${tmp_link}"
}
