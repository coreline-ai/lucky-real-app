import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/result/app_failure.dart';
import '../../../core/time/app_clock.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../engine/gateway/models.dart';
import '../../shared/failure_messages.dart';
import '../../shared/tab_background.dart';
import '../content/chemistry_content.dart';
import 'chemistry_screen.dart';

/// 케미 상대 입력 (02): 관계 타입 + 출생정보. 저장 전 엔진 검증 1회.
/// 05: 상대방 민감정보 안내 문구 필수.
class PartnerFormScreen extends ConsumerStatefulWidget {
  const PartnerFormScreen({super.key});

  @override
  ConsumerState<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends ConsumerState<PartnerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  RelationType _relation = RelationType.friend;
  DateTime? _birthDate;
  bool _timeKnown = false;
  int _hour = 12;
  int _minute = 0;
  CalendarType _calendarType = CalendarType.solar;
  bool _isLeapMonth = false;
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = ref.read(appClockProvider).todayKst();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1908, 4, 1),
      lastDate: now,
      helpText: '상대 생년월일 선택',
    );
    if (picked != null) setState(() => _birthDate = picked);
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
      );
      // 저장 전 검증 계산 (지원 범위·법정시 오류 선차단).
      await ref.read(engineGatewayProvider).calculateFourPillars(input);

      final now = ref.read(appClockProvider).nowKst();
      final partnerId = await ref
          .read(chemistryRepositoryProvider)
          .addPartner(
            ownerUserId: localUserId,
            label: _labelController.text.trim(),
            relationType: _relation.name,
            birthDate: _birthDate!,
            birthHour: input.hour,
            birthMinute: input.minute,
            calendarType: _calendarType,
            isLeapMonth: input.isLeapMonth,
            now: now,
          );
      ref.invalidate(partnersProvider);
      if (mounted) {
        context.pushReplacement('${RoutePaths.chemistryResult}/$partnerId');
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

  @override
  Widget build(BuildContext context) {
    return TabBackground(
      imagePath: AssetPaths.chemistryResultBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('상대 추가')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '상대방의 출생정보는 민감한 개인정보예요. '
                    '이 기기에만 저장되며, 상대방 동의 없이 공개하지 마세요.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelController,
                maxLength: 20,
                decoration: const InputDecoration(labelText: '이름 또는 별칭'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? '이름이나 별칭을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 8),
              Text('관계', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final relation in RelationType.values)
                    ChoiceChip(
                      label: Text(relation.korean),
                      selected: _relation == relation,
                      onSelected: (_) => setState(() => _relation = relation),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _pickBirthDate,
                child: Text(
                  _birthDate == null
                      ? '생년월일 선택'
                      : '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일',
                ),
              ),
              const SizedBox(height: 8),
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
                subtitle: _timeKnown ? null : const Text('몰라도 케미를 볼 수 있어요.'),
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
                        onChanged: (value) => setState(() => _minute = value!),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? '확인 중…' : '케미 보러 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
