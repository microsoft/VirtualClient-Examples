#!/bin/bash

EXIT_CODE=0
BUILD_CONFIGURATION="Debug"
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE}"))"

Usage() {
    echo ""
    echo "Builds packages from the artifacts/output of the build. Run build.cmd first."
    echo ""
    echo "Usage:"
    echo "---------------------"
    echo "user@system:~/repo$ export VCBuildVersion=1.0.0"
    echo "user@system:~/repo$ ./build.sh [--release] [--interactive]"
    echo "user@system:~/repo$ $0 [--release]"
    echo ""
    Finish
}

Error() {
    EXIT_CODE=1
    End
}

End() {
    echo ""
    echo "Packaging Stage Exit Code: $EXIT_CODE"
    echo ""
    Finish
}

Finish() {
    exit $EXIT_CODE
}

if [ "${1,,}" == "/?" ] || [ "${1,,}" == "-?" ] || [ "${1,,}" == "--help" ]; then
    Usage
fi

if [ "${1,,}" == "--release" ]; then
    BUILD_CONFIGURATION="Release"
fi

if [ -z "$VCBuildVersion" ]; then
    echo ""
    echo "'VCBuildVersion' environment variable not set. This defines the version for all project builds. Using default build version 0.0.1."
    echo ""
    export VCBuildVersion=0.0.1
fi

echo ""
echo "**********************************************************************"
echo "Package Extensions: $VCBuildVersion"
echo "Repo Root         : $SCRIPT_DIR"
echo "Configuration     : $BUILD_CONFIGURATION"
echo "**********************************************************************"
echo ""

# The packages project itself is not meant to produce a binary/.dll and thus is not built. However, to ensure
# the requisite NuGet package assets file exist in the local 'obj' folder, we need to perform a restore.
dotnet restore "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" --force
result=$?
if [ $result -ne 0 ]; then
    Error
fi

dotnet pack "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" --force --no-restore --no-build -c $BUILD_CONFIGURATION \
-p:NuspecFile="$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/example.virtualclient.extensions.nuspec"

result=$?
if [ $result -ne 0 ]; then
    Error
fi

for f in `ls $SCRIPT_DIR/out/packages | grep "\.nupkg$"`; do mv "$SCRIPT_DIR/out/packages/$f" "$SCRIPT_DIR/out/packages/${f%.nupkg}.zip"; done
result=$?
if [ $result -ne 0 ]; then
    Error
fi

End