import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/skin_theme_config.dart';
import '../services/db_service.dart';

class ShopDialog extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;

  const ShopDialog({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _currentProfile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentProfile = widget.userProfile;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _buySkin(SkinConfig skin) async {
    if (_isProcessing || _currentProfile.diamonds < skin.cost) return;
    // Prevent buying already unlocked skin
    if (_currentProfile.unlockedSkins.contains(skin.id)) return;

    setState(() => _isProcessing = true);
    try {
      final updatedSkins = List<String>.from(_currentProfile.unlockedSkins);
      // Double-check to prevent duplicate entries
      if (!updatedSkins.contains(skin.id)) {
        updatedSkins.add(skin.id);
      }
      final updatedProfile = _currentProfile.copyWith(
        diamonds: _currentProfile.diamonds - skin.cost,
        unlockedSkins: updatedSkins,
        selectedSkin: skin.id,
      );

      final success = await DbService.saveProfile(updatedProfile);
      if (!mounted) return;
      if (success) {
        setState(() {
          _currentProfile = updatedProfile;
        });
        widget.onProfileUpdated(updatedProfile);
        _showSuccessSnackBar('🎉 Mở khóa thành công Skin "${skin.name}"!');
      } else {
        _showErrorSnackBar('❌ Đã xảy ra lỗi khi mua Skin. Vui lòng thử lại!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi không xác định khi mua Skin. Vui lòng thử lại!');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _applySkin(String skinId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final updatedProfile = _currentProfile.copyWith(selectedSkin: skinId);
      
      final success = await DbService.saveProfile(updatedProfile);
      if (!mounted) return;
      if (success) {
        setState(() {
          _currentProfile = updatedProfile;
        });
        widget.onProfileUpdated(updatedProfile);
        _showSuccessSnackBar('✨ Đã áp dụng Skin quân cờ mới!');
      } else {
        _showErrorSnackBar('❌ Không thể áp dụng Skin. Vui lòng thử lại!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi không xác định. Vui lòng thử lại!');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _buyTheme(ThemeConfig theme) async {
    if (_isProcessing || _currentProfile.diamonds < theme.cost) return;
    // Prevent buying already unlocked theme
    if (_currentProfile.unlockedThemes.contains(theme.id)) return;

    setState(() => _isProcessing = true);
    try {
      final updatedThemes = List<String>.from(_currentProfile.unlockedThemes);
      // Double-check to prevent duplicate entries
      if (!updatedThemes.contains(theme.id)) {
        updatedThemes.add(theme.id);
      }
      final updatedProfile = _currentProfile.copyWith(
        diamonds: _currentProfile.diamonds - theme.cost,
        unlockedThemes: updatedThemes,
        selectedTheme: theme.id,
      );

      final success = await DbService.saveProfile(updatedProfile);
      if (!mounted) return;
      if (success) {
        setState(() {
          _currentProfile = updatedProfile;
        });
        widget.onProfileUpdated(updatedProfile);
        _showSuccessSnackBar('🎉 Mở khóa thành công Theme "${theme.name}"!');
      } else {
        _showErrorSnackBar('❌ Đã xảy ra lỗi khi mua Theme. Vui lòng thử lại!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi không xác định khi mua Theme. Vui lòng thử lại!');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _applyTheme(String themeId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final updatedProfile = _currentProfile.copyWith(selectedTheme: themeId);
      
      final success = await DbService.saveProfile(updatedProfile);
      if (!mounted) return;
      if (success) {
        setState(() {
          _currentProfile = updatedProfile;
        });
        widget.onProfileUpdated(updatedProfile);
        _showSuccessSnackBar('✨ Đã áp dụng giao diện bàn cờ mới!');
      } else {
        _showErrorSnackBar('❌ Không thể áp dụng Theme. Vui lòng thử lại!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi không xác định. Vui lòng thử lại!');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      elevation: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F2FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Color(0xFF00F2FE),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'CỬA HÀNG CARO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  // Diamonds badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00F2FE).withOpacity(0.2),
                          const Color(0xFF00F2FE).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '💎 ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${_currentProfile.diamonds}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00F2FE),
                labelColor: const Color(0xFF00F2FE),
                unselectedLabelColor: Colors.white60,
                dividerColor: Colors.white.withOpacity(0.08),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'SKIN QUÂN CỜ', icon: Icon(Icons.grid_4x4_rounded, size: 20)),
                  Tab(text: 'THEME BÀN CỜ', icon: Icon(Icons.palette_outlined, size: 20)),
                ],
              ),
              
              // Tab contents
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSkinsTab(),
                      _buildThemesTab(),
                    ],
                  ),
                ),
              ),
              
              // Close button
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.06),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  elevation: 0,
                ),
                child: const Text('ĐÓNG CỬA HÀNG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinsTab() {
    return ListView.builder(
      itemCount: SkinConfig.allSkins.length,
      itemBuilder: (context, index) {
        final skin = SkinConfig.allSkins[index];
        final isUnlocked = _currentProfile.unlockedSkins.contains(skin.id);
        final isActive = _currentProfile.selectedSkin == skin.id;
        final canAfford = _currentProfile.diamonds >= skin.cost;

        return _buildShopItemCard(
          emoji: skin.emoji,
          name: skin.name,
          cost: skin.cost,
          isUnlocked: isUnlocked,
          isActive: isActive,
          canAfford: canAfford,
          onApply: () => _applySkin(skin.id),
          onBuy: () => _buySkin(skin),
          previewWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'X',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: skin.xColor,
                  shadows: skin.xShadow,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'O',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: skin.oColor,
                  shadows: skin.oShadow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemesTab() {
    return ListView.builder(
      itemCount: ThemeConfig.allThemes.length,
      itemBuilder: (context, index) {
        final theme = ThemeConfig.allThemes[index];
        final isUnlocked = _currentProfile.unlockedThemes.contains(theme.id);
        final isActive = _currentProfile.selectedTheme == theme.id;
        final canAfford = _currentProfile.diamonds >= theme.cost;

        return _buildShopItemCard(
          emoji: theme.emoji,
          name: theme.name,
          cost: theme.cost,
          isUnlocked: isUnlocked,
          isActive: isActive,
          canAfford: canAfford,
          onApply: () => _applyTheme(theme.id),
          onBuy: () => _buyTheme(theme),
          previewWidget: Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: theme.bgGradient),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.boardBorderColor, width: 1.5),
            ),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              padding: const EdgeInsets.all(2),
              children: List.generate(6, (i) {
                return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: theme.boardBg,
                    border: Border.all(color: theme.gridLineColor, width: 0.3),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopItemCard({
    required String emoji,
    required String name,
    required int cost,
    required bool isUnlocked,
    required bool isActive,
    required bool canAfford,
    required VoidCallback onApply,
    required VoidCallback onBuy,
    required Widget previewWidget,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.02),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive 
              ? const Color(0xFF00F2FE).withOpacity(0.4) 
              : Colors.white.withOpacity(0.06),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Emoji/Icon representing item
            Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 14),
            
            // Name and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  previewWidget,
                ],
              ),
            ),
            
            // Action button
            const SizedBox(width: 8),
            _buildActionButton(
              isUnlocked: isUnlocked,
              isActive: isActive,
              cost: cost,
              canAfford: canAfford,
              onApply: onApply,
              onBuy: onBuy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required bool isUnlocked,
    required bool isActive,
    required int cost,
    required bool canAfford,
    required VoidCallback onApply,
    required VoidCallback onBuy,
  }) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00F2FE).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00F2FE), size: 14),
            SizedBox(width: 4),
            Text(
              'Đang dùng',
              style: TextStyle(
                color: Color(0xFF00F2FE),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isUnlocked) {
      return ElevatedButton(
        onPressed: _isProcessing ? null : onApply,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.08),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
        ),
        child: const Text('Áp dụng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }

    // Must buy
    return ElevatedButton(
      onPressed: (_isProcessing || !canAfford) ? null : onBuy,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB300),
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.white.withOpacity(0.04),
        disabledForegroundColor: Colors.white24,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎 ', style: TextStyle(fontSize: 12)),
          Text(
            '$cost',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
