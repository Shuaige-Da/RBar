using System.IO;

namespace DynamicIslandBar;

public static class ProductIdentity
{
    public const string ProductName = "RBar";
    public const string PublisherName = "rainwave";
    public const string LegacyProductName = "DynamicIslandBar";

    public static string UserDataDirectory => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        ProductName);

    public static string LegacyUserDataDirectory => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        LegacyProductName);

    public static void MigrateLegacyUserData()
    {
        MigrateLegacyUserData(LegacyUserDataDirectory, UserDataDirectory);
    }

    internal static void MigrateLegacyUserData(string legacyDirectory, string targetDirectory)
    {
        if (string.IsNullOrWhiteSpace(legacyDirectory)
            || string.IsNullOrWhiteSpace(targetDirectory))
        {
            return;
        }

        try
        {
            var legacyFullPath = Path.GetFullPath(legacyDirectory);
            var targetFullPath = Path.GetFullPath(targetDirectory);
            if (string.Equals(legacyFullPath, targetFullPath, StringComparison.OrdinalIgnoreCase)
                || !Directory.Exists(legacyFullPath))
            {
                return;
            }

            Directory.CreateDirectory(targetFullPath);
            CopyFileIfMissing(legacyFullPath, targetFullPath, "capsule-config.json");
            CopyFileIfMissing(legacyFullPath, targetFullPath, "capsule-config.json.bak");
            CopyFileIfMissing(legacyFullPath, targetFullPath, "permissions.json");
            CopyDirectoryIfMissing(
                Path.Combine(legacyFullPath, "Logs"),
                Path.Combine(targetFullPath, "Logs"));
        }
        catch
        {
            // Migration is best-effort. Existing RBar data always wins.
        }
    }

    public static bool IsOwnProcessName(string? processName)
    {
        return string.Equals(processName, ProductName, StringComparison.OrdinalIgnoreCase)
            || string.Equals(processName, LegacyProductName, StringComparison.OrdinalIgnoreCase);
    }

    public static bool IsOwnExecutablePath(string? executablePath)
    {
        if (string.IsNullOrWhiteSpace(executablePath))
        {
            return false;
        }

        var fileName = Path.GetFileNameWithoutExtension(executablePath);
        return IsOwnProcessName(fileName);
    }

    private static void CopyFileIfMissing(
        string sourceDirectory,
        string targetDirectory,
        string fileName)
    {
        var source = Path.Combine(sourceDirectory, fileName);
        var target = Path.Combine(targetDirectory, fileName);
        if (File.Exists(source) && !File.Exists(target))
        {
            File.Copy(source, target);
        }
    }

    private static void CopyDirectoryIfMissing(string sourceDirectory, string targetDirectory)
    {
        if (!Directory.Exists(sourceDirectory) || Directory.Exists(targetDirectory))
        {
            return;
        }

        Directory.CreateDirectory(targetDirectory);
        foreach (var sourceFile in Directory.EnumerateFiles(sourceDirectory))
        {
            File.Copy(sourceFile, Path.Combine(targetDirectory, Path.GetFileName(sourceFile)));
        }
    }
}
