#!/bin/bash

set -euo pipefail

PEDANTIC=0

CPP_CHECK_OUTPUT="cppcheck.out"
CPP_CHECK_ERROR="cppcheck.out.error"
CPP_CHECK_WARN="cppcheck.out.warn"
CPP_CHECK_STYLE="cppcheck.out.style"
CPP_CHECK_PERF="cppcheck.out.perf"
CPP_CHECK_PORT="cppcheck.out.port"
CPP_CHECK_INFO="cppcheck.out.info"

echo ""
echo "::group::Run cppcheck on files"
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

echo ""
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
    echo ""
    echo "::error::Errors:"
    while IFS= read -r line; do
        echo "::error::$line"
    done <$CPP_CHECK_ERROR
    #awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_ERROR
    RS=1
fi

if [[ $NUM_WARN -gt 0 ]]; then
    echo ""
    echo "Warnings:"
    awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_WARN
    if [[ PEDANTIC -gt 0 ]]; then
        RS=1
    fi
fi

if [[ $NUM_STYLE -gt 0 ]]; then
    echo ""
    echo "Style Warnings:"
    awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_STYLE
fi

if [[ $NUM_PERF -gt 0 ]]; then
    echo ""
    echo "Performance Warnings:"
    awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_STYLE
fi

if [[ $NUM_PORT -gt 0 ]]; then
    echo ""
    echo "Portability Warnings:"
    awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_STYLE
fi

if [[ $NUM_INFO -gt 0 ]]; then
    echo ""
    echo "Information messages:"
    awk '{printf "%d\t%s\n", NR, $0}' <$CPP_CHECK_STYLE
fi

exit $RS
