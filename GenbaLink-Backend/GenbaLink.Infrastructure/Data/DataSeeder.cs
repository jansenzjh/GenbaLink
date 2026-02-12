using GenbaLink.Core.Entities;
using GenbaLink.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Data;

public static class DataSeeder
{
    public static async Task SeedAsync(GenbaLinkDbContext context)
    {
        if (context.ProductSkus.Any()) return;

        var skus = new List<ProductSku>();
        var random = new Random();

        var categories = new[] { "Outerwear", "T-Shirts", "Jeans", "Sweaters", "Accessories" };
        var colors = new[] { "09 Black", "00 White", "69 Navy", "32 Beige", "15 Red", "57 Olive" };
        var sizes = new[] { "XS", "S", "M", "L", "XL", "XXL" };
        var names = new[] 
        { 
            "Ultra Light Down Jacket", "AIRism Cotton Oversized T-Shirt", "Selvedge Regular Fit Jeans", 
            "Souffle Yarn Crew Neck Sweater", "HEATTECH Scarf", "Dry-EX Polo Shirt", "EZY Ankle Pants"
        };

        for (int i = 0; i < 1000; i++)
        {
            var category = categories[random.Next(categories.Length)];
            var name = names[random.Next(names.Length)];
            var color = colors[random.Next(colors.Length)];
            var size = sizes[random.Next(sizes.Length)];
            
            // Generate Uniqlo-style 6-digit ID
            var id = random.Next(100000, 999999).ToString();

            // Ensure uniqueness
            while (skus.Any(s => s.Id == id))
            {
                id = random.Next(100000, 999999).ToString();
            }

            skus.Add(new ProductSku
            {
                Id = id,
                Name = name,
                Category = category,
                Color = color,
                Size = size,
                Price = random.Next(1990, 12990), // Prices in Yen equivalent (sort of)
                StockLevel = random.Next(5, 100) // Random stock, some will be low
            });
        }

        await context.ProductSkus.AddRangeAsync(skus);
        await context.SaveChangesAsync();
    }
}
