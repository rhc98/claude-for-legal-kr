---
name: matter-workspace
description: >
  매터 워크스페이스 관리 — 새로 만들기·목록·전환·종료·분리(실무 수준). 다중 의뢰인 실무자
  (법무법인·단독 사무소)를 위해 한 의뢰인·매터의 컨텍스트를 다른 모든 것과 분리. 사용자가
  새 매터 열기, 매터 전환, 매터 목록, 매터 종료·아카이브, 실무 수준에서만 작업하고 싶을 때 사용.
argument-hint: "<new | list | switch | close | none> [slug]"
---

# /matter-workspace

법무법인 또는 단독 사무소 실무자는 여러 의뢰인·매터를 가로질러 일함. 매터 워크스페이스는
한 의뢰인·engagement의 컨텍스트를 다른 모든 것과 분리. 이 스킬이 그 워크스페이스 관리.

## 서브커맨드

- `/privacy-legal:matter-workspace new <slug>` — 새 매터 워크스페이스 생성, 짧은 인테이크
  실행, `matter.md` 작성
- `/privacy-legal:matter-workspace list` — 상태·활성 플래그와 함께 매터 목록
- `/privacy-legal:matter-workspace switch <slug>` — 활성 매터 설정
- `/privacy-legal:matter-workspace close <slug>` — 매터 아카이브
  (`~/.claude/plugins/config/claude-for-legal/privacy-legal/matters/_archived/`로 이동, 절대 삭제 안 함)
- `/privacy-legal:matter-workspace none` — 활성 매터에서 분리, 실무 수준에서만 작업

## 지침

1. `~/.claude/plugins/config/claude-for-legal/privacy-legal/CLAUDE.md` 읽기 — `## 매터
   워크스페이스` 섹션 populate 확인. `활성화`가 `✗`이면: "매터 워크스페이스 off — 의뢰인
   하나의 사내 실무로 구성되어 있어 플러그인이 실무 수준 컨텍스트에서 자동 동작합니다.
   실제로 다중 의뢰인 작업이면 `/privacy-legal:cold-start-interview --redo` 실행하고
   법무법인 또는 단독·소규모 실무 환경 선택. 그게 아니면 `/matter-workspace` 전혀 필요
   없음." 오류 처리 안 함 — 비활성 상태는 사내 사용자의 예상 상태.
2. 아래 서브커맨드 로직 사용.
3. `$ARGUMENTS`의 첫 토큰으로 디스패치:
   - `new` → 인테이크 인터뷰 실행, `~/.claude/plugins/config/claude-for-legal/privacy-legal/matters/<slug>/matter.md`
     작성, `history.md`와 `notes.md` seed.
   - `list` → `~/.claude/plugins/config/claude-for-legal/privacy-legal/matters/*/matter.md`
     enumerate, 표 출력, 활성 매터 표시.
   - `switch` → 실무 수준 CLAUDE.md의 `활성 매터:` 라인 갱신.
   - `close` → `~/.claude/plugins/config/claude-for-legal/privacy-legal/matters/<slug>/`를
     `~/.claude/plugins/config/claude-for-legal/privacy-legal/matters/_archived/<slug>/`로
     이동, `history.md`에 종료 날짜 로그.
   - `none` → `활성 매터:`를 `없음 — 실무 수준 컨텍스트만`으로 설정.
4. 무엇이 변경되는지 사용자에게 보여주고 작성 전 확인.

## 비고

- `매터 간 컨텍스트`가 실무 수준 CLAUDE.md에서 `on`이 아니면 스킬은 매터를 가로질러 절대 안 읽음.
- 아카이브는 삭제가 아님 — 종료된 매터는 보유·이해상충 점검 목적으로 readable.
- Slug는 lowercase + 하이픈. 아카이브된 것과 활성 사이에 slug 재사용 시 아카이브된 것은
  `_archived/<slug>/`에 보존.

---

# 매터 워크스페이스

다중 의뢰인 실무자(법무법인·단독 사무소)는 여러 매터를 가로질러 일함. 한 매터의 컨텍스트는
다른 매터로 leak되면 안 됨. 이 스킬은 그것을 진실로 만드는 thin 파일 관리 레이어.

**디폴트 상태는 off.** 사내 사용자는 이걸 절대 안 봄 — 실무 수준에서만 실행. 매터 워크스페이스는
콜드스타트에서 법무법인·소규모 사용자에 활성화되거나 실무 수준 CLAUDE.md의 `## 매터
워크스페이스` 편집으로. `활성화`가 `✗`이면 이 스킬은 실행 안 함; 위 워크플로우가 비활성
상태 설명하고 실제로 매터 격리가 필요한 사용자에게 `/privacy-legal:cold-start-interview --redo` 제안.

## 저장 레이아웃

모든 매터 데이터는:

```
~/.claude/plugins/config/claude-for-legal/privacy-legal/
├── CLAUDE.md                       # 실무 수준 실무 프로파일
└── matters/
    ├── <slug>/
    │   ├── matter.md               # 의뢰인·상대방·매터 유형·핵심 사실·override
    │   ├── history.md              # 이벤트·결정·초안·검토 날짜별 로그
    │   ├── notes.md                # 자유 형식 작업 노트
    │   └── outputs/                # 이 매터의 PIA·DPA 검토·트리아지 결과
    └── _archived/
        └── <slug>/                 # 종료된 매터(읽기 가능)
```

## 새 매터 인테이크

`new <slug>` 호출 시:

1. **의뢰인 정보:**
   - 의뢰인 회사명
   - 의뢰인 산업 (개인정보 풋프린트 영향)
   - 의뢰인 PIPA 역할 (개인정보처리자 / 수탁자 / 양쪽)
   - 의뢰인 규모 (개인정보 풋프린트 영향)
   - 정보주체 위치 (한국 only / 외국 포함 → GDPR·CCPA 가능성)

2. **매터 정보:**
   - 매터 유형 (PIA / DPA 검토 / 권리행사 응답 / 정책 갱신 / PIPC 조사 응답 등)
   - 매터 시작 날짜
   - 상대방 (해당 시 — 예: DPA 상대 고객·벤더)
   - 핵심 기한
   - 실무 수준 디폴트로부터의 매터-특화 override (예: 이 의뢰인은 디폴트보다 보수적 위험 성향)

3. **이해상충 점검:** 다른 활성·아카이브 매터에서 같은 상대방·의뢰인 없는지 확인.
   발견 시 플래그: "[다른 매터]가 [동일 당사자]를 포함. 이해상충 점검 필요."

4. `matter.md` 작성 + `history.md`에 매터 생성 entry.

## 매터별 출력

매터가 활성이면 모든 스킬의 산출물은 매터 폴더 `matters/<slug>/outputs/`로. 실무 수준
산출물 폴더가 아님.

## 다음 단계

매터 작업 후 짧은 confirmation + 다음 추천 행동.
