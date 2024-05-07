---
ArtifactType: nupkg, executable, azure-web-app, azure-cloud-service
Documentation: URL
Language: csharp, powershell, markdown
Platform: windows, linux, azure-function, azure-app-service
Stackoverflow: URL
Tags: Cloud Readiness Criteria,CRC,Juno,Virtual Client
ms.reviewedAt: 11/3/2019
ms.reviewedBy: brdeyo
---

# Cloud Readiness Certified (CRC)
This repo is owned and managed by the Cloud Readiness Certified (CRC) team under the CHIE organization.
For information please contact [crc_fte@microsoft.com](mailto:crc_fte@microsoft.com).

This repo includes the following team projects:

* #### Virtual Client Extensions Examples
  The projects in this solution showcase examples of how to create action, monitor and dependency handler extensions to
  the Virtual Client platform.

## Getting Started
The following documentation provides insight into how CRC Git repos are structured and how to work within them.

* [Working in CRC Repos](https://msazure.visualstudio.com/One/_git/CSI-CRC-BuildEnv?path=%2FREADME.md&version=GBmaster&_a=preview)

<div style="font-size:10pt">

```
# Examples
# Ensure you have the latest build environment files
S:\one\repo> init.cmd

# Clean output/artifact directories
S:\one\repo> clean.cmd

# Restore NuGet packages
S:\one\repo> build-restore.cmd

# Build all solutions/projects in the repo.
S:\one\repo> build.cmd

# Run all unit + functional tests for projects in the repo. Note that tests MUST have a [Category("Unit")] or [Category("Functional")] 
# attribute at the top of the test class in order to be run.
S:\one\repo> build-test.cmd
```
</div>

## Building Virtual Client Extensions Packages
The projects in this repo are used as dependencies for projects in other repos. The CRC team uses NuGet toolsets to create packages 
for sharing/integrating Virtual Client extensions. To build extensions packages for the projects the following commands are used to 
simplify this process and for automated build integration.

| Command                                          | Description                       |
| :----------------------------------------------- | :-------------------------------- |
| build-packages.cmd                               | Builds extension packages for all of the projects in the repo using the package version provided. |

<div style="font-size:10pt">

```
# Examples
# Perform each of the build steps noted above for the repo

# Then build packages. Note that packages are output to the 'repo\out\packages' directory.
S:\one\repo> build-packages.cmd 1.2.3

# Produces:
S:\one\repo\out\packages\crc.vc.extensions.1.2.3.zip
```
</div>