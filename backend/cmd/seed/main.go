package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"backend/models"
)

func main() {
	// Load .env
	if err := godotenv.Load(); err != nil {
		log.Println("[seed] no .env — using system env vars")
	}

	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("[seed] DB_DSN not set")
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		log.Fatalf("[seed] db connect failed: %v", err)
	}

	// Auto-migrate to ensure tables exist
	db.AutoMigrate(&models.Product{})

	// ── Sample Products ───────────────────────────────────────────────────────
	products := []models.Product{
		// ── Drinks ────────────────────────────────────────────────────────────
		{
			Name:          "Fresh Orange Juice",
			Category:      "Drinks",
			BasePrice:     2.50,
			CostPrice:     3.50,
			StockQuantity: 120,
			ImageURL:      "https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&q=80",
		},
		{
			Name:          "Cold Brew Coffee",
			Category:      "Drinks",
			BasePrice:     3.99,
			CostPrice:     5.50,
			StockQuantity: 80,
			ImageURL:      "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&q=80",
		},
		{
			Name:          "Mango Smoothie",
			Category:      "Drinks",
			BasePrice:     4.20,
			CostPrice:     5.00,
			StockQuantity: 60,
			ImageURL:      "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&q=80",
		},
		{
			Name:          "Sparkling Water 500ml",
			Category:      "Drinks",
			BasePrice:     1.20,
			CostPrice:     1.20,
			StockQuantity: 200,
			ImageURL:      "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&q=80",
		},
		{
			Name:          "Green Tea Matcha Latte",
			Category:      "Drinks",
			BasePrice:     4.50,
			CostPrice:     6.00,
			StockQuantity: 45,
			ImageURL:      "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400&q=80",
		},

		// ── Clothing ──────────────────────────────────────────────────────────
		{
			Name:          "Classic White T-Shirt",
			Category:      "Clothing",
			BasePrice:     12.99,
			CostPrice:     20.00,
			StockQuantity: 150,
			ImageURL:      "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&q=80",
		},
		{
			Name:          "Slim Fit Denim Jeans",
			Category:      "Clothing",
			BasePrice:     34.99,
			CostPrice:     49.99,
			StockQuantity: 90,
			ImageURL:      "https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&q=80",
		},
		{
			Name:          "Oversized Hoodie — Navy",
			Category:      "Clothing",
			BasePrice:     29.00,
			CostPrice:     39.99,
			StockQuantity: 75,
			ImageURL:      "https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=400&q=80",
		},
		{
			Name:          "Summer Floral Dress",
			Category:      "Clothing",
			BasePrice:     24.50,
			CostPrice:     35.00,
			StockQuantity: 55,
			ImageURL:      "https://images.unsplash.com/photo-1623609163859-ca93c959b98a?w=400&q=80",
		},
		{
			Name:          "Leather Sneakers",
			Category:      "Clothing",
			BasePrice:     59.99,
			CostPrice:     79.99,
			StockQuantity: 40,
			ImageURL:      "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&q=80",
		},

		// ── Groceries ─────────────────────────────────────────────────────────
		{
			Name:          "Organic Avocados (Pack of 4)",
			Category:      "Groceries",
			BasePrice:     3.99,
			CostPrice:     5.50,
			StockQuantity: 100,
			ImageURL:      "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&q=80",
		},
		{
			Name:          "Sourdough Bread Loaf",
			Category:      "Groceries",
			BasePrice:     4.50,
			CostPrice:     4.50,
			StockQuantity: 30,
			ImageURL:      "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80",
		},
		{
			Name:          "Free Range Eggs (12 pack)",
			Category:      "Groceries",
			BasePrice:     5.20,
			CostPrice:     7.00,
			StockQuantity: 85,
			ImageURL:      "https://images.unsplash.com/photo-1569288052389-dac9b0ac9eac?w=400&q=80",
		},
		{
			Name:          "Whole Milk 1L",
			Category:      "Groceries",
			BasePrice:     1.80,
			CostPrice:     1.80,
			StockQuantity: 120,
			ImageURL:      "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80",
		},
		{
			Name:          "Mixed Salad Greens 200g",
			Category:      "Groceries",
			BasePrice:     2.99,
			CostPrice:     4.00,
			StockQuantity: 65,
			ImageURL:      "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80",
		},
		{
			Name:          "Jasmine Rice 5kg",
			Category:      "Groceries",
			BasePrice:     8.90,
			CostPrice:     10.00,
			StockQuantity: 200,
			ImageURL:      "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&q=80",
		},
	}

	inserted := 0
	skipped := 0
	for _, p := range products {
		// Skip if a product with the same name already exists
		var existing models.Product
		if err := db.Where("name = ?", p.Name).First(&existing).Error; err == nil {
			skipped++
			continue
		}
		if err := db.Create(&p).Error; err != nil {
			log.Printf("[seed] failed to insert %q: %v", p.Name, err)
			continue
		}
		inserted++
		fmt.Printf("  ✓ [%s] %s — $%.2f\n", p.Category, p.Name, p.BasePrice)
	}

	fmt.Printf("\n[seed] done — %d inserted, %d skipped (already exists)\n", inserted, skipped)
}
