#!/bin/bash

set -e

source dev-container-features-test-lib

check "mypy --version" mypy --version

reportResults