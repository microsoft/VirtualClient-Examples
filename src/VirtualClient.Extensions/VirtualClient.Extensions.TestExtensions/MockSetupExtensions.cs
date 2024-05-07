namespace CRC.VirtualClient.Extensions
{
    using System;
    using System.IO.Abstractions;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using global::VirtualClient;
    using global::VirtualClient.Common.Extensions;
    using global::VirtualClient.Contracts;
    using Moq;
    using Moq.Language.Flow;
    using Newtonsoft.Json.Linq;
    using Polly;

    /// <summary>
    /// Extension methods to help simplify common mock setup scenarios in unit + functional
    /// testing classes.
    /// </summary>
    public static class MockSetupExtensions
    {
        /// <summary>
        /// Setup default behavior for validation if a file exists.
        /// </summary>
        public static ISetup<IFile, bool> OnFilesExist(this Mock<IFile> fileIntegration, params string[] filePaths)
        {
            fileIntegration.ThrowIfNull(nameof(fileIntegration));

            if (filePaths?.Any() != true)
            {
                return fileIntegration.Setup(file => file.Exists(It.IsAny<string>()));
            }
            else
            {
                return fileIntegration.Setup(file => file.Exists(It.Is<string>(path => filePaths.Contains(path))));
            }
        }

        /// <summary>
        /// Setup default behavior for retrieving a package from the <see cref="IPackageManager"/>.
        /// </summary>
        public static ISetup<IPackageManager, Task<DependencyPath>> OnGetPackage(this Mock<IPackageManager> packageManager, string packageName = null)
        {
            packageManager.ThrowIfNull(nameof(packageManager));

            if (packageName == null)
            {
                return packageManager.Setup(mgr => mgr.GetPackageAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()));
            }
            else
            {
                return packageManager.Setup(mgr => mgr.GetPackageAsync(packageName, It.IsAny<CancellationToken>()));
            }
        }

        /// <summary>
        /// Setup default behavior for retrieving state objects from the <see cref="IStateManager"/>.
        /// </summary>
        public static ISetup<IStateManager, Task<JObject>> OnGetState(this Mock<IStateManager> stateManager, string stateId = null)
        {
            stateManager.ThrowIfNull(nameof(stateManager));

            if (stateId == null)
            {
                return stateManager.Setup(mgr => mgr.GetStateAsync(It.IsAny<string>(), It.IsAny<CancellationToken>(), It.IsAny<IAsyncPolicy>()));
            }
            else
            {
                return stateManager.Setup(mgr => mgr.GetStateAsync(stateId, It.IsAny<CancellationToken>(), It.IsAny<IAsyncPolicy>()));
            }
        }

        /// <summary>
        /// Setup default behavior for retrieving state objects from the <see cref="IStateManager"/>.
        /// </summary>
        public static ISetup<IStateManager, Task> OnSaveState(this Mock<IStateManager> stateManager, string stateId = null)
        {
            stateManager.ThrowIfNull(nameof(stateManager));

            if (stateId == null)
            {
                return stateManager.Setup(mgr => mgr.SaveStateAsync(
                    It.IsAny<string>(),
                    It.IsAny<JObject>(),
                    It.IsAny<CancellationToken>(),
                    It.IsAny<IAsyncPolicy>()));
            }
            else
            {
                return stateManager.Setup(mgr => mgr.SaveStateAsync(
                    stateId,
                    It.IsAny<JObject>(),
                    It.IsAny<CancellationToken>(),
                    It.IsAny<IAsyncPolicy>()));
            }
        }
    }
}
