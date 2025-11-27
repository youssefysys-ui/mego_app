import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';

class CouponDiscountWidget extends StatelessWidget {
  final double originalPrice;
  final double discount;
  final double finalPrice;
  final String couponType;

  const CouponDiscountWidget({
    super.key,
    required this.originalPrice,
    required this.discount,
    required this.finalPrice,
    required this.couponType,
  });

  String _getCouponLabel() {
    switch (couponType) {
      case 'DISCOUNT_10':
        return '10% OFF';
      case 'DISCOUNT_20':
        return '20% OFF';
      case 'DISCOUNT_25':
        return '25% OFF';
      case 'DISCOUNT_50':
        return '50% OFF';
      case 'FLAT_50':
        return 'EGP 50 OFF';
      case 'FLAT_100':
        return 'EGP 100 OFF';
      case 'FREE_RIDE':
        return 'FREE RIDE';
      default:
        return 'DISCOUNT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coupon Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCouponLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price Information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Original Price (Strikethrough)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Original Price',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EGP ${originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.red,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
              
              // Discount Arrow
              Icon(
                Icons.arrow_forward,
                color: Colors.green.shade700,
                size: 24,
              ),
              
              // Final Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'You Pay',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EGP ${finalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Savings Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.savings_outlined,
                  color: Colors.green.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'You save EGP ${discount.toStringAsFixed(2)} on this ride',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '🎉',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
