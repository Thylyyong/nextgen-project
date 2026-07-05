package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend/models"
)

// ─────────────────────────────────────────────
// OrderController
// ─────────────────────────────────────────────

// OrderController handles all order-related HTTP endpoints.
type OrderController struct {
	DB *gorm.DB
}

// NewOrderController constructs an OrderController.
func NewOrderController(db *gorm.DB) *OrderController {
	return &OrderController{DB: db}
}

// ── CreateOrder ───────────────────────────────────────────────────────────────
// POST /api/orders  (protected)
//
// The authenticated user's ID is read from gin.Context (set by AuthMiddleware).
type createOrderRequest struct {
	TotalAmount float64 `json:"total_amount" binding:"required,gt=0"`
}

func (oc *OrderController) CreateOrder(c *gin.Context) {
	var req createOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Read userID injected by AuthMiddleware — guaranteed to exist on protected routes
	userID, _ := c.Get("userID")

	order := models.Order{
		UserID:      userID.(uint),
		TotalAmount: req.TotalAmount,
		Status:      models.StatusPending,
	}

	if err := oc.DB.Create(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create order"})
		return
	}

	c.JSON(http.StatusCreated, order)
}

// ── GetMyOrders ───────────────────────────────────────────────────────────────
// GET /api/orders  (protected)
//
// Returns all orders belonging to the currently authenticated user.
func (oc *OrderController) GetMyOrders(c *gin.Context) {
	userID, _ := c.Get("userID")

	var orders []models.Order
	if err := oc.DB.
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": orders, "total": len(orders)})
}

// ── UpdateOrderStatus ─────────────────────────────────────────────────────────
// PUT /api/orders/:id/status  (protected)
//
// Allows updating an order's lifecycle status.
type updateStatusRequest struct {
	Status models.OrderStatus `json:"status" binding:"required"`
}

func (oc *OrderController) UpdateOrderStatus(c *gin.Context) {
	id := c.Param("id")
	var req updateStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate enum value
	validStatuses := map[models.OrderStatus]bool{
		models.StatusPending:    true,
		models.StatusProcessing: true,
		models.StatusReady:      true,
	}
	if !validStatuses[req.Status] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status value"})
		return
	}

	result := oc.DB.Model(&models.Order{}).Where("id = ?", id).Update("status", req.Status)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update status"})
		return
	}
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "status updated"})
}

// ── GetOrderByID ──────────────────────────────────────────────────────────────
// GET /api/orders/:id  (protected)
func (oc *OrderController) GetOrderByID(c *gin.Context) {
	id := c.Param("id")
	userID, _ := c.Get("userID")

	var order models.Order
	if err := oc.DB.Preload("User").Where("id = ? AND user_id = ?", id, userID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}

	c.JSON(http.StatusOK, order)
}
