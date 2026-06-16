import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final String? value;

  const OTPInput({
    super.key,
    this.length = 4,
    required this.onChanged,
    this.hasError = false,
    this.value,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          setState(() {
            _focusedIndex = index;
          });
        }
      });
      return node;
    });

    if (widget.value != null && widget.value!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fillOtp(widget.value!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(OTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != oldWidget.value) {
      _fillOtp(widget.value!);
    }
  }

  void _fillOtp(String otp) {
    for (int i = 0; i < widget.length; i++) {
      if (i < otp.length) {
        _controllers[i].text = otp[i];
      } else {
        _controllers[i].clear();
      }
    }
    if (otp.isNotEmpty) {
      if (otp.length < widget.length) {
        _focusNodes[otp.length].requestFocus();
      } else {
        // Full OTP filled, dismiss keyboard focus
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChange(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    
    final fullOtp = _controllers.map((c) => c.text).join();
    widget.onChanged(fullOtp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        return Focus(
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_controllers[index].text.isEmpty && index > 0) {
                _controllers[index - 1].clear();
                _focusNodes[index - 1].requestFocus();
                final fullOtp = _controllers.map((c) => c.text).join();
                widget.onChanged(fullOtp);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isFocused ? AppColors.bgCard : AppColors.bgCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.hasError
                    ? AppColors.danger
                    : (isFocused ? AppColors.primaryGreen : AppColors.border),
                width: isFocused ? 2.0 : 1.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: AppTextStyles.otp.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _handleChange(value, index),
            ),
          ),
        );
      }),
    );
  }
}
