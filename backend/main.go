package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"backend/controllers"
	"backend/middleware"
	"backend/models"
)

func main() {
	// ── 1. Load environment variables from .env ──────────────────────────────
	// godotenv is a no-op if .env is absent (production containers use real env vars)
	if err := godotenv.Load(); err != nil {
		log.Println("[config] .env not found — using system environment variables")
	}

	// ── 2. Connect to PostgreSQL via GORM ────────────────────────────────────
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("[fatal] DB_DSN environment variable is not set")
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("[fatal] failed to connect to database: %v", err)
	}
	log.Println("[db] connected to PostgreSQL")

	// ── 3. Auto-migrate schema (creates / updates tables safely) ────────────
	if err := db.AutoMigrate(
		&models.User{},
		&models.Product{},
		&models.Order{},
	); err != nil {
		log.Fatalf("[fatal] auto-migration failed: %v", err)
	}
	log.Println("[db] auto-migration complete")

	// ── 4. Initialise controllers ────────────────────────────────────────────
	authCtrl := controllers.NewAuthController(db)
	productCtrl := controllers.NewProductController(db)
	orderCtrl := controllers.NewOrderController(db)

	// ── 5. Configure Gin ─────────────────────────────────────────────────────
	// Use gin.Release in production; reads GIN_MODE env var automatically
	r := gin.Default()

	// ── 6. Configure CORS safely ─────────────────────────────────────────────
	// AllowAllOrigins=true is fine for local development.
	// ⚠️ Before production: switch to specific AllowOrigins list!
	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
	}))

	// ── 7. Route groups ───────────────────────────────────────────────────────

	api := r.Group("/api")
	{
		// ── Public routes (no auth required) ──────────────────────────
		auth := api.Group("/auth")
		{
			auth.POST("/register", authCtrl.Register)
			auth.POST("/login", authCtrl.Login)
		}

		// Product list is public so guests can browse the catalogue
		api.GET("/products", productCtrl.GetProducts)

		// ── Protected routes (JWT required) ───────────────────────────
		protected := api.Group("/")
		protected.Use(middleware.AuthMiddleware())
		{
			// Products (write / single-fetch)
			protected.GET("/products/:id", productCtrl.GetProductByID)
			protected.POST("/products", productCtrl.CreateProduct)

			// Orders
			protected.POST("/orders", orderCtrl.CreateOrder)
			protected.GET("/orders", orderCtrl.GetMyOrders)
			protected.PUT("/orders/:id/status", orderCtrl.UpdateOrderStatus)
		}
	}

	// ── Health-check endpoint (useful for container probes) ──────────────────
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// ── 8. Start server ───────────────────────────────────────────────────────
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	addr := fmt.Sprintf(":%s", port)
	log.Printf("[server] starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("[fatal] server error: %v", err)
	}
}
