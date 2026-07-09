import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/features/share/application/share_image_service.dart';
import 'package:ohaeng_guardians/features/share/presentation/share_card_canvas.dart';
import 'package:ohaeng_guardians/features/share/presentation/share_preview_screen.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  group('공유 카드 (05 개인정보 게이트)', () {
    testWidgets('카드에는 제목·설명·닉네임·앱 이름만 렌더된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShareCardCanvas(
            data: ShareCardData.guardian(
              title: '오늘의 수호신 · 목',
              subtitle: '내 페이스를 지키기 좋은 날이에요.',
              element: FiveElement.wood,
              nickname: '테스터',
            ),
          ),
        ),
      );
      expect(find.textContaining('테스터'), findsOneWidget);
      expect(find.textContaining('오행가디언즈'), findsOneWidget);
      // 생년월일 형식 텍스트가 존재하지 않음 (구조적으로 전달 불가지만 이중 확인).
      expect(find.textContaining('19'), findsNothing);
      expect(find.textContaining('년생'), findsNothing);
    });

    testWidgets('닉네임 null이면 카드에 닉네임이 없다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShareCardCanvas(
            data: ShareCardData.chemistry(
              title: '우리의 케미 리듬 78',
              subtitle: '함께할수록 서로를 채워주는 흐름이에요.',
            ),
          ),
        ),
      );
      expect(find.textContaining('테스터'), findsNothing);
      expect(find.text('오행가디언즈'), findsOneWidget);
    });

    testWidgets('미리보기: 닉네임 토글 기본 on, 끄면 카드에서 사라진다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SharePreviewScreen.chemistry(
              title: '우리의 케미 리듬 78',
              subtitle: '함께할수록 서로를 채워주는 흐름이에요.',
              myNickname: '테스터',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 기본: 내 닉네임 표시 on
      expect(find.textContaining('테스터 · 오행가디언즈'), findsOneWidget);

      // 안내 카드·토글은 미리보기 아래에 있어 스크롤 후 확인.
      await tester.scrollUntilVisible(find.textContaining('포함되지 않아요'), 200);
      expect(find.textContaining('상대방 이름'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.textContaining('테스터 · 오행가디언즈'), findsNothing);
    });

    testWidgets('미리보기: 공유 취소는 케미 공유 보상을 지급하지 않는다', (tester) async {
      var sharedCount = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SharePreviewScreen.chemistry(
              title: '우리의 케미 리듬 78',
              subtitle: '함께할수록 서로를 채워주는 흐름이에요.',
              myNickname: '테스터',
              shareService: _FakeShareImageService(ShareResultStatus.dismissed),
              onSharedChemistry: () async => sharedCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('이대로 공유하기'), 200);
      await tester.tap(find.text('이대로 공유하기'));
      await tester.pumpAndSettle();

      expect(sharedCount, 0);
      expect(find.text('공유 미리보기'), findsOneWidget);
    });

    testWidgets('미리보기: 하단 공유 버튼은 시스템 안전영역 위에 놓인다', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                padding: EdgeInsets.only(bottom: 48),
                viewPadding: EdgeInsets.only(bottom: 48),
              ),
              child: SharePreviewScreen.chemistry(
                title: '우리의 케미 리듬 78',
                subtitle: '함께할수록 서로를 채워주는 흐름이에요.',
                myNickname: '테스터',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('이대로 공유하기'), 200);
      final buttonRect = tester.getRect(find.text('이대로 공유하기'));

      expect(buttonRect.bottom, lessThanOrEqualTo(640 - 48));
    });
  });

  group('ShareImageService', () {
    test('공유 후 임시 파일이 삭제된다 (완료·실패 모두)', () async {
      final dir = await Directory.systemTemp.createTemp('ohaeng_share');
      addTearDown(() => dir.delete(recursive: true));

      String? sharedPath;
      final ok = ShareImageService(
        shareFile: (path, text) async {
          sharedPath = path;
          return const ShareResult('ok', ShareResultStatus.success);
        },
      );
      final status = await ok.shareBytes([1, 2, 3], text: 't', tempDir: dir);
      expect(status, ShareResultStatus.success);
      expect(sharedPath, isNotNull);
      expect(File(sharedPath!).existsSync(), isFalse, reason: '완료 후 정리');

      final failing = ShareImageService(
        shareFile: (path, text) async {
          sharedPath = path;
          throw Exception('share cancelled');
        },
      );
      await expectLater(
        failing.shareBytes([1, 2, 3], text: 't', tempDir: dir),
        throwsException,
      );
      expect(File(sharedPath!).existsSync(), isFalse, reason: '실패 후에도 정리');
    });

    test('공유 취소 상태를 호출자에게 전달한다', () async {
      final dir = await Directory.systemTemp.createTemp('ohaeng_share_cancel');
      addTearDown(() => dir.delete(recursive: true));

      final service = ShareImageService(
        shareFile: (_, _) async =>
            const ShareResult('', ShareResultStatus.dismissed),
      );

      expect(
        await service.shareBytes([1, 2, 3], text: 't', tempDir: dir),
        ShareResultStatus.dismissed,
      );
    });
  });

  group('골든', () {
    testWidgets('수호신 공유 카드 골든', (tester) async {
      await tester.binding.setSurfaceSize(ShareCardCanvas.logicalSize);
      await tester.pumpWidget(
        const MaterialApp(
          home: ShareCardCanvas(
            data: ShareCardData.guardian(
              title: '오늘의 수호신 · 수',
              subtitle: '흘려보내는 것도 회복이에요.',
              element: FiveElement.water,
              nickname: '테스터',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ShareCardCanvas),
        matchesGoldenFile('goldens/share_card_guardian.png'),
      );
    });
  });
}

class _FakeShareImageService extends ShareImageService {
  _FakeShareImageService(this.status)
    : super(shareFile: (_, _) async => ShareResult('fake', status));

  final ShareResultStatus status;

  @override
  Future<List<int>> captureBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    return [1, 2, 3];
  }
}
