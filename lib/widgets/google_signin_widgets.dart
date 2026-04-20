// lib/widgets/google_signin_widgets.dart
// Reusable widgets for Google Sign-In functionality

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/models.dart';

// ============================================
// GOOGLE AVATAR DISPLAY
// ============================================
class GoogleAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final VoidCallback? onTap;

  const GoogleAvatar({
    super.key,
    required this.user,
    this.size = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.displayAvatar;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: avatarUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _defaultAvatar();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _loadingAvatar();
                  },
                ),
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          user.name.isEmpty
              ? 'U'
              : user.name.substring(0, 1).toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _loadingAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.2),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}

// ============================================
// GOOGLE SIGN-IN BADGE
// ============================================
class GoogleSignInBadge extends StatelessWidget {
  final bool isGoogleSignedIn;
  final double size;

  const GoogleSignInBadge({
    super.key,
    required this.isGoogleSignedIn,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isGoogleSignedIn) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        Icons.check_circle,
        size: size,
        color: AppColors.success,
      ),
    );
  }
}

// ============================================
// PROFILE HEADER WITH GOOGLE AVATAR
// ============================================
class GoogleProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLogout;

  const GoogleProfileHeader({
    super.key,
    required this.user,
    this.onEditProfile,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Avatar with badge
          Stack(
            children: [
              GoogleAvatar(user: user, size: 100),
              Positioned(
                bottom: 0,
                right: 0,
                child: GoogleSignInBadge(
                  isGoogleSignedIn: user.googleAvatar != null,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User info
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (user.role.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (onEditProfile != null || onLogout != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onEditProfile != null)
                  ElevatedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (onEditProfile != null && onLogout != null)
                  const SizedBox(width: 12),
                if (onLogout != null)
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                    ),
                    icon: const Icon(Icons.logout_outlined, size: 18, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================
// GOOGLE SIGN-IN INFO CARD
// ============================================
class GoogleSignInInfo extends StatelessWidget {
  final UserModel user;
  final bool isEmailVerified;

  const GoogleSignInInfo({
    super.key,
    required this.user,
    this.isEmailVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    if (user.googleAvatar == null || user.googleAvatar!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in with Google',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your account is verified and secured',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SECURITY INFO SECTION
// ============================================
class GoogleSecurityInfo extends StatelessWidget {
  final UserModel user;

  const GoogleSecurityInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Security',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _SecurityItem(
                icon: Icons.verified_user,
                title: 'Email Verification',
                value: user.isEmailVerified ? 'Verified' : 'Pending',
                isVerified: user.isEmailVerified,
              ),
              const Divider(height: 20),
              _SecurityItem(
                icon: Icons.vpn_lock_outlined,
                title: 'Authentication Method',
                value: user.googleAvatar != null ? 'Google OAuth 2.0' : 'Password',
                isVerified: user.googleAvatar != null,
              ),
              const Divider(height: 20),
              _SecurityItem(
                icon: Icons.person_outline,
                title: 'Account Type',
                value: user.role.toUpperCase(),
                isVerified: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isVerified;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isVerified)
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
      ],
    );
  }
}
