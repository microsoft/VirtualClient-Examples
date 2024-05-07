namespace CRC.VirtualClient.Extensions
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Text.RegularExpressions;
    using global::VirtualClient;
    using global::VirtualClient.Common;
    using Newtonsoft.Json.Linq;

    /// <summary>
    /// Extension methods to help simplify common mock setup scenarios in unit + functional
    /// testing classes.
    /// </summary>
    public static class MockExtensions
    {
        /// <summary>
        /// Confirms the workload commands were executed. This method uses regular expressions
        /// to evaluate equality so the commands passed in can be explicit or using regular expressions
        /// syntax.
        /// </summary>
        public static bool CommandsExecuted(this InMemoryProcessManager processManager, params string[] commands)
        {
            bool executed = true;
            List<IProcessProxy> processesConfirmed = new List<IProcessProxy>();

            foreach (string command in commands)
            {
                try
                {
                    string normalizedRegex = Regex.Escape(command);
                    IProcessProxy matchingProcess = processManager.Processes.FirstOrDefault(
                        proc => Regex.IsMatch(proc.FullCommand(), normalizedRegex, RegexOptions.IgnoreCase) && !processesConfirmed.Any(otherProc => object.ReferenceEquals(proc, otherProc)));

                    if (matchingProcess == null)
                    {
                        executed = false;
                        break;
                    }

                    processesConfirmed.Add(matchingProcess);
                }
                catch
                {
                    throw;
                }
            }

            return executed;
        }

        /// <summary>
        /// Makes conversion from an object to a JObject clean for readability in the unit + functional
        /// tests when working with state objects.
        /// </summary>
        public static JObject ToJObject<TState>(this TState stateObject)
        {
            return stateObject != null
                ? JObject.FromObject(stateObject)
                : null;
        }
    }
}
