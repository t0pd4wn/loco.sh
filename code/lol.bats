#!/usr/bin/env bats

@test "installing a profile" {
  ./loco -a install -p style-only
  [ "$status" -eq 1 ]
}
