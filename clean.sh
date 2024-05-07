#!/bin/bash

EXIT_CODE=0
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE}"))"
REPO_OUT_DIR=$SCRIPT_DIR/out
REPO_SRC_DIR=$SCRIPT_DIR/src

Usage() {
    echo ""
    echo "Deletes build artifacts from the repo."
    echo ""
    echo "Usage:"
    echo "---------------------"
    echo "user@system:~/repo$ $0"
    echo ""
    Finish
}

Error() {
    EXIT_CODE=1
    End
}

End() {
    echo ""
    echo "Clean Stage Exit Code: $EXIT_CODE"
    echo ""
    Finish
}

Finish() {
    exit $EXIT_CODE
}

if [ "${1,,}" == "/?" ] || [ "${1,,}" == "-?" ] || [ "${1,,}" == "--help" ]; then
    Usage
fi

echo ""

for dir in $REPO_OUT_DIR/*/
do
    echo "Clean: $dir"
    rm -rfd $dir

    result=$?
    if [ $result -ne 0 ]; then
        Error
    fi
done

for dir in $(find $REPO_SRC_DIR -type d | grep obj$)/
do
    echo "Clean: $dir"
    rm -rfd $dir

     result=$?
     if [ $result -ne 0 ]; then
        Error
     fi
done

End