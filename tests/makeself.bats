#!/usr/bin/env bats

setup_file() {
  load helpers/test_helper
}

@test "$(cyan 'release ')" {
  assert_exist "${RELEASE}"
}
