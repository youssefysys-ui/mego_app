import 'package:get/get.dart';
import 'package:mego_app/core/res/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_model.dart';

class WalletController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<WalletModel?> wallet = Rx<WalletModel?>(null);
  final RxList<WalletTransactionModel> transactions = <WalletTransactionModel>[].obs;

  late final SupabaseClient _supabase;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    loadWallet();
  }

  /// Load user wallet - create with 100 EUR if doesn't exist
  Future<void> loadWallet() async {
    if (currentUserId == null) {
      errorMessage.value = 'Please login to view your wallet';
      print('⚠️ No current user ID found');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 Fetching wallet for user: $currentUserId');

      // Try to fetch existing wallet
      final response = await _supabase
          .from('wallet')
          .select()
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (response != null) {
        // Wallet exists
        wallet.value = WalletModel.fromJson(response);
        print('✅ Wallet loaded: Total = ${wallet.value!.total} EUR');
      } else {
        // Wallet doesn't exist - create with 100 EUR
        print('⚠️ No wallet found, creating new wallet with 100 EUR...');
        await _createWallet();
      }

      // Load transactions
      await loadTransactions();

    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load wallet: $e';
      print('❌ Error loading wallet: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new wallet with initial 100 EUR balance
  Future<void> _createWallet() async {
    try {
      final walletData = {
        'user_id': currentUserId,
        'total': 100.0,
      };

      final response = await _supabase
          .from('wallet')
          .insert(walletData)
          .select()
          .single();

      wallet.value = WalletModel.fromJson(response);
      
      print('✅ Wallet created successfully with 100 EUR');
      print('Wallet ID: ${wallet.value!.id}');

      // Create initial transaction record
      await _createTransaction(
        type: 'credit',
        amount: 100.0,
        description: 'Welcome bonus - Initial wallet credit',
      );

    } catch (e) {
      print('❌ Error creating wallet: $e');
      throw Exception('Failed to create wallet: $e');
    }
  }

  /// Load wallet transactions
  Future<void> loadTransactions() async {
    if (wallet.value == null) return;

    try {
      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', wallet.value!.id)
          .order('created_at', ascending: false)
          .limit(50);

      transactions.value = (response as List)
          .map((json) => WalletTransactionModel.fromJson(json))
          .toList();

      print('✅ Loaded ${transactions.length} transactions');

    } catch (e) {
      print('❌ Error loading transactions: $e');
    }
  }

  /// Add money to wallet
  Future<bool> addMoney(double amount, String description) async {
    if (wallet.value == null) return false;

    try {
      isLoading.value = true;

      final newTotal = wallet.value!.total + amount;

      // Update wallet total
      await _supabase
          .from('wallets')
          .update({
            'total': newTotal,
          })
          .eq('id', wallet.value!.id);

      // Create transaction record
      await _createTransaction(
        type: 'credit',
        amount: amount,
        description: description,
      );

      // Update local wallet
      wallet.value = wallet.value!.copyWith(
        total: newTotal,
      );

      print('✅ Added $amount EUR to wallet. New total: $newTotal EUR');

      await loadTransactions();
      
      return true;

    } catch (e) {
      print('❌ Error adding money: $e');
      errorMessage.value = 'Failed to add money: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deduct money from wallet
  Future<bool> deductMoney(double amount, String description, {String? referenceId}) async {
    if (wallet.value == null) return false;

    if (wallet.value!.total < amount) {
      errorMessage.value = 'Insufficient balance';
      print('❌ Insufficient balance. Required: $amount EUR, Available: ${wallet.value!.total} EUR');
      return false;
    }

    try {
      isLoading.value = true;

      final newTotal = wallet.value!.total - amount;

      // Update wallet total
      await _supabase
          .from('wallet')
          .update({
            'total': newTotal,
          })
          .eq('id', wallet.value!.id);

      // Create transaction record
      await _createTransaction(
        type: 'debit',
        amount: amount,
        description: description,
        referenceId: referenceId,
      );

      // Update local wallet
      wallet.value = wallet.value!.copyWith(
        total: newTotal,
      );

      print('✅ Deducted $amount EUR from wallet. New total: $newTotal EUR');

      await loadTransactions();
      
      return true;

    } catch (e) {
      print('❌ Error deducting money: $e');
      errorMessage.value = 'Failed to deduct money: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create transaction record
  Future<void> _createTransaction({
    required String type,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final transactionData = {
        'wallet_id': wallet.value!.id,
        'type': type,
        'amount': amount,
        'description': description,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('wallet_transactions')
          .insert(transactionData);

      print('✅ Transaction recorded: $type $amount EUR');

    } catch (e) {
      print('❌ Error creating transaction: $e');
    }
  }

  /// Refresh wallet data
  Future<void> refreshWallet() async {
    await loadWallet();
  }

  /// Get formatted balance
  String get formattedBalance {
    if (wallet.value == null) return '0.00 '+currency;
    return '${wallet.value!.total.toStringAsFixed(2)} '+currency;
  }

  /// Check if user has sufficient balance
  bool hasSufficientBalance(double amount) {
    if (wallet.value == null) return false;
    return wallet.value!.total >= amount;
  }
}
