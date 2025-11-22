import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/account.dart';
import '/ui/account/edit_profile_screen.dart';
import '/ui/account/account_manager.dart';
import '/ui/auth/auth_manager.dart';
import '../notifications/notification_settings_dialog.dart';
import '../shared/theme_settings_dialog.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountManager = Provider.of<AccountManager>(context);
    final account = accountManager.account;

    if (accountManager.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (account == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin tài khoản')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context, account),
              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 20),
              
              // Settings Section
              _buildSettingsSection(context),
              const SizedBox(height: 20),

              // Logout Section
              _buildLogoutSection(context),
              const SizedBox(height: 20),
              
              // Version Info
              _buildVersionInfo(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Account account) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.15), // Purple
            const Color(0xFF764ba2).withOpacity(0.15), // Deep purple
            const Color(0xFFf093fb).withOpacity(0.15), // Pink
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        account.initials ?? 'NA',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Verified Badge
                  if (account.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF11998e).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Đã xác thực',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Edit Profile Button
              Container(
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Chỉnh sửa thông tin',
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(account: account),
                      ),
                    );
                    if (result != null && result is Account) {
                      context.read<AccountManager>().updateAccount(result);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            account.fullName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Phone
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  account.phone.isNotEmpty ? account.phone : 'Chưa cập nhật SĐT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              Icons.account_balance_wallet_rounded,
              'Quản lý\nchi tiêu',
              [const Color(0xFF667eea), const Color(0xFF764ba2)],
            ),
            _buildActionButton(
              context,
              Icons.credit_card_rounded,
              'Cài đặt\nthanh toán',
              [const Color(0xFFee0979), const Color(0xFFff6a00)],
            ),
            _buildActionButton(
              context,
              Icons.security_rounded,
              'Đăng nhập\nvà bảo mật',
              [const Color(0xFF11998e), const Color(0xFF38ef7d)],
            ),
            _buildActionButton(
              context,
              Icons.notifications_rounded,
              'Cài đặt\nthông báo',
              [const Color(0xFFf093fb), const Color(0xFFee0979)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, List<Color> gradientColors) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingItem(
              context,
              Icons.help_center_rounded,
              'Trung tâm trợ giúp',
              colorScheme.onSurfaceVariant,
            ),
            _buildDivider(context),
            _buildSettingItem(
              context,
              Icons.notifications_rounded,
              'Cài đặt thông báo',
              colorScheme.onSurfaceVariant,
              onTap: () => _showSpendingSettingsDialog(context),
            ),
            _buildDivider(context),
            _buildSettingItem(
              context,
              Icons.share_rounded,
              'Chia sẻ góp ý',
              colorScheme.onSurfaceVariant,
            ),
            _buildDivider(context),
            _buildSettingItem(
              context,
              Icons.info_rounded,
              'Thông tin chung',
              colorScheme.onSurfaceVariant,
            ),
            _buildDivider(context),
            _buildSettingItem(
              context,
              Icons.palette_rounded,
              'Giao diện & Màu sắc', 
              colorScheme.onSurfaceVariant,
              onTap: () => showDialog(
                context: context,
                builder: (context) => const ThemeSettingsDialog(),
              ),
            ),
            _buildDivider(context),
            _buildLanguageItem(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, Color iconColor,
      {VoidCallback? onTap, Widget? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            size: 24,
          ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.language_rounded, color: colorScheme.onSurfaceVariant, size: 22),
      ),
      title: Text(
        'Ngôn ngữ',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'VI',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          context.read<AuthManager>().logout();
          context.go('/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainer,
          foregroundColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colorScheme.error.withOpacity(0.2)),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.verified_user_rounded, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'An toàn tài sản & Bảo mật thông tin của bạn',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showSpendingSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationSettingsDialog(),
    );
  }
}
