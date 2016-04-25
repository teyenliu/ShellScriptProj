#!/bin/bash

set -x
SRC_INPUT=`cat coverage_src.input`
PKG_INPUT=`cat coverage_pkg.input`
COVERAGE_RATE=`cat coverage_rate.input`
FLAKE8_SRC=`cat flake8_src.input`
FLAKE8_NUM=`cat flake8_num.input`

TIME=$(date "+%Y%m%d-%k%M")

# check WORKSPACE is null or space
if [ ! -z "$WORKSPACE" -a "$WORKSPACE" != " " ]; then
    $WORKSPACE=$PWD
fi

# clean up temp files
cleanup() {
    rm -rf *.result
}

failed_action() {
    cleanup;
    exit 1
}

# run unit test
python gocloud/manage.py test $PKG_INPUT 2>&1 | tee unittest.result
if grep "FAILED" unittest.result; then
    echo "unit test failed";
    failed_action;
else
    echo "unit test passed";
fi

# run coverage
coverage run --source=$SRC_INPUT gocloud/manage.py test $PKG_INPUT 
coverage report > coverage.result
if [ $(grep "TOTAL" coverage.result | awk '{print substr($4,0, length($4)-1)}' | bc -l) > ${COVERAGE_RATE} ]; then 
    echo "More than "$COVERAGE_RATE"%";
else 
    echo "Less than "$COVERAGE_RATE"%";
    failed_action;
fi

# run flake8
flake8 --max-complexity 2 $FLAKE8_SRC > flake8.result
if [ $(grep "E\|W\|F" flake8.result | wc -l) -lt ${FLAKE8_NUM} ]; then
    echo "Pass flake8";
else
    echo "Not pass flake8"; 
    failed_action;
fi

cleanup;
