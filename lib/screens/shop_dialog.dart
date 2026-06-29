import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/skin_theme_config.dart';
import '../models/emote_config.dart';
import '../services/db_service.dart';
import '../app_language.dart';

class ShopDialog extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;
  final AppLanguage language;

  const ShopDialog({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
    required this.language,
  });

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _currentProfile;
  bool _isProcessing = false;

  AppText get _text => AppText(widget.language);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        _showSuccessSnackBar(_text.unlockedSkin(skin.displayName(widget.language)));
      } else {
        _showErrorSnackBar(_text.buySkinFailed);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_text.buySkinUnknown);
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
        _showSuccessSnackBar(_text.applySkinSuccess);
      } else {
        _showErrorSnackBar(_text.applySkinFailed);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_text.unknownErrorRetry);
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
        _showSuccessSnackBar(_text.unlockedTheme(theme.displayName(widget.language)));
      } else {
        _showErrorSnackBar(_text.buyThemeFailed);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_text.buyThemeUnknown);
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
        _showSuccessSnackBar(_text.applyThemeSuccess);
      } else {
        _showErrorSnackBar(_text.applyThemeFailed);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_text.unknownErrorRetry);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _buyEmote(EmoteConfig emote) async {
    if (_isProcessing || _currentProfile.diamonds < emote.cost) return;
    if (_currentProfile.unlockedEmotes.contains(emote.id)) return;

    setState(() => _isProcessing = true);
    try {
      final updated = List<String>.from(_currentProfile.unlockedEmotes);
      if (!updated.contains(emote.id)) updated.add(emote.id);
      final updatedProfile = _currentProfile.copyWith(
        diamonds: _currentProfile.diamonds - emote.cost,
        unlockedEmotes: updated,
      );

      final success = await DbService.saveProfile(updatedProfile);
      if (!mounted) return;
      if (success) {
        setState(() => _currentProfile = updatedProfile);
        widget.onProfileUpdated(updatedProfile);
        _showSuccessSnackBar(_text.emoteUnlocked);
      } else {
        _showErrorSnackBar(_text.emoteBuyFailed);
      }
    } catch (_) {
      if (mounted) _showErrorSnackBar(_text.emoteBuyFailed);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
                      Text(
                        _text.shopTitle,
                        style: const TextStyle(
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
                tabs: [
                  Tab(text: _text.skinsTab, icon: const Icon(Icons.grid_4x4_rounded, size: 20)),
                  Tab(text: _text.themesTab, icon: const Icon(Icons.palette_outlined, size: 20)),
                  Tab(text: _text.emotesTab, icon: const Icon(Icons.emoji_emotions_outlined, size: 20)),
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
                      _buildEmotesTab(),
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
                child: Text(_text.closeShop, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
          name: skin.displayName(widget.language),
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
          name: theme.displayName(widget.language),
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

  Widget _buildEmotesTab() {
    final lang = widget.language;
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: EmoteConfig.allEmotes.map((emote) {
        final owned = _currentProfile.unlockedEmotes.contains(emote.id);
        final canAfford = _currentProfile.diamonds >= emote.cost;
        return GestureDetector(
          onTap: owned || emote.cost == 0
              ? null
              : (canAfford ? () => _buyEmote(emote) : null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: owned
                  ? const Color(0xFF00F2FE).withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: owned
                    ? const Color(0xFF00F2FE).withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emote.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                if (!owned && emote.cost > 0)
                  Text(
                    '${emote.cost} 💎',
                    style: TextStyle(
                      fontSize: 10,
                      color: canAfford ? const Color(0xFF00F2FE) : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    owned ? (lang == AppLanguage.vi ? 'Có sẵn' : 'Owned') : '🔒',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00F2FE), size: 14),
            const SizedBox(width: 4),
            Text(
              _text.active,
              style: const TextStyle(
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
        child: Text(_text.apply, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
