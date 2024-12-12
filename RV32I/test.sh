#!/bin/bash

# Check if at least one module file and a testbench file are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [module file(s)] [testbench file]"
    exit 1
fi

# Define directories
MODULE_DIR="modules"
TESTBENCH_DIR="testbenches"
RESULTS_DIR="${TESTBENCH_DIR}/results"

# Ensure the results directory exists
mkdir -p "$RESULTS_DIR"

# Extract the first module file name (without extension) to use as the result file prefix
result_file_prefix=$(basename "$1" .v)
result_file="${RESULTS_DIR}/${result_file_prefix}_result.vvp"

# Build the full paths for the module files and testbench file
module_files=""
for file in "$@"; do
    if [[ "$file" == *"_tb.v" ]]; then
        # Testbench file (from testbenches directory)
        testbench_file="${TESTBENCH_DIR}/${file}"
    else
        # Module files (from modules directory)
        module_files="${module_files} ${MODULE_DIR}/${file}"
    fi
done

# Check if the testbench file exists
if [ ! -f "$testbench_file" ]; then
    echo "Error: Testbench file '$testbench_file' not found."
    exit 2
fi

# Run iverilog to generate the result file
iverilog -o "$result_file" $module_files "$testbench_file"

# Check if iverilog ran successfully
if [ $? -ne 0 ]; then
    echo "Error: iverilog failed."
    exit 3
fi

# Run the generated result file with vvp
vvp "$result_file"