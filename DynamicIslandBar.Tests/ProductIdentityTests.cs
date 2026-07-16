using DynamicIslandBar;

namespace DynamicIslandBar.Tests;

public sealed class ProductIdentityTests
{
    [Fact]
    public void BrandConstants_AreReleaseValues()
    {
        Assert.Equal("RBar", ProductIdentity.ProductName);
        Assert.Equal("rainwave", ProductIdentity.PublisherName);
        Assert.Equal("DynamicIslandBar", ProductIdentity.LegacyProductName);
        Assert.True(ProductIdentity.IsOwnProcessName("RBar"));
        Assert.True(ProductIdentity.IsOwnProcessName("DynamicIslandBar"));
        Assert.True(ProductIdentity.IsOwnExecutablePath(@"C:\Apps\RBar.exe"));
        Assert.False(ProductIdentity.IsOwnProcessName("Explorer"));
    }

    [Fact]
    public void MigrateLegacyUserData_CopiesKnownFilesWithoutOverwritingRBarData()
    {
        var root = Path.Combine(Path.GetTempPath(), $"RBar-Migration-{Guid.NewGuid():N}");
        var legacy = Path.Combine(root, "DynamicIslandBar");
        var target = Path.Combine(root, "RBar");
        try
        {
            Directory.CreateDirectory(Path.Combine(legacy, "Logs"));
            Directory.CreateDirectory(target);
            File.WriteAllText(Path.Combine(legacy, "capsule-config.json"), "legacy");
            File.WriteAllText(Path.Combine(legacy, "capsule-config.json.bak"), "backup");
            File.WriteAllText(Path.Combine(legacy, "permissions.json"), "permissions");
            File.WriteAllText(Path.Combine(legacy, "Logs", "app.log"), "log");
            File.WriteAllText(Path.Combine(target, "capsule-config.json"), "current");

            ProductIdentity.MigrateLegacyUserData(legacy, target);

            Assert.Equal("current", File.ReadAllText(Path.Combine(target, "capsule-config.json")));
            Assert.Equal("backup", File.ReadAllText(Path.Combine(target, "capsule-config.json.bak")));
            Assert.Equal("permissions", File.ReadAllText(Path.Combine(target, "permissions.json")));
            Assert.Equal("log", File.ReadAllText(Path.Combine(target, "Logs", "app.log")));
        }
        finally
        {
            if (Directory.Exists(root))
            {
                Directory.Delete(root, recursive: true);
            }
        }
    }
}
