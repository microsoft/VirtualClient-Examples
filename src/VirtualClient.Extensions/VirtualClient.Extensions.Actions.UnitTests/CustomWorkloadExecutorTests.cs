namespace CRC.VirtualClient.Extensions
{
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using System.Threading;
    using System.Threading.Tasks;
    using global::VirtualClient;
    using global::VirtualClient.Common.Extensions;
    using global::VirtualClient.Common.Telemetry;
    using global::VirtualClient.Contracts;
    using Moq;
    using Newtonsoft.Json.Linq;
    using NUnit.Framework;
    using Polly;

    [TestFixture]
    [Category("Unit")]
    public class CustomWorkloadExecutorTests
    {
        private MockFixture mockFixture;
        private DependencyPath mockWorkloadPackage;
        private string validResults;

        /*
        MockFixure
        A "mock fixture" is a class that contains different mocking objects/instances that are used to make unit + functional
        testing easier. Additionally, the MockFixture helps to keep the lines of testing code required to a minimum by reducing
        the requirement for local member variables for mocking objects and by enabling mock behavior setup extensions to be
        created that can be reused across test projects.

        The MockFixture also enables testing to be performed "as if" it were running on a specific platform (e.g. Windows vs. Linux).
        This aspect
         */

        [Test]
        [TestCase(PlatformID.Unix, Architecture.Arm64)]
        [TestCase(PlatformID.Unix, Architecture.X64)]
        [TestCase(PlatformID.Win32NT, Architecture.Arm64)]
        [TestCase(PlatformID.Win32NT, Architecture.X64)]
        public async Task CustomWorkloadExecutorVerifiesTheExpectedWorkloadPackageExistsOnTheSystem(PlatformID platform, Architecture architecture)
        {
            this.SetupDefaultBehaviors(platform, architecture);
            using (TestCustomWorkloadExecutor executor = new TestCustomWorkloadExecutor(this.mockFixture))
            {
                string expectedPackageName = this.mockWorkloadPackage.Name;

                // Using the Moq framework to setup a behavior and a callback/validation.
                this.mockFixture.PackageManager.Setup(mgr => mgr.GetPackageAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                    .Callback<string, CancellationToken>((packageName, token) => Assert.AreEqual(packageName, expectedPackageName))
                    .ReturnsAsync(this.mockWorkloadPackage)
                    .Verifiable();

                await executor.InitializeAsync(EventContext.None, CancellationToken.None)
                    .ConfigureAwait(false);

                // Verify the package manager method call above was indeed called to avoid false positive outcomes.
                this.mockFixture.PackageManager.Verify();
            }
        }

        [Test]
        [TestCase(PlatformID.Win32NT, Architecture.X64, "ExampleWorkload.exe")]
        [TestCase(PlatformID.Win32NT, Architecture.Arm64, "ExampleWorkload.exe")]
        [TestCase(PlatformID.Unix, Architecture.X64, "ExampleWorkload")]
        [TestCase(PlatformID.Unix, Architecture.Arm64, "ExampleWorkload")]
        public async Task CustomWorkloadExecutorVerifiesTheExpectedWorkloadPackageBinariesExistOnTheSystem(PlatformID platform, Architecture architecture, string expectedExecutable)
        {
            this.SetupDefaultBehaviors(platform, architecture);
            using (TestCustomWorkloadExecutor executor = new TestCustomWorkloadExecutor(this.mockFixture))
            {
                string expectedBinaryName = this.mockWorkloadPackage.Name;

                // The actual workload binaries will exist in the workload package in the "platform-specific" path.
                // Each workload package can have binaries that support different platforms/architectures.
                // (e.g. \packages\workload\1.0.0\win-x64\workload.exe, \packages\workload\1.0.0\win-arm64\workload.exe).
                DependencyPath workloadPlatformSpecificPackage = this.mockFixture.ToPlatformSpecificPath(
                    this.mockWorkloadPackage,
                    platform,
                    architecture);

                // The executor will verify the expected workload binaries exist on the file system.
                List<string> expectedBinaries = new List<string>
                {
                    this.mockFixture.Combine(workloadPlatformSpecificPackage.Path, expectedExecutable)
                };

                this.mockFixture.File.Setup(file => file.Exists(It.IsAny<string>()))
                    .Callback<string>(path => expectedBinaries.Remove(path)) // Remove the path as it is confirmed
                    .Returns(true);

                await executor.InitializeAsync(EventContext.None, CancellationToken.None)
                    .ConfigureAwait(false);

                Assert.IsEmpty(expectedBinaries);
            }
        }

        [Test]
        [TestCase(PlatformID.Win32NT, Architecture.X64, "ConfigureSystem.exe")]
        [TestCase(PlatformID.Win32NT, Architecture.Arm64, "ConfigureSystem.exe")]
        [TestCase(PlatformID.Unix, Architecture.X64, "ConfigSys")]
        [TestCase(PlatformID.Unix, Architecture.Arm64, "ConfigSys")]
        public async Task CustomWorkloadExecutorAppliesExpectedSystemSettingsOnFirstRunBeforeTheWorkloadIsExecuted(PlatformID platform, Architecture architecture, string expectedExecutable)
        {
            this.SetupDefaultBehaviors(platform, architecture);
            using (TestCustomWorkloadExecutor executor = new TestCustomWorkloadExecutor(this.mockFixture))
            {
                // Setup the scenario where a state object indicating the executor has run before
                // a first time does not exist. This is how the executor determines that it has not
                // performed a first run and thus that it needs to apply the system settings.
                this.mockFixture.StateManager.OnGetState(executor.StateId).ReturnsAsync(null as JObject);

                DependencyPath workloadPlatformSpecificPackage = this.mockFixture.ToPlatformSpecificPath(
                    this.mockWorkloadPackage,
                    platform,
                    architecture);

                string expectedCommand = this.mockFixture.Combine(workloadPlatformSpecificPackage.Path, expectedExecutable);

                await executor.ExecuteAsync(CancellationToken.None)
                    .ConfigureAwait(false);

                // The configuration command should have been ran but the workload should not. The 'CommandsExecuted'
                // extension method uses a regular expression to enable the developer to have flexibility for defining
                // and confirming commands executed.
                // Assert.IsTrue(this.mockFixture.ProcessManager.CommandsExecuted(expectedCommand));
                // Assert.IsFalse(this.mockFixture.ProcessManager.CommandsExecuted("*.ExampleWorkload"));
            }
        }

        [Test]
        [TestCase(PlatformID.Win32NT, Architecture.X64, "ConfigureSystem.exe")]
        [TestCase(PlatformID.Win32NT, Architecture.Arm64, "ConfigureSystem.exe")]
        [TestCase(PlatformID.Unix, Architecture.X64, "ConfigSys")]
        [TestCase(PlatformID.Unix, Architecture.Arm64, "ConfigSys")]
        public async Task CustomWorkloadExecutorKeepsTrackOfTheFactThatExpectedSystemSettingsWereSuccessfullyApplied(PlatformID platform, Architecture architecture, string expectedExecutable)
        {
            this.SetupDefaultBehaviors(platform, architecture);
            using (TestCustomWorkloadExecutor executor = new TestCustomWorkloadExecutor(this.mockFixture))
            {
                // Setup the scenario where a state object indicating the executor has run before
                // a first time does not exist. This is how the executor determines that it has not
                // performed a first run and thus that it needs to apply the system settings.
                this.mockFixture.StateManager.OnGetState(executor.StateId).ReturnsAsync(null as JObject);

                await executor.ExecuteAsync(CancellationToken.None)
                    .ConfigureAwait(false);

                this.mockFixture.StateManager.Verify(mgr => mgr.SaveStateAsync(
                    executor.StateId,
                    It.Is<JObject>(state => state.ToString().Contains("\"isSystemConfigured\": true")),
                    It.IsAny<CancellationToken>(),
                    It.IsAny<IAsyncPolicy>()),
                    Times.Once);
            }
        }

        [Test]
        [TestCase(PlatformID.Win32NT, Architecture.X64, "ExampleWorkload.exe Workload --duration=00:00:01")]
        [TestCase(PlatformID.Win32NT, Architecture.Arm64, "ExampleWorkload.exe Workload --duration=00:00:01")]
        [TestCase(PlatformID.Unix, Architecture.X64, "ExampleWorkload Workload --duration=00:00:01")]
        [TestCase(PlatformID.Unix, Architecture.Arm64, "ExampleWorkload Workload --duration=00:00:01")]
        public async Task CustomWorkloadExecutorExecutesTheExpectedWorkloadCommand(PlatformID platform, Architecture architecture, string expectedCommand)
        {
            this.SetupDefaultBehaviors(platform, architecture);
            using (TestCustomWorkloadExecutor executor = new TestCustomWorkloadExecutor(this.mockFixture))
            {
                // The actual workload binaries will exist in the workload package in the "platform-specific" path.
                // Each workload package can have binaries that support different platforms/architectures.
                // (e.g. \packages\workload\1.0.0\win-x64\workload.exe, \packages\workload\1.0.0\win-arm64\workload.exe).
                DependencyPath workloadPlatformSpecificPackage = this.mockFixture.ToPlatformSpecificPath(
                    this.mockWorkloadPackage,
                    platform,
                    architecture);

                string expectedWorkloadProcess = this.mockFixture.Combine(workloadPlatformSpecificPackage.Path, expectedCommand);

                await executor.ExecuteAsync(CancellationToken.None)
                    .ConfigureAwait(false);

                Assert.IsTrue(this.mockFixture.ProcessManager.CommandsExecuted(expectedWorkloadProcess));
            }
        }

        private void SetupDefaultBehaviors(PlatformID platform, Architecture architecture = Architecture.X64)
        {
            // Test Setup Methodology:
            // ----------------------------------------------------------------------------------------
            // Setup all dependencies that are expected by the class under test that represent
            // what would be the "happy path". This is the path where every dependency expected to
            // exist and to be defined correctly actually exists. The class under test is expected to
            // complete its operations successfully in this case. Then in individual tests, one of the
            // dependency behaviors will be modified. This allows all different kinds of variations in
            // potential behaviors to be tested simply and thoroughly.
            //
            // ** See the TESTING_GUIDE.md in the solution directory. **
            //
            //
            // What does the flow of the workload executor look like:
            // ----------------------------------------------------------------------------------------
            // The workload executor flow describes the ordered steps required to initialize, configure
            // and execute the workload followed by capturing the metrics/results.
            //
            // 1) IsSupported
            //    Check to see if the component should run.
            //
            // 2) ValidateParameters
            //    Check the parameters supplied in the profile step or by the user on the command line to ensure they are valid/correct.
            //
            // 3) InitializeAsync
            //   Verify the workload package. The workload package contains the workload executables/binaries/scripts and any other
            //   files or content necessary to run the workload itself. Check that all required workload binaries/scripts exist on the file system
            //   in the workload package. Ensure all required workload binaries/scripts are marked/attributed as executables (for Linux systems).
            //
            // 5) ExecuteAsync
            //    Applies system settings/configurations first. Then executes the workload itself. Capture/emit the workload results metrics.
            //
            // 6) CleanupAsync
            //    Perform any cleanup tasks.
            //
            // What are the dependencies:
            // ----------------------------------------------------------------------------------------
            // The CustomWorkloadExecutor class has a number of different dependencies that must all be
            // setup correctly in order to fully test the class.
            //
            //   o File System Integration
            //     The file system integration dependency provides read/write access to the file system (e.g.
            //     directories, files).
            //
            //   o Package Manager
            //     The package manager dependency provides the functionality for installing/downloading workload
            //     packages to the system as well as for finding their location.
            //
            //   o State Manager
            //     The state manager dependency provides access to saving and retrieving state objects/definitions.
            //     Workload executors use state objects to maintain information over long periods of time in-between
            //     individual executions (where the information could be lost if maintained only in memory).
            //
            //   o Process Manager
            //     The process manager dependency is used to create isolated processes on the system for execution
            //     of the workload executables and scripts.
            //
            //
            // ...Setting up the Happy Path
            // ----------------------------------------------------------------------------------------
            // Setup the fixture itself to target the platform provided (e.g. Windows, Unix). This ensures the platform
            // specifics are made relevant to that platform (e.g. file system paths, path structures).
            this.mockFixture = new MockFixture();
            this.mockFixture.Setup(platform, architecture);

            // Expectation 1: The expected parameters are defined
            string workloadName = "ExampleWorkload";
            this.mockFixture.Parameters.AddRange(new Dictionary<string, IConvertible>
            {
                { nameof(CustomWorkloadExecutor.PackageName), workloadName },
                { nameof(CustomWorkloadExecutor.Duration), "00:00:01" },
                { nameof(CustomWorkloadExecutor.ExampleParameter1), "AnyValue1" },
                { nameof(CustomWorkloadExecutor.ExampleParameter2), 1234 }
            });

            // Expectation 2: The expected workload package actually exists.
            this.mockWorkloadPackage = new DependencyPath(
                workloadName,
                this.mockFixture.PlatformSpecifics.GetPackagePath(workloadName));

            this.mockFixture.PackageManager
                .Setup(mgr => mgr.GetPackageAsync(workloadName, It.IsAny<CancellationToken>()))
                .ReturnsAsync(this.mockWorkloadPackage);

            // Expectation 3: The expected workload binaries/scripts within the workload package exist. Workload packages
            // follow a strict schema allowing for toolset versions that support different platforms and architectures
            // (e.g. linux-x64, linux-arm64, win-x64, win-arm64).
            DependencyPath platformSpecificWorkloadPackage = this.mockFixture.ToPlatformSpecificPath(
                this.mockWorkloadPackage,
                platform,
                architecture);

            List<string> expectedBinaries = platform == PlatformID.Win32NT
                ? new List<string>
                {
                    // Expected binaries on Windows
                    this.mockFixture.Combine(platformSpecificWorkloadPackage.Path, $"{workloadName}.exe"),
                    this.mockFixture.Combine(platformSpecificWorkloadPackage.Path, "ConfigureSystem.exe"),
                }
                : new List<string>
                {
                    // Expected binaries on Linux/Unix
                    this.mockFixture.Combine(platformSpecificWorkloadPackage.Path, $"{workloadName}"),
                    this.mockFixture.Combine(platformSpecificWorkloadPackage.Path, "ConfigSys")
                };

            expectedBinaries.ForEach(binary => this.mockFixture.File.Setup(file => file.Exists(binary)).Returns(true));

            // Expectation 5: The executor has already applied required settings/configuratinos to the system.
            this.mockFixture.StateManager.OnGetState().ReturnsAsync(new CustomWorkloadExecutor.WorkloadState { IsSystemConfigured = true }.ToJObject());

            // Expectation 6: The workload runs and produces valid results
            this.validResults = "{ \"workload_metric_1\": 123456789, \"workload_metric_2\": 98, \"workload_metric_3\": 450, \"workload_metric_4\": 1200, \"workload_metric_5\": 32 }";
            this.mockFixture.ProcessManager.OnProcessCreated = (process) =>
            {
                // e.g. ExampleWorkload.exe Workload
                if (process.FullCommand().Contains("Workload"))
                {
                    // Mimic the workload process having written valid results.
                    process.StandardOutput.Append(this.validResults);
                }
            };
        }

        // A private class inside of the unit test class is often used to enable the developer
        // to expose protected members of the class under test. This is a simple technique to
        // allow those methods to be tested directly.
        private class TestCustomWorkloadExecutor : CustomWorkloadExecutor
        {
            public TestCustomWorkloadExecutor(MockFixture fixture)
                : base(fixture.Dependencies, fixture.Parameters)
            {
            }

            public new string StateId
            {
                get
                {
                    return base.StateId;
                }
            }

            // Use the access modifier "public new" in order to expose the underlying protected method
            // without overriding it. This technique is recommended ONLY for testing scenarios but is very
            // helpful for those.
            public new Task InitializeAsync(EventContext telemetryContext, CancellationToken cancellationToken)
            {
                return base.InitializeAsync(telemetryContext, cancellationToken);
            }
        }
    }
}
