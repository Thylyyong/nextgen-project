package controllers

import (
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"backend/models"
)

// ─────────────────────────────────────────────
// Request / Response DTOs
// ─────────────────────────────────────────────

type registerRequest struct {
	Name     string `json:"name"     binding:"required,min=2"`
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type loginRequest struct {
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type authResponse struct {
	Token string      `json:"token"`
	User  models.User `json:"user"`
}

// ─────────────────────────────────────────────
// AuthController
// ─────────────────────────────────────────────

// AuthController holds a reference to the GORM database instance.
type AuthController struct {
	DB *gorm.DB
}

// NewAuthController constructs an AuthController.
func NewAuthController(db *gorm.DB) *AuthController {
	return &AuthController{DB: db}
}

// ── Register ──────────────────────────────────────────────────────────────────
// POST /api/auth/register
//
// Accepts { name, email, password }.
// Hashes the password with bcrypt (cost=12) before persisting.
// Returns a signed JWT on success.
func (ac *AuthController) Register(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check for duplicate e-mail
	var existing models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&existing).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "email already registered"})
		return
	}

	// Hash password — bcrypt cost 12 provides a strong work factor
	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to hash password"})
		return
	}

	user := models.User{
		Name:         req.Name,
		Email:        req.Email,
		PasswordHash: string(hash),
	}

	if err := ac.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create user"})
		return
	}

	token, err := generateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, authResponse{Token: token, User: user})
}

// ── Login ─────────────────────────────────────────────────────────────────────
// POST /api/auth/login
//
// Accepts { email, password }.
// Compares the supplied password against the stored bcrypt hash.
// Returns a signed JWT (24 h expiry) on success.
func (ac *AuthController) Login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		// Return a generic message — do NOT reveal whether the e-mail exists
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid email or password"})
		return
	}

	// Constant-time bcrypt comparison — safe against timing attacks
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid email or password"})
		return
	}

	token, err := generateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, authResponse{Token: token, User: user})
}

// ── GetProfile ────────────────────────────────────────────────────────────────
// GET /api/auth/me (protected)
func (ac *AuthController) GetProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var user models.User
	if err := ac.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	c.JSON(http.StatusOK, user)
}

// ─────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────

// generateJWT creates a signed HS256 JWT containing the user's ID.
// Expiry is hard-coded to 24 hours; the secret is read from JWT_SECRET env var.
func generateJWT(userID uint) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(os.Getenv("JWT_SECRET")))
}
