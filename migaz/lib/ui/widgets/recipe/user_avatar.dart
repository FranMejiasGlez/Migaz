import 'package:flutter/material.dart';
import 'package:migaz/core/config/api_config.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final double size;

  const UserAvatar({
    Key? key,
    this.imageUrl,
    required this.onTap,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveImageUrl = (imageUrl == null || imageUrl!.isEmpty) 
        ? ApiConfig.defaultProfileImage 
        : imageUrl!;
    final fullUrl = ApiConfig.getImageUrl(effectiveImageUrl);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(fullUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
