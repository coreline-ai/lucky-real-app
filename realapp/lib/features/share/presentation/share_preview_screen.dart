import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show ShareResultStatus;

import '../../../app/app_providers.dart';
import '../../../core/domain/five_element.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../shared/tab_background.dart';
import '../application/share_image_service.dart';
import 'share_card_canvas.dart';

/// 공유 미리보기 (02 공유 플로우: 미리보기 → 닉네임 선택 → 숨김 확인 → OS 시트).
/// 05 게이트: 포함 정보 명시, 민감정보 기본 미포함, 공유 직전 확인.
class SharePreviewScreen extends ConsumerStatefulWidget {
  const SharePreviewScreen.guardian({
    super.key,
    required this.title,
    required this.subtitle,
    required FiveElement this.element,
    required this.myNickname,
    this.shareService,
  }) : isChemistry = false,
       onSharedChemistry = null;

  const SharePreviewScreen.chemistry({
    super.key,
    required this.title,
    required this.subtitle,
    required this.myNickname,
    this.onSharedChemistry,
    this.shareService,
  }) : isChemistry = true,
       element = null;

  final String title;
  final String subtitle;
  final String myNickname;
  final FiveElement? element;
  final bool isChemistry;

  /// 케미 공유 완료 시 호출 (chemistry_shared 해금 트리거 기록, Phase 5 보상).
  final Future<void> Function()? onSharedChemistry;

  /// 테스트에서 OS 공유 시트 결과를 고정하기 위한 주입 지점.
  final ShareImageService? shareService;

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final _boundaryKey = GlobalKey();
  bool _showNickname = true; // 내 닉네임 기본 표시 (02/05 확정 규칙)
  bool _sharing = false;

  ShareCardData get _cardData => widget.isChemistry
      ? ShareCardData.chemistry(
          title: widget.title,
          subtitle: widget.subtitle,
          nickname: _showNickname ? widget.myNickname : null,
        )
      : ShareCardData.guardian(
          title: widget.title,
          subtitle: widget.subtitle,
          element: widget.element!,
          nickname: _showNickname ? widget.myNickname : null,
        );

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final service = widget.shareService ?? ShareImageService();
      final bytes = await service.captureBoundary(_boundaryKey);
      final status = await service.shareBytes(bytes, text: '오행가디언즈');
      if (status != ShareResultStatus.success) return;
      if (widget.isChemistry) {
        await widget.onSharedChemistry?.call();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 만들지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundPath = widget.isChemistry
        ? AssetPaths.chemistryResultBackground
        : AssetPaths.elementBackground(widget.element!);

    return TabBackground(
      imagePath: backgroundPath,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('공유 미리보기')),
        body: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              Center(
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: ShareCardCanvas(data: _cardData),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('내 닉네임 표시'),
                value: _showNickname,
                onChanged: (value) => setState(() => _showNickname = value),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이미지에 포함되는 정보',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${widget.isChemistry ? '케미 리듬과 한 줄 설명' : '오늘의 수호신과 한 줄 운세'}\n'
                        '${_showNickname ? '• 내 닉네임\n' : ''}'
                        '• 앱 이름',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '생년월일, 출생 시간, 상세 사주'
                        '${widget.isChemistry ? ', 상대방 이름' : ''}은 포함되지 않아요.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: const Icon(Icons.ios_share),
                label: Text(_sharing ? '준비 중…' : '이대로 공유하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 공유 진입 헬퍼.
Future<void> openSharePreview(BuildContext context, SharePreviewScreen screen) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));
}

/// 케미 공유 카운터 + 마일스톤 해금 (1/2/3회 → 달빛 토/금/수 카드).
final chemistrySharedCounterProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final db = ref.read(appDatabaseProvider);
    final row =
        await (db.select(db.appMeta)
              ..where((t) => t.key.equals('chemshare_count_user_local')))
            .getSingleOrNull();
    final next = (row == null ? 0 : int.parse(row.value)) + 1;
    await db
        .into(db.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(
            key: 'chemshare_count_user_local',
            value: '$next',
          ),
        );
    await ref
        .read(rewardServiceProvider)
        .claimChemistryShareMilestones(
          userId: localUserId,
          shareCount: next,
          now: ref.read(appClockProvider).nowKst(),
        );
  };
});
