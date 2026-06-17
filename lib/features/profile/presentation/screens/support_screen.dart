import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Support', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.headset_mic_outlined, size: 64, color: AppColors.primaryGreen),
                const SizedBox(height: 16),
                const Text('How can we help you?', style: AppTextStyles.h2, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Find answers to your questions or get in touch with our support team.', style: AppTextStyles.body, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Common Issues', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          _FaqItem(
            title: 'I lost an item in my ride',
            answer: 'Please contact the driver directly using the call button in your ride history. If you are unable to reach them, you can contact our support team with your ride details.',
          ),
          _FaqItem(
            title: 'My driver was unprofessional',
            answer: 'We take professionalism very seriously. Please provide specific feedback in the ride history section so we can take appropriate action.',
          ),
          _FaqItem(
            title: 'I was overcharged',
            answer: 'If your final fare was higher than expected, it could be due to tolls, wait time, or route changes. If you believe there is an error, please share the ride details.',
          ),
          _FaqItem(
            title: 'Payment failed but money deducted',
            answer: 'Failed payments are usually refunded automatically within 5-7 business days. If you do not receive the refund by then, please contact your bank.',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 8),
                Text('Chat with Us', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String title;
  final String answer;

  const _FaqItem({required this.title, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.title, style: AppTextStyles.bodyMedium)),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.border),
              const SizedBox(height: 12),
              Text(widget.answer, style: AppTextStyles.body),
            ]
          ],
        ),
      ),
    );
  }
}

