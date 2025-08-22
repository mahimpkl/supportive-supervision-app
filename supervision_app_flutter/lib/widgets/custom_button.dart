import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final IconData? icon;
  final String variant; // 'filled', 'outline', 'text'
  final Color? color;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.variant = 'filled',
    this.color,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    final isDisabled = onPressed == null || isLoading;

    switch (variant) {
      case 'outline':
        return _buildOutlineButton(context, primaryColor, isDisabled);
      case 'text':
        return _buildTextButton(context, primaryColor, isDisabled);
      default:
        return _buildFilledButton(context, primaryColor, isDisabled);
    }
  }

  Widget _buildFilledButton(BuildContext context, Color primaryColor, bool isDisabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[300] : primaryColor,
          foregroundColor: Colors.white,
          elevation: isDisabled ? 0 : 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _buildButtonContent(context, Colors.white, isDisabled),
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context, Color primaryColor, bool isDisabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDisabled ? Colors.grey[400] : primaryColor,
          side: BorderSide(
            color: isDisabled ? Colors.grey[300]! : primaryColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _buildButtonContent(
          context,
          isDisabled ? Colors.grey[400]! : primaryColor,
          isDisabled,
        ),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, Color primaryColor, bool isDisabled) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isDisabled ? Colors.grey[400] : primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _buildButtonContent(
          context,
          isDisabled ? Colors.grey[400]! : primaryColor,
          isDisabled,
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color textColor, bool isDisabled) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}