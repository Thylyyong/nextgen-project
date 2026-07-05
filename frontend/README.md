# NextGen — E-Commerce MVP

A full-stack E-commerce platform — **Go backend** + **Flutter frontend**.

---

## Prerequisites

Install these once before running anything:

| Tool | Install command | Check |
|------|----------------|-------|
| **Go** | `brew install go` | `go version` |
| **PostgreSQL** | `brew install postgresql@16` | `psql --version` |
| **Flutter** | Already at `/usr/local/bin/flutter` | `flutter --version` |

---

## 1 — Start PostgreSQL & Create the Database

```bash
# Start PostgreSQL service (first time + after restart)
brew services start postgresql@16

# Create the database
psql postgres -c "CREATE DATABASE nextgen_db;"

# Optional: verify it exists
psql postgres -c "\l" | grep nextgen
```

---

## 2 — Run the Backend (Go + Gin)

Open **Terminal 1**:

```bash
cd /Users/tly/nextgen-project/backend

# First time only: download all Go dependencies
go mod tidy

# Start the server (listens on :8080)
go run main.go
```

You should see:
```
[db] connected to PostgreSQL
[db] auto-migration complete
[server] starting on :8080
```

> The `.env` file already has the DB credentials. If you change the DB password, edit `.env`:
> ```
> DB_DSN=host=localhost user=postgres password=YOUR_PW dbname=nextgen_db port=5432 sslmode=disable
> JWT_SECRET=your_secret_key
> ```

### Quick API test (optional)
```bash
# Register a user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@mail.com","password":"password123"}'

# Browse products (no auth needed)
curl http://localhost:8080/api/products

# Filter by category
curl "http://localhost:8080/api/products?category=Drinks"
```

---

## 3 — Run the Flutter App

Open **Terminal 2**:

```bash
cd /Users/tly/nextgen-project/frontend

# First time only: install packages
flutter pub get
```

### Choose your target device

**Option A — macOS Desktop (fastest, no simulator needed)**
```bash
flutter run -d macos
```

**Option B — Chrome / Web**
```bash
flutter run -d chrome
```

**Option C — iOS Simulator**
```bash
# List available simulators
flutter emulators

# Launch iPhone simulator
flutter emulators --launch apple_ios_simulator

# Run on it
flutter run -d iphone
```

**Option D — Your iPhone (USB)**

Make sure your iPhone is plugged in and trusted, then:
```bash
flutter run -d 00008110-0016408E1E63A01E
```

> Your iPhone ID from `flutter devices` is `00008110-0016408E1E63A01E`.
> It needs **Developer Mode** enabled: Settings → Privacy & Security → Developer Mode → ON

---

## ⚠️ Important: Backend URL for each device

The Flutter app's base URL is set in:
[`lib/core/network/api_client.dart`](lib/core/network/api_client.dart) — line ~20

Change `baseUrl` depending on your target:

| Target | baseUrl value |
|--------|--------------|
| macOS Desktop | `http://localhost:8080/api` ✅ (default) |
| iOS Simulator | `http://localhost:8080/api` ✅ |
| Chrome (web) | `http://localhost:8080/api` ✅ |
| Android Emulator | `http://10.0.2.2:8080/api` |
| Real iPhone (USB) | `http://YOUR_MAC_IP:8080/api` |

To find your Mac's local IP:
```bash
ipconfig getifaddr en0
```

---

## Project Structure

```
nextgen-project/
├── backend/
│   ├── .env                    # DB + JWT secrets (gitignored)
│   ├── main.go                 # Entry point
│   ├── models/models.go        # User, Product, Order
│   ├── middleware/auth.go      # JWT validation
│   └── controllers/
│       ├── auth.go             # Register + Login
│       ├── product.go          # GET /api/products?category=
│       └── order.go            # Create + list orders
└── frontend/
    └── lib/
        ├── main.dart           # App entry + DI + Router
        ├── app/theme/          # Colors, text styles (Outfit font)
        ├── core/
        │   ├── network/        # Dio API client (auto Bearer token)
        │   └── storage/        # flutter_secure_storage JWT wrapper
        ├── auth/               # Login + Register pages + service
        └── product/
            ├── cubit/          # State management
            ├── model/          # Product data class
            ├── service/        # API calls
            ├── view/           # ProductPage
            └── widget/
                ├── custom_filter_chip.dart   # Category pill chips
                ├── category_filter_bar.dart  # Chips row (All/Drinks/...)
                ├── product_card.dart         # Product card UI
                ├── product_shimmer.dart      # Loading skeleton
                └── discount_badge.dart       # Red discount circle
```

---

## API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | ❌ | Create account, returns JWT |
| POST | `/api/auth/login` | ❌ | Login, returns JWT |
| GET | `/api/products` | ❌ | List all products |
| GET | `/api/products?category=Drinks` | ❌ | Filter by category |
| GET | `/api/products/:id` | ✅ | Single product |
| POST | `/api/products` | ✅ | Create product |
| POST | `/api/orders` | ✅ | Place order |
| GET | `/api/orders` | ✅ | My orders |
| PUT | `/api/orders/:id/status` | ✅ | Update order status |
| GET | `/health` | ❌ | Health check |
