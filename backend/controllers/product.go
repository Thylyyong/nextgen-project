package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend/models"
)

// ─────────────────────────────────────────────
// ProductController
// ─────────────────────────────────────────────

// ProductController handles all product-related HTTP endpoints.
type ProductController struct {
	DB *gorm.DB
}

// NewProductController constructs a ProductController.
func NewProductController(db *gorm.DB) *ProductController {
	return &ProductController{DB: db}
}

// ── listProductsResponse is the paginated response envelope ──────────────────
type listProductsResponse struct {
	Data  []models.Product `json:"data"`
	Total int64            `json:"total"`
}

// ── GetProducts ───────────────────────────────────────────────────────────────
// GET /api/products?category=<value>&page=<n>&limit=<n>
//
// Query parameters:
//   - category : optional string. If blank or "All" → return every product.
//                Otherwise filter by exact Category match (case-insensitive).
//   - page     : optional int (default 1)
//   - limit    : optional int (default 20, max 100)
//
// This endpoint is PUBLIC — no auth required for browsing.
func (pc *ProductController) GetProducts(c *gin.Context) {
	// ── Parse query params ────────────────────────────────────────────
	category := strings.TrimSpace(c.Query("category"))
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	// Clamp values for safety
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	offset := (page - 1) * limit

	// ── Build query ───────────────────────────────────────────────────
	query := pc.DB.Model(&models.Product{})

	// Apply category filter only when a specific (non-"All") category is given
	if category != "" && !strings.EqualFold(category, "All") {
		query = query.Where("LOWER(category) = LOWER(?)", category)
	}

	// ── Count total (for pagination metadata) ─────────────────────────
	var total int64
	if err := query.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	// ── Fetch page ────────────────────────────────────────────────────
	var products []models.Product
	if err := query.
		Order("created_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	c.JSON(http.StatusOK, listProductsResponse{Data: products, Total: total})
}

// ── GetProductByID ────────────────────────────────────────────────────────────
// GET /api/products/:id  (protected — requires valid JWT)
func (pc *ProductController) GetProductByID(c *gin.Context) {
	id := c.Param("id")
	var product models.Product

	if err := pc.DB.First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
		return
	}

	c.JSON(http.StatusOK, product)
}

// ── CreateProduct ─────────────────────────────────────────────────────────────
// POST /api/products  (protected)
// Allows authenticated users/admins to create a new product listing.
type createProductRequest struct {
	Name          string  `json:"name"           binding:"required"`
	Category      string  `json:"category"       binding:"required"`
	BasePrice     float64 `json:"base_price"     binding:"required,gt=0"`
	CostPrice     float64 `json:"cost_price"     binding:"required,gt=0"`
	StockQuantity int     `json:"stock_quantity" binding:"min=0"`
	ImageURL      string  `json:"image_url"`
}

func (pc *ProductController) CreateProduct(c *gin.Context) {
	var req createProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	product := models.Product{
		Name:          req.Name,
		Category:      req.Category,
		BasePrice:     req.BasePrice,
		CostPrice:     req.CostPrice,
		StockQuantity: req.StockQuantity,
		ImageURL:      req.ImageURL,
	}

	if err := pc.DB.Create(&product).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create product"})
		return
	}

	c.JSON(http.StatusCreated, product)
}
