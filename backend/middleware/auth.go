package middleware

import (
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// AuthMiddleware validates a Bearer JWT in the Authorization header.
//
// On success: sets "userID" (uint) into gin.Context and calls c.Next().
// On failure: aborts with 401 Unauthorized — no details leaked to caller.
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// ── 1. Extract header ──────────────────────────────────────────
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authorization header is required",
			})
			return
		}

		// ── 2. Validate format: "Bearer <token>" ──────────────────────
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authorization header format must be: Bearer <token>",
			})
			return
		}
		rawToken := parts[1]

		// ── 3. Parse & validate JWT signature ─────────────────────────
		secret := os.Getenv("JWT_SECRET")
		token, err := jwt.Parse(rawToken, func(t *jwt.Token) (interface{}, error) {
			// Ensure the signing method is HMAC — reject "alg:none" attacks
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return []byte(secret), nil
		})
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid or expired token",
			})
			return
		}

		// ── 4. Extract claims & inject into context ────────────────────
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid token claims",
			})
			return
		}

		// JWT stores numbers as float64; convert safely to uint
		userIDFloat, ok := claims["user_id"].(float64)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid token payload",
			})
			return
		}
		c.Set("userID", uint(userIDFloat))

		c.Next()
	}
}
