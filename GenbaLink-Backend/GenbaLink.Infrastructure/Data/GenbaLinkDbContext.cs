using GenbaLink.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace GenbaLink.Infrastructure.Data;

public class GenbaLinkDbContext : DbContext
{
    public GenbaLinkDbContext(DbContextOptions<GenbaLinkDbContext> options) : base(options)
    {
    }

    public DbSet<ProductSku> ProductSkus { get; set; }
    public DbSet<DemandSignal> DemandSignals { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure ProductSku
        modelBuilder.Entity<ProductSku>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired();
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
        });

        // Configure DemandSignal
        modelBuilder.Entity<DemandSignal>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.CapturedAtUtc);
            entity.HasIndex(e => e.BatchId);
        });
    }
}
