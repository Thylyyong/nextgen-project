package models

import (
	"time"
)

// ─────────────────────────────────────────────
// User
// ─────────────────────────────────────────────

// User represents an authenticated platform user.
// The PasswordHash field is intentionally excluded from
// all JSON output via the `json:"-"` annotation — it is
// NEVER serialised in any API response.
type User struct {
	ID           uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name         string    `gorm:"size:255;not null"        json:"name"`
	Email        string    `gorm:"size:255;uniqueIndex;not null" json:"email"`
	PasswordHash string    `gorm:"size:255;not null"        json:"-"` // Hidden from all JSON marshalling
	CreatedAt    time.Time `gorm:"autoCreateTime"           json:"created_at"`
}

// ─────────────────────────────────────────────
// Product
// ─────────────────────────────────────────────

// Product represents a single sellable item.
// Category is a plain string used as the filter-chip label
// on the frontend (e.g. "Drinks", "Clothing", "Groceries").
type Product struct {
	ID            uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name          string    `gorm:"size:255;not null;index"  json:"name"`
	Category      string    `gorm:"size:100;not null;index"  json:"category"` // filter-chip key
	BasePrice     float64   `gorm:"not null"                 json:"base_price"`
	CostPrice     float64   `gorm:"not null"                 json:"cost_price"`
	StockQuantity int       `gorm:"default:0"               json:"stock_quantity"`
	ImageURL      string    `gorm:"size:500"                 json:"image_url"`
	CreatedAt     time.Time `gorm:"autoCreateTime"           json:"created_at"`
}

// ─────────────────────────────────────────────
// Order
// ─────────────────────────────────────────────

// OrderStatus is a type-safe enum for the order lifecycle.
type OrderStatus string

const (
	StatusPending    OrderStatus = "Pending"
	StatusProcessing OrderStatus = "Processing"
	StatusReady      OrderStatus = "Ready"
)

// Order represents a customer purchase.
// It belongs to a User via UserID (foreign key).
type Order struct {
	ID          uint        `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID      uint        `gorm:"not null;index"           json:"user_id"`
	User        User        `gorm:"foreignKey:UserID"        json:"user,omitempty"`
	TotalAmount float64     `gorm:"not null"                 json:"total_amount"`
	Status      OrderStatus `gorm:"size:50;default:'Pending'" json:"status"`
	CreatedAt   time.Time   `gorm:"autoCreateTime"           json:"created_at"`
}
