import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/customer_profile_provider.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool isLoading;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.onTap,
    this.showEditBadge = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<CustomerProfileProvider>();
    final bytes = profile.profilePhotoBytes;
    final url = profile.profilePhotoUrl;
    ImageProvider<Object>? image;
    if (bytes != null) {
      image = MemoryImage(bytes);
    } else if (url != null) {
      image = NetworkImage(url);
    }

    return Semantics(
      button: onTap != null,
      label: showEditBadge ? 'Ubah foto profil' : 'Foto profil',
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage: image,
              child: image == null
                  ? Icon(
                      Icons.person,
                      size: radius,
                      color: Colors.green,
                    )
                  : null,
            ),
            if (showEditBadge)
              Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: radius * 0.28,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: radius * 0.22,
                    backgroundColor: Colors.green,
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
