# Ftarna - Food Ordering & Delivery System

A scalable, production-ready Food Ordering & Delivery platform with real-time capabilities and multi-tenant architecture.

## Architecture Overview

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt)
│   ├── error/           # Error handling
│   ├── l10n/            # Localization (AR/EN)
│   ├── services/        # Core services
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   ├── search_service.dart
│   │   └── ocr_service.dart
│   ├── theme/           # App theming
│   └── utils/           # Constants, extensions
│
├── features/
│   ├── auth/            # Authentication & User management
│   ├── restaurant/      # Restaurant listing & details
│   ├── branch/          # Branch management
│   ├── category/        # Menu categories
│   ├── product/         # Products with variations
│   ├── cart/            # Shopping cart
│   ├── order/           # Orders with real-time status
│   ├── reviews/         # Ratings & reviews
│   ├── offers/          # Discounts & promotions
│   └── admin/           # Admin panel
```

## Key Features

### 1. Multi-Restaurant & Multi-Branch System
- Support for multiple restaurants
- Each restaurant can have multiple branches
- Branch-level admin isolation
- Orders are never shared across branches

### 2. Categories & Products
- Hierarchical structure: Restaurant → Categories → Products
- Products with:
  - Bilingual names (AR/EN)
  - Descriptions
  - Prices with discounts
  - Images
  - Variations (sizes, extras)
  - Branch-specific availability

### 3. Real-Time System
- Firestore real-time listeners
- Instant order updates to branch admins
- Live product availability
- No manual refresh needed

### 4. Order Flow
```
Pending → Confirmed → Preparing → Ready → Out for Delivery → Delivered
                                                          ↓
                                                      Cancelled
```
- Users can add items while order is "Pending"
- Admin controls status transitions
- Full order history tracking

### 5. Push Notifications
- Order status updates
- Branch-specific notifications
- Topic-based subscriptions

### 6. Location Services
- GPS-based restaurant sorting
- Nearest branch detection
- Distance calculations

### 7. Search
- Global search across restaurants, categories, products
- Locale-aware matching

### 8. OCR Menu Upload
- Extract menu data from images
- Parse categories, products, prices
- Arabic & English text detection

## User Roles

| Role | Permissions |
|------|-------------|
| User | Browse, order, review |
| Branch Admin | Manage branch orders, menu |
| Restaurant Admin | Manage all branches, full menu |
| Super Admin | Full system access |

## Database Schema (Firestore)

### Collections
- `users` - User profiles & roles
- `restaurants` - Restaurant details
- `branches` - Branch locations
- `categories` - Menu categories
- `products` - Menu items
- `orders` - Order data
- `carts` - Shopping carts
- `reviews` - Ratings
- `offers` - Discounts
- `notifications` - User notifications

## Getting Started

### Prerequisites
- Flutter 3.x
- Firebase project configured
- Firestore, Auth, Messaging enabled

### Installation

```bash
# Clone the repository
git clone <repo-url>

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup
1. Create a Firebase project
2. Add Android/iOS apps
3. Download and add config files
4. Deploy Firestore rules: `firebase deploy --only firestore:rules`

## Key Files

### Entities
- `RestaurantEntity` - Restaurant data
- `BranchEntity` - Branch with geo data
- `CategoryEntity` - Menu category
- `ProductEntity` - Product with variations
- `OrderEntity` - Full order with status history
- `CartEntity` - Shopping cart
- `UserEntity` - User with roles

### Repositories
- `RestaurantRepository` - CRUD + geo queries
- `BranchRepository` - Branch management
- `ProductRepository` - Products + search
- `OrderRepository` - Orders with real-time
- `CartRepository` - Cart with local storage

### Cubits (State Management)
- `RestaurantCubit` - Restaurant listing
- `CartCubit` - Cart operations
- `AuthCubit` - Authentication

## Screens

### User App
- Restaurant List (geo-sorted)
- Restaurant Details with Menu
- Cart
- Checkout
- Order Tracking

### Admin App
- Branch Orders (Kanban-style)
- Order Management
- Menu Editor

## Localization

Fully supports Arabic & English with dynamic switching.

```dart
// Usage
final l10n = AppLocalizations.of(context)!;
Text(l10n.restaurants);

// Entity localization
restaurant.getLocalizedName(locale);
```

## Security Rules

Firestore rules enforce:
- User data privacy
- Branch admin isolation
- Order ownership
- Role-based access control

See `firestore.rules` for full implementation.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `flutter analyze`
5. Submit a PR

## License

MIT License
