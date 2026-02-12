using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace GenbaLink.DB;

public class SchemaUpgrader
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SchemaUpgrader> _logger;

    public SchemaUpgrader(IConfiguration configuration, ILogger<SchemaUpgrader> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public void Upgrade()
    {
        // Fallback to default if not configured, matching Program.cs hardcoded string for now
        var connectionString = _configuration.GetConnectionString("DefaultConnection") 
                             ?? "Data Source=genbalink.db";
        
        using var connection = new SqliteConnection(connectionString);
        
        try 
        {
            var evolve = new EvolveDb.Evolve(connection, msg => _logger.LogInformation(msg))
            {
                EmbeddedResourceAssemblies = new[] { typeof(SchemaUpgrader).Assembly },
                IsEraseDisabled = true,
                // The filter should match the embedded resource names prefix
                EmbeddedResourceFilters = new[] { "GenbaLink.DB.Scripts" }
            };

            evolve.Migrate();
        }
        catch (Exception ex)
        {
            _logger.LogCritical(ex, "Database migration failed.");
            throw;
        }
    }
}
