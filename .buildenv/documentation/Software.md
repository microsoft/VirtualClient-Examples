# Required Software
The following list of software is required or highly recommended for working in team repos.

## Git
If you've not already installed Git, you will need to before going forward.  The Git (Git for Windows) client can be installed 
from the following URI.  Run the installation .exe when it is finished downloading.

https://git-for-windows.github.io/

```
During the installation select the following options as they come up:
- Default installation location is ok
- Default components selected are ok
- Default start menu folder name is ok
- Use Git from the Windows Command Prompt
- Use the native Windows Secure Channel library
- Checkout Windows-style, commit Unix-style line endings
- Use Windows' default console window
    - Enable file system caching and Enable Git Credential Manager
- Install
```

## .NET SDK
The team compiles against a few different .NET SDKs depending upon the project. The following list of SDKs should be installed
before you begin working in team codebase. Installing the latest stable SDK is typically sufficient.

https://dotnet.microsoft.com/en-us/download

<div style="color:#0489B1">
<div style="font-weight:600">Note:</div>
You can see the .NET SDKs you have installed by opening a command prompt and running the following command. Note that .NET 8.0 will typically
install with Visual Studio 2022. The additional SDKs noted below are also used in team projects.
</div>

``` bash
C:> dotnet --version
C:> dotnet --list-sdks
C:> dotnet --list-runtimes
```

## NuGet Credential Provider
Team repos use various NuGet package feeds to download packages/dependencies used in development.  To authenticate with the NuGet feeds using your Microsoft account,
Azure provides a credential provider. This credential provider will help NuGet pass your credentials to internal Azure DevOps NuGet feeds used by the team.

https://github.com/microsoft/artifacts-credprovider/blob/master/README.md


## Visual Studio 2022 (Optional)
Visual Studio is the preferred IDE (integrated developer environment) for writing code in team repos.  The build system used is MSBuild and
Visual Studio has the best direct integration with MSBuild for a seamless developer experience.  The Community edition (a free edition) is perfectly 
fine for working with .NET codebases.

Note that this is not a required piece of software. Choose the development IDE/editor you prefer if not Visual Studio.

https://visualstudio.microsoft.com/downloads/


## Visual Studio Code (Optional)
Visual Studio Code is a nice general purpose editor for many different programming, scripting and markup languages.  It also provides great
support as a GUI for merge conflict resolutions. This is optional software but recommended.

https://code.visualstudio.com/

