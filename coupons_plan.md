# Coupons Lifecycle Plan - MEGO Client App

## 📋 Overview
This document outlines the complete lifecycle of coupons in the MEGO client app, from selection to automatic deactivation after ride completion, including discount application in the pricing flow.

---

## 🔄 Coupon Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      COUPON LIFECYCLE                            │
└─────────────────────────────────────────────────────────────────┘

1. User Views Coupons (CouponsView)
   ↓
2. User Selects Active Coupon
   ↓
3. Coupon Applied to Ride Request
   ↓
4. Discount Calculated in Price
   ↓
5. Ride Confirmed with Discount
   ↓
6. Ride In Progress
   ↓
7. Ride Completed
   ↓
8. Coupon Deactivated (active = false)
   ↓
9. Update Ride Record with Used Coupon Info
```

---

## 📁 Files Structure & Responsibilities

### 1. **Coupon Model** (`lib/core/shared_models/coupon_model.dart`)
**Current Status:** ✅ Already Complete
- Contains all coupon properties
- Has validation methods (`isValid`, `isExpired`)
- Handles JSON serialization

### 2. **Coupons Controller** (`lib/features/coupons/coupons_controller.dart`)
**Current Status:** ✅ Mostly Complete
**Needs Addition:**
- Add `selectedCoupon` variable to track selected coupon
- Add `selectCoupon(Coupon coupon)` method
- Add `clearSelectedCoupon()` method

### 3. **Coupons View** (`lib/features/coupons/coupons_view.dart`)
**Current Status:** ✅ Mostly Complete
**Needs Addition:**
- Add selection UI (checkbox/radio button) on each coupon card
- Add "Apply Coupon" button to navigate back with selected coupon
- Add visual indicator for selected coupon

### 4. **Search Places Controller** (`lib/features/search_places & calculation/controllers/search_places_controller.dart`)
**Needs Addition:**
- Add `selectedCoupon` variable
- Add `applyCoupon(Coupon coupon)` method
- Update price calculation to include discount

### 5. **Est Services Controller** (`lib/features/search_places & calculation/controllers/est_services_controller.dart`)
**Needs Addition:**
- Add `calculateDiscount(double price, Coupon? coupon)` method
- Update `calculateEstimatedPrice()` to accept optional coupon parameter
- Return both original price and discounted price

### 6. **Confirm Ride View** (`lib/features/confirm_ride/confirm_ride_view.dart`)
**Needs Addition:**
- Add "Apply Coupon" button/section
- Display coupon info if applied (discount amount, final price)
- Show original price with strikethrough if discount applied
- Navigate to CouponsView for coupon selection

### 7. **Ride Request Creation** (In confirm ride flow)
**Needs Addition:**
- Save `coupon_id` in ride_requests table when creating ride
- Save `discount_amount` in ride_requests table
- Save `original_price` and `final_price`

### 8. **Trip Tracking Controller** (`lib/features/trip_tracking&completed&rating/controllers/trip_tracking_controller.dart`)
**Needs Addition:**
- On ride completion, deactivate used coupon
- Update coupon `active = false` in Supabase

---

## 🗄️ Database Schema Updates

### **ride_requests table** - Add columns:
```sql
ALTER TABLE ride_requests
ADD COLUMN coupon_id UUID REFERENCES coupons(id),
ADD COLUMN discount_amount DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN original_price DECIMAL(10, 2),
ADD COLUMN final_price DECIMAL(10, 2);
```

### **coupons table** - Current structure (already exists):
```sql
coupons (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  type TEXT NOT NULL,
  coupon_for TEXT DEFAULT 'client',
  valid_until TIMESTAMP NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)
```

---

## 📝 Implementation Steps (Simple Way)

### **Phase 1: Coupon Selection** (CouponsView + Controller)

#### Step 1.1: Add Selection State to CouponsController
```dart
// Add to CouponsController
Rx<Coupon?> selectedCoupon = Rx<Coupon?>(null);

void selectCoupon(Coupon coupon) {
  if (coupon.isValid) {
    selectedCoupon.value = coupon;
    update();
    Get.back(); // Return to previous screen
  }
}

void clearSelectedCoupon() {
  selectedCoupon.value = null;
  update();
}
```

#### Step 1.2: Update CouponsView UI
- Add radio button/checkbox on active coupon cards
- Add "Apply" button that calls `controller.selectCoupon(coupon)`
- Show visual selection indicator

---

### **Phase 2: Apply Coupon to Ride Request** (SearchPlacesController)

#### Step 2.1: Add Coupon to SearchPlacesController
```dart
// Add to SearchPlacesController
Coupon? appliedCoupon;

void applyCoupon(Coupon coupon) {
  appliedCoupon = coupon;
  update();
}

void removeCoupon() {
  appliedCoupon = null;
  update();
}
```

#### Step 2.2: Update ConfirmRideView
- Add "Have a coupon?" section
- Show applied coupon details (type, discount)
- Button to navigate to CouponsView
- When returning from CouponsView, get selected coupon and apply it

```dart
// In ConfirmRideView - Navigate to coupons
onTap: () async {
  await Get.to(() => CouponsView());
  final couponsController = Get.find<CouponsController>();
  if (couponsController.selectedCoupon.value != null) {
    searchController.applyCoupon(couponsController.selectedCoupon.value!);
  }
}
```

---

### **Phase 3: Calculate Discount** (EstServicesController)

#### Step 3.1: Add Discount Calculation Method
```dart
// Add to EstServicesController
double calculateDiscount(double originalPrice, Coupon? coupon) {
  if (coupon == null || !coupon.isValid) return 0.0;
  
  switch (coupon.type) {
    case 'DISCOUNT_10':
      return originalPrice * 0.10;
    case 'DISCOUNT_20':
      return originalPrice * 0.20;
    case 'DISCOUNT_25':
      return originalPrice * 0.25;
    case 'DISCOUNT_50':
      return originalPrice * 0.50;
    case 'FLAT_50':
      return 50.0;
    case 'FLAT_100':
      return 100.0;
    case 'FREE_RIDE':
      return originalPrice; // 100% discount
    default:
      return 0.0;
  }
}

Map<String, double> calculatePriceWithDiscount(
  double pickupLat,
  double pickupLng,
  double dropoffLat,
  double dropoffLng,
  Coupon? coupon,
) {
  final originalPrice = calculateEstimatedPrice(
    pickupLat, pickupLng, dropoffLat, dropoffLng
  );
  
  final discount = calculateDiscount(originalPrice, coupon);
  final finalPrice = (originalPrice - discount).clamp(0.0, double.infinity);
  
  return {
    'originalPrice': originalPrice,
    'discount': discount,
    'finalPrice': finalPrice,
  };
}
```

#### Step 3.2: Update UI to Show Prices
- Show original price (strikethrough if discount applied)
- Show discount amount in green
- Show final price in bold

```
Original Price:  $25.00  (strikethrough)
Discount:       -$5.00   (green)
─────────────────────────
Final Price:     $20.00  (bold, large)
```

---

### **Phase 4: Save Coupon with Ride Request** (Confirm Ride)

#### Step 4.1: Update Ride Request Creation
```dart
// In _confirmRide() method (confirm_button.dart)
final priceInfo = estServicesController.calculatePriceWithDiscount(
  controller.selectedFromPlace!.latitude,
  controller.selectedFromPlace!.longitude,
  controller.selectedToPlace!.latitude,
  controller.selectedToPlace!.longitude,
  controller.appliedCoupon, // Pass coupon
);

// Create ride request with coupon info
final rideRequestData = {
  'user_id': userId,
  'pickup_place': controller.selectedFromPlace!.name,
  'pickup_lat': controller.selectedFromPlace!.latitude,
  'pickup_lng': controller.selectedFromPlace!.longitude,
  'dropoff_place': controller.selectedToPlace!.name,
  'dropoff_lat': controller.selectedToPlace!.latitude,
  'dropoff_lng': controller.selectedToPlace!.longitude,
  'coupon_id': controller.appliedCoupon?.id, // Save coupon ID
  'original_price': priceInfo['originalPrice'],
  'discount_amount': priceInfo['discount'],
  'final_price': priceInfo['finalPrice'],
  'estimated_time': estimatedTime,
  'status': 'pending',
  'created_at': DateTime.now().toIso8601String(),
};
```

---

### **Phase 5: Deactivate Coupon After Ride** (TripTrackingController)

#### Step 5.1: Add Deactivation Method
```dart
// Add to TripTrackingController
Future<void> deactivateUsedCoupon(String? couponId) async {
  if (couponId == null) return;
  
  try {
    final supabase = Supabase.instance.client;
    
    await supabase
        .from('coupons')
        .update({
          'active': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', couponId);
    
    print('✅ Coupon $couponId deactivated successfully');
  } catch (e) {
    print('❌ Error deactivating coupon: $e');
  }
}
```

#### Step 5.2: Call Deactivation on Ride Completion
```dart
// In TripTrackingController - when ride status changes to 'completed'
if (rideStatus == 'completed') {
  // Deactivate coupon if used
  await deactivateUsedCoupon(rideModel.couponId);
  
  // Navigate to rating screen
  navigateToRatingScreen();
}
```

---

## 🎯 User Flow Example

### Scenario: User applies 20% discount coupon

1. **User in ConfirmRideView** sees estimated price: $25.00
2. **User taps "Apply Coupon"** → navigates to CouponsView
3. **User selects "20% Discount"** coupon → returns to ConfirmRideView
4. **UI Updates:**
   ```
   ✓ Coupon Applied: 20% Discount
   
   Original Price:   $25.00
   Discount (20%):   -$5.00
   ──────────────────────────
   Final Price:      $20.00
   ```
5. **User confirms ride** → ride_request saved with:
   - coupon_id: "test-2"
   - original_price: 25.00
   - discount_amount: 5.00
   - final_price: 20.00
6. **Driver accepts** → Ride in progress
7. **Ride completes** → Automatic:
   - Coupon "test-2" → active = false
   - User can't use this coupon again
8. **User goes to CouponsView** → sees coupon marked as "Used/Expired"

---

## 🔧 Implementation Order

### ✅ **Week 1: Backend & Models**
- [ ] Update Supabase coupons table (add columns to ride_requests)
- [ ] Test coupon queries
- [ ] Verify current coupon model works

### ✅ **Week 2: Coupon Selection**
- [ ] Add selection state to CouponsController
- [ ] Update CouponsView with selection UI
- [ ] Add "Apply" button functionality
- [ ] Test navigation flow

### ✅ **Week 3: Discount Calculation**
- [ ] Add discount calculation to EstServicesController
- [ ] Update price display in ConfirmRideView
- [ ] Add coupon display section
- [ ] Test all coupon types (10%, 20%, FREE_RIDE, etc.)

### ✅ **Week 4: Integration**
- [ ] Update ride request creation to include coupon data
- [ ] Add coupon deactivation on ride completion
- [ ] Test full lifecycle
- [ ] Handle edge cases (expired coupons, invalid coupons)

---

## 🚨 Edge Cases to Handle

### 1. **Coupon Expires During Ride**
- Solution: Check validity when applying, not when ride completes

### 2. **User Selects Coupon but Changes Mind**
- Solution: Add "Remove Coupon" button in ConfirmRideView

### 3. **Ride Cancelled After Coupon Applied**
- Solution: Don't deactivate coupon if ride is cancelled, only on 'completed'

### 4. **Multiple Users Try to Use Same "all" Coupon**
- Solution: "all" coupons are for viewing only, system creates individual copies

### 5. **Discount Exceeds Price**
- Solution: Use `clamp(0.0, double.infinity)` to ensure final price >= 0

### 6. **Network Error During Deactivation**
- Solution: Retry mechanism or background job

---

## 📊 Testing Checklist

### Coupon Selection
- [ ] Can view active coupons
- [ ] Can select valid coupon
- [ ] Cannot select expired coupon
- [ ] Selected coupon returns to ConfirmRide

### Discount Application
- [ ] 10% discount calculates correctly
- [ ] 20% discount calculates correctly
- [ ] FLAT_50 deducts $50
- [ ] FREE_RIDE makes price $0
- [ ] UI shows original + discounted price

### Ride Completion
- [ ] Coupon deactivates when ride completes
- [ ] Coupon stays active if ride cancelled
- [ ] Deactivated coupon appears in "Expired" section
- [ ] User cannot reuse deactivated coupon

### Database
- [ ] ride_requests saves coupon_id correctly
- [ ] discount_amount saves correctly
- [ ] Coupon active status updates in DB
- [ ] Query returns correct coupons for user

---

## 📱 UI Components Needed

### CouponsView Updates
```
┌─────────────────────────────────────┐
│ ○ 20% Discount              [✓]    │ ← Radio button + Selected
│   Get 20% off on next ride         │
│   Valid until: 25/12/2025          │
│   ─────────────────────────────    │
│   [Apply Coupon] ← New Button      │
└─────────────────────────────────────┘
```

### ConfirmRideView Updates
```
┌─────────────────────────────────────┐
│  Price Details                      │
│  ─────────────────────────────────  │
│  Original Price:        $25.00      │
│  Discount (20%):        -$5.00 🎉   │
│  ─────────────────────────────────  │
│  Total:                 $20.00      │
│                                     │
│  ✓ Coupon Applied: 20% Discount    │
│  [Remove Coupon]                    │
│                                     │
│  OR                                 │
│                                     │
│  [Apply Coupon] ← If no coupon     │
└─────────────────────────────────────┘
```

---

## 🎨 Visual Flow Diagram

```
┌──────────────┐
│   HomeView   │
└──────┬───────┘
       │
       ├─→ [Search Destination]
       │
┌──────▼────────────┐
│ SearchPlacesView  │
│ • Select From     │
│ • Select To       │
└──────┬────────────┘
       │
       ├─→ [Confirm Ride]
       │
┌──────▼────────────┐
│ ConfirmRideView   │
│ • Show Price      │
│ • [Apply Coupon]  │←──┐
└──────┬────────────┘   │
       │                 │
       ├─→ [Apply Coupon]│
       │                 │
┌──────▼────────────┐   │
│  CouponsView      │   │
│ • Select Coupon   │   │
│ • [Apply] ────────────┘
└───────────────────┘
       │
       ├─→ [Confirm with Discount]
       │
┌──────▼────────────┐
│ RideAcceptTrack   │
│ • Wait for Driver │
└──────┬────────────┘
       │
┌──────▼────────────┐
│ TripTracking      │
│ • Ride In Progress│
└──────┬────────────┘
       │
       ├─→ [Ride Completed]
       │   • Deactivate Coupon ✓
       │
┌──────▼────────────┐
│   RatingView      │
└───────────────────┘
```

---

## 🔐 Security Considerations

1. **Validate coupon on backend** before applying discount
2. **Check coupon ownership** (user_id matches or coupon_for = 'all')
3. **Verify coupon not already used** (active = true)
4. **Check expiration date** before applying
5. **Log coupon usage** for audit trail
6. **Prevent multiple simultaneous uses** of same coupon

---

## 📈 Future Enhancements

1. **Coupon Stacking** - Allow multiple coupons (if business logic permits)
2. **Referral Coupons** - Auto-generate when user refers friend
3. **Time-Limited Flash Sales** - Special coupons valid for 1 hour
4. **First Ride Bonus** - Auto-apply for new users
5. **Loyalty Program** - Earn coupons after X rides
6. **Push Notifications** - Alert users of expiring coupons
7. **Coupon History** - Show all previously used coupons
8. **Promo Code Entry** - Allow users to enter codes manually

---

## ✅ Success Criteria

The coupon system is complete when:

- ✅ User can browse and select coupons
- ✅ Selected coupon applies discount to ride price
- ✅ Discount displays correctly in UI
- ✅ Coupon info saves with ride request
- ✅ Coupon deactivates automatically after ride completion
- ✅ User cannot reuse deactivated coupons
- ✅ All edge cases handled gracefully
- ✅ No bugs or crashes in production

---

## 📞 Support & Questions

For implementation questions or clarifications:
- Review this document
- Check existing code structure
- Test incrementally
- Document any deviations from plan

---

**Document Version:** 1.0  
**Created:** November 26, 2025  
**Status:** Planning Phase  
**Next Action:** Review plan → Start Phase 1 implementation
