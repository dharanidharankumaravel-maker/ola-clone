import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/primary_button.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _selectedAmount = 500;
  bool _isTopping = false;
  final List<int> _topupOptions = [100, 250, 500, 1000];

  void _handleTopup() async {
    setState(() => _isTopping = true);
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isTopping = false);
      
      final user = ref.read(authProvider).value;
      if (user != null) {
        ref.read(authProvider.notifier).updateUser(
          user.copyWith(walletBalance: user.walletBalance + _selectedAmount),
        );
      }
      
      ref.read(walletTransactionProvider.notifier).addTransaction(
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          amount: _selectedAmount.toDouble(),
          type: 'topup',
          description: 'Added to wallet',
          createdAt: DateTime.now(),
        )
      );
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Top-up Successful'),
          content: Text('₹$_selectedAmount added to your wallet!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final balance = user?.walletBalance ?? 500.0; // using 500.0 if not logged in just to show UI
    final transactions = ref.watch(walletTransactionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Alo Money', style: AppTextStyles.h3),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 32, color: AppColors.primaryGreen),
                        const SizedBox(height: 12),
                        Text('Alo Money Balance', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen)),
                        const SizedBox(height: 8),
                        Text('₹${balance.toStringAsFixed(0)}', style: AppTextStyles.displayTitle.copyWith(color: AppColors.primaryGreen, fontSize: 44, height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Add Money Section
                  Text('ADD MONEY', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _topupOptions.map((amt) {
                      final isSelected = _selectedAmount == amt;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAmount = amt),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreenLight : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text('₹$amt', style: AppTextStyles.bodyMedium.copyWith(color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Add ₹$_selectedAmount to Wallet',
                    onPressed: _handleTopup,
                    isLoading: _isTopping,
                  ),
                  
                  const SizedBox(height: 32),
                  Text('TRANSACTION HISTORY', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = transactions[index];
                final isCredit = tx.type == 'topup';
                final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(tx.createdAt);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCredit ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.description, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(dateStr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: transactions.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
