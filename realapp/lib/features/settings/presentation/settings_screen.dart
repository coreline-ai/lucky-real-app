import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../notifications/application/notification_scheduler.dart';
import '../../shared/tab_background.dart';

/// 설정 (Phase 3 범위: 출생정보 수정 진입, 데이터 삭제, 고지).
/// 닉네임 변경·해석 톤 등 나머지는 Phase 5에서 완성한다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _corelineAiLicenseText = '''
Coreline-ai 라이센스

MIT License 수준으로 제공됩니다.

Copyright (c) 2026 Coreline-ai

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

문의: Coreline-ai
''';

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Text('출생 정보, 기록, 카드가 이 기기에서 모두 삭제돼요. 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(notificationSchedulerProvider).cancelAll();
    await ref.read(profileRepositoryProvider).deleteAllData();
    ref.invalidate(activeBirthProfileProvider);
    if (context.mounted) context.go(RoutePaths.home);
  }

  Future<void> _changeNickname(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(profileRepositoryProvider);
    final profile = await repository.getActiveBirthProfile();
    if (!context.mounted) return;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 변경은 출생 정보 입력 후 사용할 수 있어요.')),
      );
      return;
    }

    final controller = TextEditingController(text: profile.displayName);
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (nickname == null || nickname.isEmpty) return;

    await repository.updateNickname(nickname);
    ref.invalidate(activeBirthProfileProvider);
  }

  Future<void> _showLicense(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coreline-ai 라이센스'),
        content: const SingleChildScrollView(
          child: SelectableText(_corelineAiLicenseText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref
        .watch(activeBirthProfileProvider)
        .maybeWhen(data: (profile) => profile != null, orElse: () => false);
    final birthProfileTitle = hasProfile ? '출생 정보 수정' : '출생 정보 입력';
    final birthProfileSubtitle = hasProfile
        ? '수정하면 오늘 결과가 다시 계산돼요. 지난 기록은 그대로 남아요.'
        : '입력하면 오늘의 수호신과 루틴을 볼 수 있어요.';

    return TabBackground(
      imagePath: AssetPaths.settingsBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('설정')),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('닉네임 변경'),
              onTap: () => _changeNickname(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('기록 캘린더'),
              onTap: () => context.push(RoutePaths.history),
            ),
            const _NotificationSection(),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: Text(birthProfileTitle),
              subtitle: Text(birthProfileSubtitle),
              onTap: () => context.push(RoutePaths.onboardingForm),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('내 데이터 삭제'),
              onTap: () => _confirmDeleteAll(context, ref),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('안내'),
              subtitle: Text(
                '오행가디언즈의 운세와 수호신은 오락과 자기성찰을 위한 콘텐츠예요. '
                '의료, 투자, 법률 등 중요한 결정의 근거로 사용하지 마세요. '
                '모든 정보는 이 기기에만 저장돼요.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('라이센스'),
              subtitle: const Text('Coreline-ai 라이센스 · MIT License 수준'),
              onTap: () => _showLicense(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 알림 관리 (02): 종류별 on/off + 시간 변경, 완전 비활성화 가능.
class _NotificationSection extends ConsumerStatefulWidget {
  const _NotificationSection();

  @override
  ConsumerState<_NotificationSection> createState() =>
      _NotificationSectionState();
}

class _NotificationSectionState extends ConsumerState<_NotificationSection> {
  static const _labels = {
    AppNotificationType.morningGuardian: '아침 수호신 알림',
    AppNotificationType.eveningRoutine: '저녁 루틴 리마인드',
    AppNotificationType.cardUnclaimed: '카드 보상 미수령 알림',
  };

  Future<void> _toggle(AppNotificationType type, bool enabled) async {
    final scheduler = ref.read(notificationSchedulerProvider);
    if (enabled) {
      final granted = await scheduler.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기기 설정에서 알림 권한을 허용해 주세요.')),
          );
        }
        return;
      }
    }
    await scheduler.update(type, enabled: enabled);
    setState(() {});
  }

  Future<void> _changeTime(
    AppNotificationType type,
    int hour,
    int minute,
    bool enabled,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked == null) return;
    await ref
        .read(notificationSchedulerProvider)
        .update(
          type,
          enabled: enabled,
          hour: picked.hour,
          minute: picked.minute,
        );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(notificationSchedulerProvider).settings(),
      builder: (context, snapshot) {
        final settings = snapshot.data;
        if (settings == null) return const SizedBox.shrink();
        return Column(
          children: [
            const Divider(),
            const ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('알림 관리'),
            ),
            for (final type in AppNotificationType.values)
              Builder(
                builder: (context) {
                  final setting = settings.firstWhere(
                    (s) => s.type == type.key,
                  );
                  return SwitchListTile(
                    title: Text(_labels[type]!),
                    subtitle: Text(
                      '${setting.hour.toString().padLeft(2, '0')}:'
                      '${setting.minute.toString().padLeft(2, '0')} · 눌러서 시간 변경',
                    ),
                    value: setting.enabled,
                    onChanged: (value) => _toggle(type, value),
                    secondary: IconButton(
                      icon: const Icon(Icons.schedule),
                      tooltip: '시간 변경',
                      onPressed: () => _changeTime(
                        type,
                        setting.hour,
                        setting.minute,
                        setting.enabled,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
