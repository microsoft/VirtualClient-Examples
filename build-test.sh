#!/bin/bash

ExitCode=0
BUILD_CONFIGURATION="Debug"
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE}"))"

Usage() {
    echo ""
    echo "Executes unit and functional tests within the repo. Run build.cmd first."
    echo ""
    echo "Usage:"
    echo "---------------------"
    echo "user@system:~/repo$ ./build.sh [--release] [--interactive]"
    echo "user@system:~/repo$ $0 [--release]"
    echo ""
    Finish
}

Error() {
    ExitCode=1
    End
}

End() {
    echo ""
    echo "Test Stage Exit Code: $ExitCode"
    echo ""
    Finish
}

Finish() {
    exit $ExitCode
}

if [ "${1,,}" == "/?" ] || [ "${1,,}" == "-?" ] || [ "${1,,}" == "--help" ]; then
    Usage
fi

if [ "${1,,}" == "--release" ]; then
    BUILD_CONFIGURATION="Release"
fi

echo ""
echo "**********************************************************************"
echo "Running Tests :"
echo "Repo Root     : $SCRIPT_DIR"
echo "Configuration : $BUILD_CONFIGURATION"
echo "**********************************************************************"
echo ""

for file in $(find "$SCRIPT_DIR/src" -type f -name "*Tests.csproj"); do
    dotnet test -c $BUILD_CONFIGURATION "$file" --no-restore --no-build --filter "(Category=Unit|Category=Functional)" --logger "console;verbosity=normal"
    result=$?
    if [ $result -ne 0 ]; then
        Error
    fi
done

End
