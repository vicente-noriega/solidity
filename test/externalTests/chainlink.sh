#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2022 solidity contributors.
#------------------------------------------------------------------------------

set -e

source scripts/common.sh
source test/externalTests/common.sh

REPO_ROOT=$(realpath "$(dirname "$0")/../..")

verify_input "$@"
BINARY_TYPE="$1"
BINARY_PATH="$2"
SELECTED_PRESETS="$3"

function compile_fn { yarn compile; }
function test_fn { yarn test; }

function chainlink_test
{
    local repo="https://github.com/solidity-external-tests/chainlink"
    local ref_type=branch
    local ref=develop_080
    local config_file="hardhat.config.ts"
    local config_var=config

    local compile_only_presets=(
        ir-optimize-evm+yul       # Compiles but tests fail. See https://github.com/nomiclabs/hardhat/issues/2115
        legacy-no-optimize        # Tests crash on a machine with 8 GB of RAM in CI "FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory"
    )
    local settings_presets=(
        "${compile_only_presets[@]}"
        #ir-no-optimize           # Compilation fails with "YulException: Variable var__value_775 is 1 slot(s) too deep inside the stack."
        #ir-optimize-evm-only     # Compilation fails with "YulException: Variable var__value_10 is 1 slot(s) too deep inside the stack"
        legacy-optimize-evm-only  # NOTE: This requires >= 4 GB RAM in CI not to crash
        legacy-optimize-evm+yul   # NOTE: This requires >= 4 GB RAM in CI not to crash
    )

    [[ $SELECTED_PRESETS != "" ]] || SELECTED_PRESETS=$(circleci_select_steps_multiarg "${settings_presets[@]}")
    print_presets_or_exit "$SELECTED_PRESETS"

    setup_solc "$DIR" "$BINARY_TYPE" "$BINARY_PATH"
    download_project "$repo" "$ref_type" "$ref" "$DIR"

    cd "contracts/"

    # TMP: Try running with hard-coded dependencies
    #neutralize_package_lock
    neutralize_package_json_hooks
    name_hardhat_default_export "$config_file" "$config_var"
    force_hardhat_compiler_binary "$config_file" "$BINARY_TYPE" "$BINARY_PATH"
    force_hardhat_compiler_settings "$config_file" "$(first_word "$SELECTED_PRESETS")" "$config_var"
    yarn install
    yarn add hardhat-gas-reporter

    replace_version_pragmas

    for preset in $SELECTED_PRESETS; do
        hardhat_run_test "$config_file" "$preset" "${compile_only_presets[*]}" compile_fn test_fn "$config_var"
        store_benchmark_report hardhat chainlink "$repo" "$preset"
    done
}

external_test Chainlink chainlink_test
