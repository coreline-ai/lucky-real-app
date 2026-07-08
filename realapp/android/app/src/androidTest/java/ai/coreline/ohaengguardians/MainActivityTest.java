package ai.coreline.ohaengguardians;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

/**
 * integration_test를 `adb shell am instrument`로 직접 실행하기 위한 진입점.
 * (Firebase Test Lab 표준 구성과 동일 — flutter tool의 디버그 연결을 우회한다.)
 */
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> rule =
            new ActivityTestRule<>(MainActivity.class, true, false);
}
