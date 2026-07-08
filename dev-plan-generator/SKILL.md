---
name: dev-plan-generator
description: Create or update lightweight phased development plan markdown documents for implementation work. Use when the user asks for a 개발 계획 문서, 구현 계획, dev plan, phased implementation plan, implement_*.md, or a checkbox-based task plan before or during coding. Before drafting, read relevant project `.md` files to clarify the goal, scope, and documented rules. Generate or maintain `dev-plan/implement_YYYYMMDD_HHMMSS.md` with a clear purpose, scope limits, phased tasks, per-phase self-tests, and progress checkboxes.
---

# Dev Plan Generator

## Overview

Create a lightweight development scope document that keeps implementation focused on the current goal.
This document is for fixing scope, tracking phased work, and preserving development history across multiple implementation efforts.

## Core intent

- Fix the goal and scope of the current work.
- Prevent implementation from expanding in a different direction.
- Track progress with phase-based checkboxes.
- Keep a history by creating a new plan file for each new workstream.

## Workflow

1. Read only the docs needed to fix scope before drafting: prefer `README.md`, `AGENTS.md`, `CLAUDE.md`, relevant `docs/*.md`, and recent `dev-plan/*.md`.
2. Clarify the goal, scope, exclusions, documented rules, and material ambiguities; if unclear, list likely cases/options and ask before choosing.
3. Create a new `dev-plan/implement_YYYYMMDD_HHMMSS.md` for a new workstream.
4. Update the same file only when the goal and scope are the same workstream.
5. Create a new file when the goal, scope, or refactor direction changes.

## Document rules

- Put `개발 목적`, `개발 범위`, `제외 범위`, `참조 문서`, and `공통 진행 규칙` at the top.
- Keep the document lightweight and implementation-oriented.
- Do not turn the document into a PRD, TRD, meeting log, or large design spec.
- Break work into ordered phases.
- Use markdown checkboxes for all implementation and test tasks.
- Each Phase must include self-tests.
- Do not move to the next Phase until the current Phase tests are complete.
- Record implementation issues inside the current Phase and fix them there.
- Update checkbox state to match real progress.
- Do not add undocumented new features or unrelated refactors.
- Write the plan so another agent can resume it: purpose, scope, exclusions, file structure, implementation order, and test criteria must be clear.
- Plan implementation in the smallest maintainable responsibility units needed for the feature; define each unit's role and boundary without adding options, extensions, or extras outside scope.
- Extract shared logic only when it reduces duplication inside the planned scope; avoid purposeless abstraction.
- Prefer existing project APIs, official SDKs, and standard libraries before custom implementation; add new dependencies only when required by scope.
- Include a separate `QA 관점` section for adversarial review, failure cases, boundary values, and regression risks.

## History rules

- Create files under `dev-plan/`.
- Name files as `implement_YYYYMMDD_HHMMSS.md`.
- Set the first H1 to the exact filename including `.md`.
- Add `작성 일시` near the top.
- If this work follows a previous plan, add the previous plan to `참조 문서`.
- Do not overwrite old plan files.

## Required structure

Use this structure by default:

```md
# implement_YYYYMMDD_HHMMSS.md

작성 일시: `YYYY-MM-DD HH:MM:SS TZ`

이 문서는 이번 개발의 범위를 고정하고, 구현이 목적 밖으로 확장되지 않도록 하기 위한 작업 문서다.

## 개발 목적
...

## 개발 범위
...

## 제외 범위
- ...

## 참조 문서
- [문서명](경로 또는 링크)
- 없음

## 공통 진행 규칙
- 각 Phase는 앞선 Phase의 자체 테스트 완료 후에만 시작한다.
- 구현 중 발생한 이슈는 해당 Phase에서 수정하고 기록한다.
- 체크박스 상태를 실제 진행 상태와 맞게 업데이트한다.
- 문서에 없는 범위 확장은 하지 않는다.
- 요구사항이 불명확하면 가능한 케이스를 나누고 확인 후 진행한다.
- 한 기능은 유지보수 가능한 최소 책임 단위로 나누고, 각 단위의 역할과 경계를 계획에 적는다.
- 계획 밖 옵션/확장/부가 기능을 만들기 위한 분리는 하지 않는다.
- 공통화는 계획 범위 안의 중복을 줄일 때만 수행하고 과도한 추상화는 피한다.
- 기존 프로젝트 API, 공식 SDK, 표준 라이브러리를 우선 검토하고 새 의존성은 범위상 필요할 때만 포함한다.

## Phase 상태 요약
- [ ] Phase 1 완료
- [ ] Phase 2 완료

## QA 관점
- [ ] 실패 케이스와 경계값을 검토한다.
- [ ] 회귀 리스크와 검증 기준을 확인한다.

## Phase 1. <이름>
### 목표
- ...

### 구현 태스크
- [ ] ...
- [ ] ...

### 자체 테스트
- [ ] ...
- [ ] ...

### 이슈 및 수정
- [ ] 발견 이슈 없음

### 완료 조건
- [ ] 구현 완료
- [ ] 자체 테스트 완료
- [ ] 다음 Phase 진행 가능
```

## Optional sections

Add only when needed:

- `문서 기반 제약 사항`
- `확인 필요 사항 / 결정 기록`
- `예상 변경 파일 / 영향 범위`
- `최종 결과 요약`
- `잔여 리스크 / 후속 과제`
- `이전 개발 계획`

## Script

Use `scripts/new_dev_plan.py` to scaffold a new file quickly.
The script should stay minimal. It creates the document skeleton; the actual scope clarification comes from reading project docs and the user request.
