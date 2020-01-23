#!/bin/bash

set -euo pipefail

function color_output() {
    local MESSAGE=$1
    local COLOR=$2
    local MOD=$3

    echo -e "${MOD}\e[${COLOR}m${MESSAGE}\e[0m"
}

function print_summary() {
    local MSG=$1
    local FILE=$2
    local COLOR=$3
    local MOD=$4
    local NUM

    NUM=$(wc -l <"$FILE")
    local HEADER_MSG="$MSG ($NUM):"

    color_output "$HEADER_MSG" "$COLOR" "::group::"
    while IFS= read -r line; do
        echo "${MOD}$line"
    done <"$FILE"
    echo "::endgroup::"
}

# Log colors
ANSI_RED=31
ANSI_GREEN=32
ANSI_YELLOW=33

# Treat warnings as error
FAIL_ON_WARN=0

# Files for parsing output
CPP_CHECK_OUTPUT="cppcheck.out"
CPP_CHECK_ERROR="cppcheck.out.error"
CPP_CHECK_WARN="cppcheck.out.warn"
CPP_CHECK_STYLE="cppcheck.out.style"
CPP_CHECK_PERF="cppcheck.out.perf"
CPP_CHECK_PORT="cppcheck.out.port"
CPP_CHECK_INFO="cppcheck.out.info"

echo "::group::Run cppcheck"
cppcheck --std=c++11 --output-file=$CPP_CHECK_OUTPUT --language=c++ --enable=all ./
echo "::endgroup::"

grep '(error)' $CPP_CHECK_OUTPUT >$CPP_CHECK_ERROR || true
grep '(warning)' $CPP_CHECK_OUTPUT >$CPP_CHECK_WARN || true
grep '(style)' $CPP_CHECK_OUTPUT >$CPP_CHECK_STYLE || true
grep '(performance)' $CPP_CHECK_OUTPUT >$CPP_CHECK_PERF || true
grep '(portability)' $CPP_CHECK_OUTPUT >$CPP_CHECK_PORT || true
grep '(information)' $CPP_CHECK_OUTPUT >$CPP_CHECK_INFO || true

print_summary "Errors" $CPP_CHECK_ERROR $ANSI_RED "::error::"
print_summary "Warnings" $CPP_CHECK_WARN $ANSI_YELLOW "::warning::"
print_summary "Style Warnings" $CPP_CHECK_WARN $ANSI_YELLOW "::warning::"
print_summary "Performance Warnings" $CPP_CHECK_WARN $ANSI_YELLOW "::warning::"
print_summary "Portability Warnings" $CPP_CHECK_WARN $ANSI_YELLOW "::warning::"
print_summary "Info Messages" $CPP_CHECK_INFO $ANSI_GREEN ""

NUM_ERROR=$(wc -l <$CPP_CHECK_ERROR)
NUM_WARN=$(wc -l <$CPP_CHECK_WARN)
NUM_STYLE=$(wc -l <$CPP_CHECK_STYLE)
NUM_PERF=$(wc -l <$CPP_CHECK_PERF)
NUM_PORT=$(wc -l <$CPP_CHECK_PORT)

let "NUM_TOTAL_WARN=$NUM_WARN + $NUM_STYLE + $NUM_PERF + $NUM_PORT"

RS=0
if [[ $NUM_ERROR -gt 0 ]]; then
    echo "::error::Check failed! Errors found."
    RS=1
elif [[ $FAIL_ON_WARN -ne 0 && $NUM_TOTAL_WARN -gt 0 ]]; then
    echo "::error::Check failed! Warnings found which are treated as errors."
    RS=1
else
    echo "Check passed!"
fi

exit $RS
