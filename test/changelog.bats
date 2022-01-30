setup() {
  load 'test_helper/bats-support/load.bash'
  load 'test_helper/bats-assert/load.bash'
  export BEE_ERR="BEE_ERR"
  changelog="${BATS_TEST_DIRNAME}/../changelog.bash"
  # shellcheck disable=SC2164
  cd "${BATS_TEST_TMPDIR}"
}

_setup_changes() {
  export CHANGELOG_CHANGES="${BATS_TEST_TMPDIR}/CHANGES.md"
  cat << 'EOF' > "${CHANGELOG_CHANGES}"
### Added
- More tests
EOF
}

_setup_changelog() {
  export CHANGELOG_PATH="${BATS_TEST_TMPDIR}/CHANGELOG.md"
  cat << 'EOF' > "${CHANGELOG_PATH}"
# Changelog
Test

## [Unreleased]

## [1.2.3] - 2021-12-13
### Added
- Tests 2

## [1.0.0] - 2021-12-13
### Added
- Tests 1

[Unreleased]: https://github.com/sschmid/bee-changelog/compare/1.2.3...HEAD
[1.2.3]: https://github.com/sschmid/bee-changelog/compare/1.0.0...1.2.3
[1.0.0]: https://github.com/sschmid/bee-changelog/releases/tag/1.0.0
EOF
}

_setup_version() {
  export test_version="$1"
  semver::read() { echo "${test_version}"; }
  export -f semver::read
  date() { echo "2021-12-13"; }
  export -f date
  export CHANGELOG_URL=https://github.com/sschmid/bee-changelog
}

_changelog() {
  run bee --batch "source ${changelog}" "$@"
}

@test "fails when CHANGELOG_CHANGES does not exist" {
  export CHANGELOG_CHANGES="${BATS_TEST_TMPDIR}/unknown.md"
  _changelog changelog::merge
  assert_failure
  assert_output "${BEE_ERR} ${CHANGELOG_CHANGES} not found!"
}

@test "fails when CHANGELOG_PATH does not exist" {
  _setup_changes
  export CHANGELOG_PATH="${BATS_TEST_TMPDIR}/unknown.md"
  _changelog changelog::merge
  assert_failure
  assert_output --partial "unknown.md: No such file or directory"
}

@test "merges changes into changelog" {
  _setup_changes
  _setup_changelog
  _setup_version 2.0.0
  _changelog changelog::merge
  assert_success
  run cat "${CHANGELOG_PATH}"
  cat << EOF | assert_output -
# Changelog
Test

## [Unreleased]

## [2.0.0] - 2021-12-13
### Added
- More tests

## [1.2.3] - 2021-12-13
### Added
- Tests 2

## [1.0.0] - 2021-12-13
### Added
- Tests 1

[Unreleased]: https://github.com/sschmid/bee-changelog/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sschmid/bee-changelog/compare/1.2.3...2.0.0
[1.2.3]: https://github.com/sschmid/bee-changelog/compare/1.0.0...1.2.3
[1.0.0]: https://github.com/sschmid/bee-changelog/releases/tag/1.0.0
EOF
}

@test "merges changes into changelog with tag prefix" {
  export CHANGELOG_TAG_PREFIX=changelog-
  _setup_changes
  _setup_changelog
  _setup_version 2.0.0
  _changelog changelog::merge
  assert_success
  run cat "${CHANGELOG_PATH}"
  cat << EOF | assert_output -
# Changelog
Test

## [Unreleased]

## [2.0.0] - 2021-12-13
### Added
- More tests

## [1.2.3] - 2021-12-13
### Added
- Tests 2

## [1.0.0] - 2021-12-13
### Added
- Tests 1

[Unreleased]: https://github.com/sschmid/bee-changelog/compare/changelog-2.0.0...HEAD
[2.0.0]: https://github.com/sschmid/bee-changelog/compare/changelog-1.2.3...changelog-2.0.0
[1.2.3]: https://github.com/sschmid/bee-changelog/compare/1.0.0...1.2.3
[1.0.0]: https://github.com/sschmid/bee-changelog/releases/tag/1.0.0
EOF
}

@test "merges changes into changelog with tag suffix" {
  export CHANGELOG_TAG_SUFFIX=-changelog
  _setup_changes
  _setup_changelog
  _setup_version 2.0.0
  _changelog changelog::merge
  assert_success
  run cat "${CHANGELOG_PATH}"
  cat << EOF | assert_output -
# Changelog
Test

## [Unreleased]

## [2.0.0] - 2021-12-13
### Added
- More tests

## [1.2.3] - 2021-12-13
### Added
- Tests 2

## [1.0.0] - 2021-12-13
### Added
- Tests 1

[Unreleased]: https://github.com/sschmid/bee-changelog/compare/2.0.0-changelog...HEAD
[2.0.0]: https://github.com/sschmid/bee-changelog/compare/1.2.3-changelog...2.0.0-changelog
[1.2.3]: https://github.com/sschmid/bee-changelog/compare/1.0.0...1.2.3
[1.0.0]: https://github.com/sschmid/bee-changelog/releases/tag/1.0.0
EOF
}
