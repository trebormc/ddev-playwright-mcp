setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-ddev-playwright-mcp
  mkdir -p $TESTDIR
  export PROJNAME=test-ddev-playwright-mcp
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  sleep 10
  # Verify playwright-mcp container is running and MCP endpoint responds
  run ddev exec -s playwright-mcp node -e "fetch('http://localhost:8931/mcp').then(() => console.log('ok')).catch(() => process.exit(1))"
  assert_success
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart >/dev/null
  health_checks
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev add-on get trebormc/ddev-playwright-mcp with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get trebormc/ddev-playwright-mcp
  ddev restart >/dev/null
  health_checks
}
