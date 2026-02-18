using GenbaLink.Core.Entities;
using GenbaLink.Infrastructure.Data;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Data;

public static class DataSeeder
{
    public static async Task SeedAsync(FirestoreRepository repository)
    {
        var existingSkus = await repository.GetAllAsync<ProductSku>("ProductSkus");
        if (existingSkus.Count > 0) return;

        var categories = new[] { "Men's Tops", "Women's Tops", "Outerwear", "Bottoms", "Accessories" };
        var colors = new[] { "White", "Black", "Navy", "Beige", "Olive", "Gray", "Red", "Blue" };
        var sizes = new[] { "XS", "S", "M", "L", "XL" };
        
        var productNames = new Dictionary<string, string[]>
        {
            { "Men's Tops", new[] { "AIRism Cotton T-Shirt", "Oxford Shirt", "Dry-EX Polo", "Linen Blend Shirt" } },
            { "Women's Tops", new[] { "Rayon Blouse", "Supima Cotton Tee", "Sleeveless Top", "Crew Neck Sweater" } },
            { "Outerwear", new[] { "Ultra Light Down Jacket", "Pocketable Parka", "Blocktech Coat", "Denim Jacket" } },
            { "Bottoms", new[] { "Stretch Chinos", "Selvedge Jeans", "Smart Ankle Pants", "Cargo Joggers" } },
            { "Accessories", new[] { "Canvas Tote Bag", "Round Mini Shoulder Bag", "Color Socks", "Leather Belt" } }
        };

        var random = new Random(42); // Seeded for consistency

        for (int i = 0; i < 100; i++)
        {
            var category = categories[random.Next(categories.Length)];
            var color = colors[random.Next(colors.Length)];
            var size = sizes[random.Next(sizes.Length)];
            var possibleNames = productNames[category];
            var baseName = possibleNames[random.Next(possibleNames.Length)];

            var sku = new ProductSku
            {
                Id = (100000 + i).ToString(),
                Name = baseName,
                Category = category,
                Color = color,
                Size = size,
                Price = Math.Round(14.90 + (random.NextDouble() * 85), 2),
                StockLevel = random.Next(0, 150)
            };
            
            await repository.AddAsync("ProductSkus", sku.Id, sku);
        }
    }
}
