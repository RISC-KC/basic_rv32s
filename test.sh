#!/bin/bash
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [module file(s)] [testbench file]"
    exit 1
fi

MODULE_DIR="modules"
TESTBENCH_DIR="testbenches"
RESULTS_DIR="${TESTBENCH_DIR}/results"

mkdir -p "$RESULTS_DIR"

result_file_prefix=$(basename "$1" .v)
result_file="${RESULTS_DIR}/${result_file_prefix}_result.vvp"

# Build the full paths for the module files and testbench file
module_files=""
for file in "$@"; do
    if [[ "$file" == *"_tb.v" ]]; then
        testbench_file="${TESTBENCH_DIR}/${file}"
    else
        module_files="${module_files} ${MODULE_DIR}/${file}"
    fi
done

# Check if the testbench file exists
if [ ! -f "$testbench_file" ]; then
    echo "Error: Testbench file '$testbench_file' not found."
    exit 2
fi

# Run iverilog
iverilog -o "$result_file" $module_files "$testbench_file"

if [ $? -ne 0 ]; then
    echo "Error: iverilog failed."
    exit 3
fi

vvp "$result_file"