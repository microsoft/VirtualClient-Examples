#!/bin/bash

EXIT_CODE=0
RESTORE_INTERACTIVE=""
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE}"))"

Usage() {
    echo ""
    echo "Downloads dependency packages(e.g. NuGet) to the system. Pass in the --interactive"
    echo "flag to enable authentication with the target package feeds."
    echo ""
    echo "Usage:"
    echo "---------------------"
    echo "user@system:~/repo$ $0 [--interactive]"
    echo ""
    Finish
}

Error() {
    EXIT_CODE=1
    End
}

End() {
    echo ""
    echo "Restore Stage Exit Code: $EXIT_CODE"
    echo ""
    Finish
}

Finish() {
    exit $EXIT_CODE
}

if [ "${1,,}" == "/?" ] || [ "${1,,}" == "-?" ] || [ "${1,,}" == "--help" ]; then
    Usage
fi

if [ "${1,,}" == "--interactive" ]; then
    RESTORE_INTERACTIVE="--interactive"
fi

echo ""
echo "**********************************************************************"
echo "Restore Packages:"
echo "Repo Root       : $SCRIPT_DIR"
echo "**********************************************************************"
echo ""
dotnet restore "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.sln" $RESTORE_INTERACTIVE

result=$?
if [ $result -ne 0 ]; then
    Error
fi

End