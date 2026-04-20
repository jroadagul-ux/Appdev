# BlueSense Resort Management System — Flutter App

A full-featured Flutter mobile app for the BlueSense pool resort management system.
Mirrors all features from the web frontend and connects to your existing Node.js + MongoDB backend.

---

## 📱 Features

### Customer (Guest)
- Login / Register / Forgot Password
- Home page with resort info, amenities, pool cards
- **Multi-step Booking Wizard**:
  - Step 1: Select Oasis (1 or 2), date, session (Day / Night / 22hrs)
  - Step 2: Choose package with pricing, add-ons
  - Step 3: Guest info (name, contact, pax)
  - Step 4: Payment method & downpayment, review & submit
- My Bookings (search by email)
- Profile view

### Admin
- Dashboard with stats: reservations, rooms, staff, revenue, low stock
- Pool sensor monitoring (temperature, turbidity, pH)
- Sales analytics charts (daily bar chart + monthly line chart)
- **Room Management** — CRUD, status filter (Available / Booked / Maintenance)
- **Staff Management** — CRUD, enable/disable accounts, search
- **Inventory Management** — CRUD, log usage, low stock alerts
- **Booking Management** — view all bookings, update status & payment, search/filter
- **Sales Tracking** — view all sales records
- **Reports** — booking, revenue, occupancy, inventory, staff reports

### Staff
- Staff Dashboard with task/inspection counts
- **Tasks** — view assigned tasks, update status (Pending → In Progress → Completed), priority badges, overdue indicators
- **Inspections** — view room inspections, add notes, update status

---

## ⚙️ Setup

### 1. Install Flutter
https://docs.flutter.dev/get-started/install

### 2. Configure Backend URL
Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8080';
```
Change the IP to wherever your Node.js backend is running.

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run
```

### 5. Build for Android
```bash
flutter build apk --release
```

### 6. Build for iOS
```bash
flutter build ios --release
```

---

## 🗂 Project Structure

```
lib/
├── main.dart                    # App entry, routes, splash/auth router
├── config/
│   ├── api_config.dart          # All backend API endpoints
│   ├── app_theme.dart           # Ocean-blue resort color palette & theme
│   └── package_data.dart        # Oasis 1 & 2 packages with pricing
├── models/
│   └── models.dart              # All data models (User, Booking, Room, Staff, etc.)
├── services/
│   ├── api_service.dart         # HTTP client (GET/POST/PUT/PATCH/DELETE)
│   └── auth_provider.dart       # Auth state management (login/logout/token)
├── widgets/
│   └── common_widgets.dart      # StatCard, StatusBadge, EmptyState, etc.
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── forgot_password_screen.dart
    ├── customer/
    │   ├── home_screen.dart
    │   ├── booking_screen.dart      # Multi-step booking wizard
    │   └── my_bookings_screen.dart
    ├── admin/
    │   ├── admin_dashboard_screen.dart
    │   ├── room_management_screen.dart
    │   ├── staff_management_screen.dart
    │   ├── inventory_management_screen.dart
    │   ├── booking_management_screen.dart
    │   └── sales_screen.dart        # Sales + Reports
    └── staff/
        └── staff_screens.dart       # Dashboard + Tasks + Inspections
```

---

## 🔐 Roles & Access

| Role     | Access |
|----------|--------|
| customer | Home, Booking, My Bookings, Profile |
| staff    | Staff Dashboard, Tasks, Inspections |
| admin    | Full admin panel (all pages above) |

The app auto-redirects on login based on role.

---

## 📡 Backend API Required

Your existing Node.js backend on `localhost:8080` (or your network IP).
Make sure the backend is running before using the app.

Database: MongoDB Atlas (`bluesense` DB)

---

## 🎨 Design

- Ocean-blue resort color palette matching the web design
- Google Fonts (Poppins) throughout
- Bottom navigation bar for customers
- Clean cards, status badges, priority indicators
- Pull-to-refresh on all list screens
- Responsive — works on phones and tablets
