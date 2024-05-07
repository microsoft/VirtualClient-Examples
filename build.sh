#!/bin/bash

EXIT_CODE=0
BUILD_CONFIGURATION="Debug"
RESTORE_INTERACTIVE=""
PUBLISH_FLAGS="--self-contained -p:InvariantGlobalization=true"
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE}"))"

Usage() {
    echo ""
    echo "Builds/compiles the source code in the repo."
    echo ""
    echo "Usage:"
    echo "---------------------"
    echo "user@system:~/repo$ export VCBuildVersion=1.0.0"
    echo "user@system:~/repo$ $0 [--restore] [--interactive]"
    echo ""
    Finish
}

Error() {
    EXIT_CODE=1
    End
}

End() {
    echo ""
    echo "Build Stage Exit Code: $EXIT_CODE"
    echo ""
    Finish
}

Finish() {
    exit $EXIT_CODE
}

if [ "${1,,}" == "/?" ] || [ "${1,,}" == "-?" ] || [ "${1,,}" == "--help" ]; then
    Usage
fi

if [ "${1,,}" == "--release" ] || [ "${2,,}" == "--release" ]; then
    BUILD_CONFIGURATION="Release"
fi

if [ "${1,,}" == "--interactive" ] || [ "${2,,}" == "--interactive" ]; then
    RESTORE_INTERACTIVE="--interactive"
fi

if [ -z "$VCBuildVersion" ]; then
    echo ""
    echo "'VCBuildVersion' environment variable not set. This defines the version for all project builds. Using default build version 0.0.1."
    echo ""
    export VCBuildVersion=0.0.1
fi

echo ""
echo "**********************************************************************"
echo "Build Extensions: $VCBuildVersion"
echo "Repo Root       : $SCRIPT_DIR"
echo "Configuration   : $BUILD_CONFIGURATION"
echo "**********************************************************************"
echo ""
dotnet build "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.sln" -c $BUILD_CONFIGURATION $RESTORE_INTERACTIVE
result=$?
if [ $result -ne 0 ]; then
    Error
fi

echo ""
echo "----------------------------------------------------------------------"
echo "Build Virtual Client Extensions: linux-x64"
echo "----------------------------------------------------------------------"
echo ""
dotnet publish "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" -r linux-x64 -c $BUILD_CONFIGURATION --self-contained -p:InvariantGlobalization=true $RESTORE_INTERACTIVE
result=$?
if [ $result -ne 0 ]; then
    Error
fi

echo ""
echo "----------------------------------------------------------------------"
echo "Build Virtual Client Extensions: linux-arm64"
echo "----------------------------------------------------------------------"
echo ""
dotnet publish "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" -r linux-arm64 -c $BUILD_CONFIGURATION --self-contained -p:InvariantGlobalization=true $RESTORE_INTERACTIVE
result=$?
if [ $result -ne 0 ]; then
    Error
fi

echo ""
echo "----------------------------------------------------------------------"
echo "Build Virtual Client Extensions: win-x64"
echo "----------------------------------------------------------------------"
echo ""
dotnet publish "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" -r win-x64 -c $BUILD_CONFIGURATION --self-contained $RESTORE_INTERACTIVE
result=$?
if [ $result -ne 0 ]; then
    Error
fi

echo ""
echo "----------------------------------------------------------------------"
echo "Build Virtual Client Extensions: win-arm64"
echo "----------------------------------------------------------------------"
echo ""
dotnet publish "$SCRIPT_DIR/src/VirtualClient.Extensions/VirtualClient.Extensions.Packaging/VirtualClient.Extensions.Packaging.csproj" -r win-arm64 -c $BUILD_CONFIGURATION --self-contained $RESTORE_INTERACTIVE
result=$?
if [ $result -ne 0 ]; then
    Error
fi

End