# Test the runtime selection

# source the Nos framework
. /opt/nos/common.sh

# source the nos test helper
. util/nos.sh

# source stub.sh to stub functions and binaries
. util/stub.sh

# initialize nos
nos_init

# source the nodejs libraries
. ${engine_lib_dir}/nodejs.sh

setup() {
  rm -rf /tmp/code
  mkdir -p /tmp/code
  nos_reset_payload
}

@test "npm install will not run more than once" {

  nodejs_npm_installed="true"
  npm_ran="false"

  stub_and_eval "nos_run_subprocess" "npm_ran=\"true\""

  nodejs_npm_install

  restore "nos_run_subprocess"
  nodejs_npm_installed="false"

  [ "$npm_ran" = "false" ]
}

@test "npm install will not run without a package.json file" {

  nos_init "$(cat <<-END
{
  "code_dir": "/tmp/code"
}
END
)"

  npm_ran="false"

  stub_and_eval "nos_run_subprocess" "npm_ran=\"true\""

  nodejs_npm_install

  restore "nos_run_subprocess"
  nodejs_npm_installed="false"

  [ "$npm_ran" = "false" ]
}

@test "npm install will run once if a package.json file is present" {

  nos_init "$(cat <<-END
{
  "code_dir": "/tmp/code"
}
END
)"

  npm_ran="false"

  stub_and_eval "nos_run_subprocess" "npm_ran=\"true\""

  mkdir -p /tmp/code
  touch /tmp/code/package.json

  nodejs_npm_install

  restore "nos_run_subprocess"
  nodejs_npm_installed="false"

  [ "$npm_ran" = "true" ]
}

@test "npm will not rebuild if the runtime hasn't changed" {

  nos_init "$(cat <<-END
{
  "code_dir": "/tmp/code"
}
END
)"

  rebuild_ran="false"

  stub_and_echo "nodejs_check_runtime" "true"

  stub_and_eval "nos_run_subprocess" "rebuild_ran=\"true\""

  nodejs_npm_rebuild

  restore "nodejs_check_runtime"
  restore "nos_run_subprocess"

  [ "$rebuild_ran" = "false" ]
}

@test "npm will rebuild if the runtime has changed" {

  nos_init "$(cat <<-END
{
  "code_dir": "/tmp/code"
}
END
)"

  rebuild_ran="false"

  stub_and_echo "nodejs_check_runtime" "false"

  stub_and_eval "nos_run_subprocess" "rebuild_ran=\"true\""

  nodejs_npm_rebuild

  restore "nodejs_check_runtime"
  restore "nos_run_subprocess"

  [ "$rebuild_ran" = "true" ]
}