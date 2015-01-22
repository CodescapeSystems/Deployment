using System;
using System.Diagnostics;
using System.Reflection;

namespace DeploymentApplication
{
	class Program
	{
		static void Main(string[] args)
		{
			ExecuteCommand("dir");

			Console.WriteLine("This version: {0}", Assembly.GetExecutingAssembly().GetName().Version);

			Console.ReadLine();
		}

		static void ExecuteCommand(string command)
		{
			int exitCode;
			ProcessStartInfo processInfo;
			Process process;

			processInfo = new ProcessStartInfo("cmd.exe", "/c " + command);
			processInfo.CreateNoWindow = true;
			processInfo.UseShellExecute = false;
			// *** Redirect the output ***
			processInfo.RedirectStandardError = true;
			processInfo.RedirectStandardOutput = true;

			process = Process.Start(processInfo);
			process.WaitForExit();

			// *** Read the streams ***
			string output = process.StandardOutput.ReadToEnd();
			string error = process.StandardError.ReadToEnd();

			exitCode = process.ExitCode;

			Console.WriteLine(output, "ExecuteCommand");

			Console.WriteLine("ExitCode: " + exitCode, "ExecuteCommand");
			process.Close();
		}

	}
}
