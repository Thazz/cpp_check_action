#!/bin/bash

set -euo pipefail

function color_output() {
    local c=$1
    shift
    echo -e "\e[${c}m$*\e[0m"
}

ANSI_RED=31
ANSI_GREEN=32
ANSI_YELLOW=33

FAIL_ON_WARN=0
FAIL_DUE_ERR=1
FAIL_DUE_WARN=2

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

NUM_ERROR=$(cat $CPP_CHECK_ERROR | wc -l)
NUM_WARN=$(cat $CPP_CHECK_WARN | wc -l)
NUM_STYLE=$(cat $CPP_CHECK_STYLE | wc -l)
NUM_PERF=$(cat $CPP_CHECK_PERF | wc -l)
NUM_PORT=$(cat $CPP_CHECK_PORT | wc -l)
NUM_INFO=$(cat $CPP_CHECK_INFO | wc -l)

echo "::group::Cppcheck summary:"
echo "  $NUM_ERROR errors"
echo "  $NUM_WARN warnings"
echo "  $NUM_STYLE style warnings"
echo "  $NUM_PERF performance warnings"
echo "  $NUM_PORT portability warnings"
echo "  $NUM_INFO information messages"
echo "::endgroup::"

RS=0
if [[ NUM_ERROR -gt 0 ]]; then
    #color_output $ANSI_RED "::group::Errors:"
    echo -e "::group::\e[${ANSI_RED}mErrors:\e[0m"
    while IFS= read -r line; do
        echo "::error::$line"
    done <$CPP_CHECK_ERROR
    echo "::endgroup::"

    RS=$FAIL_DUE_ERR
fi

if [[ $NUM_WARN -gt 0 ]]; then
    color_output $ANSI_YELLOW "::group::Warnings:"
    while IFS= read -r line; do
        echo "::warn::$line"
    done <$CPP_CHECK_WARN
    echo "::endgroup::"

    if [[ FAIL_ON_WARN -gt 0 ]]; then
        RS=$FAIL_DUE_WARN
    fi
fi

if [[ $NUM_STYLE -gt 0 ]]; then
    color_output $ANSI_YELLOW "::group::Style Warnings:"
    while IFS= read -r line; do
        echo "::warn::$line"
    done <$CPP_CHECK_STYLE
    echo "::endgroup::"
fi

if [[ $NUM_PERF -gt 0 ]]; then
    color_output $ANSI_YELLOW "::group::Performance Warnings:"
    while IFS= read -r line; do
        echo "::warn::$line"
    done <$CPP_CHECK_PERF
    echo "::endgroup::"
fi

if [[ $NUM_PORT -gt 0 ]]; then
    color_output $ANSI_YELLOW "::group::Portability Warnings:"
    while IFS= read -r line; do
        echo "::warn::$line"
    done <$CPP_CHECK_PORT
    echo "::endgroup::"
fi

if [[ $NUM_INFO -gt 0 ]]; then
    color_output $ANSI_GREEN "::group::Information Messagess:"
    while IFS= read -r line; do
        echo "::warn::$line"
    done <$CPP_CHECK_INFO
    echo "::endgroup::"
fi

exit $RS
