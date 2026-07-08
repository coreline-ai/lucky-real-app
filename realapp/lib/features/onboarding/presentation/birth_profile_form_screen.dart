import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/result/app_failure.dart';
import '../../../core/time/app_clock.dart';
import '../../../engine/gateway/models.dart';
import '../../home/application/today_fortune_provider.dart';
import '../../shared/failure_messages.dart';
import '../../shared/tab_background.dart';

/// 출생정보 입력 (Phase 3).
/// 저장 전에 엔진 계산을 1회 실행해 지원 범위/법정시 오류를 미리 걸러낸다.
class BirthProfileFormScreen extends ConsumerStatefulWidget {
  const BirthProfileFormScreen({super.key});

  @override
  ConsumerState<BirthProfileFormScreen> createState() =>
      _BirthProfileFormScreenState();
}

class _BirthProfileFormScreenState
    extends ConsumerState<BirthProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  DateTime? _birthDate;
  bool _timeKnown = true;
  int _hour = 12;
  int _minute = 0;
  CalendarType _calendarType = CalendarType.solar;
  bool _isLeapMonth = false;
  GenderMode? _genderMode;
  bool _saving = false;
  bool _loadingInitialProfile = true;
  bool _editingExistingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialProfile());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProfile() async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .getActiveBirthProfile();
    if (!mounted) return;
    if (profile == null) {
      setState(() => _loadingInitialProfile = false);
      return;
    }

    setState(() {
      _editingExistingProfile = true;
      _loadingInitialProfile = false;
      _nicknameController.text = profile.displayName;
      _birthDate = profile.birthDate;
      _timeKnown = profile.birthTimeKnown;
      _hour = profile.birthHour ?? 12;
      _minute = profile.birthMinute ?? 0;
      _calendarType = profile.calendarType == CalendarType.lunar.name
          ? CalendarType.lunar
          : CalendarType.solar;
      _isLeapMonth = profile.isLeapMonth;
      _genderMode = switch (profile.genderMode) {
        'male' => GenderMode.male,
        'female' => GenderMode.female,
        _ => null,
      };
    });
  }

  Future<void> _pickBirthDate() async {
    final now = ref.read(appClockProvider).todayKst();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1908, 4, 1),
      lastDate: now,
      helpText: '생년월일 선택',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _showMessage('생년월일을 선택해 주세요.');
      return;
    }

    setState(() => _saving = true);
    try {
      final input = BirthInput(
        year: _birthDate!.year,
        month: _birthDate!.month,
        day: _birthDate!.day,
        hour: _timeKnown ? _hour : null,
        minute: _timeKnown ? _minute : null,
        calendarType: _calendarType,
        isLeapMonth: _calendarType == CalendarType.lunar && _isLeapMonth,
        genderMode: _genderMode,
      );

      // 저장 전 검증 계산: 오류가 있으면 저장하지 않는다 (수용 기준).
      await ref.read(engineGatewayProvider).calculateFourPillars(input);

      final now = ref.read(appClockProvider).nowKst();
      await ref
          .read(profileRepositoryProvider)
          .saveProfile(
            nickname: _nicknameController.text.trim(),
            birthDate: _birthDate!,
            birthHour: input.hour,
            birthMinute: input.minute,
            calendarType: _calendarType,
            isLeapMonth: input.isLeapMonth,
            genderMode: _genderMode,
            now: now,
          );
      await ref
          .read(profileRepositoryProvider)
          .invalidateSnapshotsFrom(ref.read(appClockProvider).todayKst());
      ref.invalidate(activeBirthProfileProvider);
      ref.invalidate(todayFortuneProvider);

      if (!mounted) return;
      if (_editingExistingProfile) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.home);
        }
      } else {
        context.go(RoutePaths.guardianReveal);
      }
    } on AppFailure catch (failure) {
      _showMessage(failureMessage(failure.code));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBack() {
    if (!_editingExistingProfile) {
      context.go(RoutePaths.onboarding);
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(
      _editingExistingProfile ? RoutePaths.settings : RoutePaths.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInitialProfile) {
      return TabBackground(
        imagePath: AssetPaths.onboardingGuardianIntro,
        scrim: TabBackgroundScrim.strong,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBackground.appBar(
            title: const Text('출생 정보 입력'),
            leading: BackButton(onPressed: _handleBack),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final title = _editingExistingProfile ? '출생 정보 수정' : '출생 정보 입력';
    final submitLabel = _editingExistingProfile ? '저장하기' : '저장하고 시작하기';

    return PopScope(
      canPop: _editingExistingProfile,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: TabBackground(
        imagePath: AssetPaths.onboardingGuardianIntro,
        scrim: TabBackgroundScrim.strong,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBackground.appBar(
            title: Text(title),
            leading: BackButton(onPressed: _handleBack),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nicknameController,
                  maxLength: 20,
                  decoration: const InputDecoration(labelText: '닉네임'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? '닉네임을 입력해 주세요.'
                      : null,
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _pickBirthDate,
                  child: Text(
                    _birthDate == null
                        ? '생년월일 선택'
                        : '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일',
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<CalendarType>(
                  segments: const [
                    ButtonSegment(value: CalendarType.solar, label: Text('양력')),
                    ButtonSegment(value: CalendarType.lunar, label: Text('음력')),
                  ],
                  selected: {_calendarType},
                  onSelectionChanged: (selection) =>
                      setState(() => _calendarType = selection.first),
                ),
                if (_calendarType == CalendarType.lunar)
                  SwitchListTile(
                    title: const Text('윤달이에요'),
                    value: _isLeapMonth,
                    onChanged: (value) => setState(() => _isLeapMonth = value),
                  ),
                SwitchListTile(
                  title: const Text('출생 시간을 알아요'),
                  subtitle: _timeKnown
                      ? null
                      : const Text('시간을 모르면 시주 없이 "출생 시간 미상 기준"으로 계산해요.'),
                  value: _timeKnown,
                  onChanged: (value) => setState(() => _timeKnown = value),
                ),
                if (_timeKnown)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _hour,
                          decoration: const InputDecoration(labelText: '시'),
                          items: [
                            for (var h = 0; h < 24; h++)
                              DropdownMenuItem(value: h, child: Text('$h시')),
                          ],
                          onChanged: (value) => setState(() => _hour = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _minute,
                          decoration: const InputDecoration(labelText: '분'),
                          items: [
                            for (var m = 0; m < 60; m += 5)
                              DropdownMenuItem(value: m, child: Text('$m분')),
                          ],
                          onChanged: (value) =>
                              setState(() => _minute = value!),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  '전통 계산용 성향값 (선택)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                SegmentedButton<GenderMode?>(
                  segments: const [
                    ButtonSegment(value: GenderMode.male, label: Text('남')),
                    ButtonSegment(value: GenderMode.female, label: Text('여')),
                    ButtonSegment(value: null, label: Text('선택 안 함')),
                  ],
                  selected: {_genderMode},
                  onSelectionChanged: (selection) =>
                      setState(() => _genderMode = selection.first),
                ),
                if (_genderMode == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '선택하지 않으면 대운 해석은 제외돼요.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? '확인 중…' : submitLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
