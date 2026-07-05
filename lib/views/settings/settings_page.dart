import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _units = 'Metric'; // Metric or Imperial

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: PawsBaseTokens.surface,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Account"),
            const SizedBox(height: 12),
            _buildAccountCard(colorScheme),
            const SizedBox(height: 32),
            _buildSectionHeader("App Settings"),
            const SizedBox(height: 12),
            _buildAppSettingsCard(colorScheme),
            const SizedBox(height: 32),
            _buildSectionHeader("Support"),
            const SizedBox(height: 12),
            _buildSupportCard(colorScheme),
            const SizedBox(height: 48),
            _buildLogoutButton(colorScheme),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: PawsBaseTokens.neutral,
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required List<Widget> children,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountCard(ColorScheme colorScheme) {
    final greenBg = PawsBaseTokens.primary.withValues(alpha: 0.2);
    final greenIcon = PawsBaseTokens.primaryDark;

    return _buildCardContainer(
      colorScheme: colorScheme,
      children: [
        _buildSettingRow(
          icon: Icons.account_circle_outlined,
          iconBgColor: greenBg,
          iconColor: greenIcon,
          title: "Profile Information",
          colorScheme: colorScheme,
          onTap: () {
            // Profile Information tap action
          },
        ),
        _buildDivider(colorScheme),
        _buildSettingRow(
          icon: Icons.lock_outline_rounded,
          iconBgColor: greenBg,
          iconColor: greenIcon,
          title: "Security",
          colorScheme: colorScheme,
          onTap: () {
            // Security tap action
          },
        ),
      ],
    );
  }

  Widget _buildAppSettingsCard(ColorScheme colorScheme) {
    final beigeBg = PawsBaseTokens.secondary.withValues(alpha: 0.3);
    final brownIcon = PawsBaseTokens.secondaryDark;

    return _buildCardContainer(
      colorScheme: colorScheme,
      children: [
        _buildSettingRow(
          icon: Icons.notifications_none_rounded,
          iconBgColor: beigeBg,
          iconColor: brownIcon,
          title: "Notifications",
          colorScheme: colorScheme,
          onTap: () {
            // Notifications tap action
          },
        ),
        _buildDivider(colorScheme),
        _buildSettingRow(
          icon: Icons.straighten_outlined,
          iconBgColor: beigeBg,
          iconColor: brownIcon,
          title: "Units",
          colorScheme: colorScheme,
          trailing: PopupMenuButton<String>(
            initialValue: _units,
            onSelected: (String newValue) {
              setState(() {
                _units = newValue;
              });
            },
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _units,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Metric',
                child: Text('Metric'),
              ),
              const PopupMenuItem<String>(
                value: 'Imperial',
                child: Text('Imperial'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(ColorScheme colorScheme) {
    final greyBg = PawsBaseTokens.neutral.withValues(alpha: 0.15);
    final greyIcon = PawsBaseTokens.neutral;

    return _buildCardContainer(
      colorScheme: colorScheme,
      children: [
        _buildSettingRow(
          icon: Icons.help_outline_rounded,
          iconBgColor: greyBg,
          iconColor: greyIcon,
          title: "Help Center",
          colorScheme: colorScheme,
          onTap: () {
            // Help Center tap action
          },
        ),
        _buildDivider(colorScheme),
        _buildSettingRow(
          icon: Icons.admin_panel_settings_outlined,
          iconBgColor: greyBg,
          iconColor: greyIcon,
          title: "Privacy Policy",
          colorScheme: colorScheme,
          onTap: () {
            // Privacy Policy tap action
          },
        ),
        _buildDivider(colorScheme),
        _buildSettingRow(
          icon: Icons.info_outline_rounded,
          iconBgColor: greyBg,
          iconColor: greyIcon,
          title: "About PawsBase",
          colorScheme: colorScheme,
          onTap: () {
            // About PawsBase tap action
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    final logoutBg = colorScheme.brightness == Brightness.dark
        ? colorScheme.error.withValues(alpha: 0.15)
        : const Color(0xFFFEECEB);

    return Center(
      child: InkWell(
        onTap: () {
          // Log out action
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: logoutBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: colorScheme.error, size: 18),
              const SizedBox(width: 8),
              Text(
                "Log Out",
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required ColorScheme colorScheme,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                size: 24,
              ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: rowContent,
      );
    }

    return rowContent;
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: colorScheme.outline.withValues(alpha: 0.08),
    );
  }
}
