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

- `/commercial-legal:matter-workspace new <slug>` — 새 매터 워크스페이스 생성, 짧은 인테이크
  실행, `matter.md` 작성
- `/commercial-legal:matter-workspace list` — 상태·활성 플래그와 함께 매터 목록
- `/commercial-legal:matter-workspace switch <slug>` — 활성 매터 설정
- `/commercial-legal:matter-workspace close <slug>` — 매터 아카이브
  (`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/_archived/`로 이동, 절대 삭제 안 함)
- `/commercial-legal:matter-workspace none` — 활성 매터에서 분리, 실무 수준에서만 작업

## 지침

1. `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md` 읽기 — `## 매터
   워크스페이스` 섹션 populate 확인. `활성화`가 `✗`이면: "매터 워크스페이스 off — 의뢰인
   하나의 사내 실무로 구성되어 있어 플러그인이 실무 수준 컨텍스트에서 자동 동작합니다.
   실제로 다중 의뢰인 작업이면 `/commercial-legal:cold-start-interview --redo` 실행하고
   법무법인 또는 단독·소규모 실무 환경 선택. 그게 아니면 `/matter-workspace` 전혀 필요
   없음." 오류 처리 안 함 — 비활성 상태는 사내 사용자의 예상 상태.
2. 아래 서브커맨드 로직 사용.
3. `$ARGUMENTS`의 첫 토큰으로 디스패치:
   - `new` → 인테이크 인터뷰 실행, `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/<slug>/matter.md`
     작성, `history.md`와 `notes.md` seed.
   - `list` → `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/*/matter.md`
     enumerate, 표 출력, 활성 매터 표시.
   - `switch` → 실무 수준 CLAUDE.md의 `활성 매터:` 라인 갱신.
   - `close` → `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/<slug>/`를
     `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/_archived/<slug>/`로
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
상태 설명하고 실제로 매터 격리가 필요한 사용자에게 `/commercial-legal:cold-start-interview --redo` 제안.

## 저장 레이아웃

모든 매터 데이터는:

```
~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/
├── CLAUDE.md                       # 실무 수준 실무 프로파일
└── matters/
    ├── <slug>/
    │   ├── matter.md               # 의뢰인·상대방·매터 유형·핵심 사실·override
    │   ├── history.md              # 이벤트·결정·초안·검토 날짜별 로그
    │   ├── notes.md                # 자유 형식 작업 노트
    │   └── outputs/                # 이 매터의 계약 검토·평가·트리아지·이해관계자 요약 결과
    └── _archived/
        └── <slug>/                 # 종료된 매터(읽기 가능)
```

Slug는 lowercase + 하이픈. 예: `acme-msa-2026`, `zenith-renewal`, `vendor-xyz-nda`.

## 새 매터 인테이크

`new <slug>` 호출 시:

1. **슬러그 점검:** `matters/<slug>/` 또는 `matters/_archived/<slug>/`에 이미 있는지 확인.
   재사용이면 다른 slug 요청.
2. **의뢰인 정보:**
   - 의뢰인 (우리가 대리하는 당사자, 사내면 내부 사업부)
   - 상대방 (다른 측 — 복수 가능)
   - 측(side) (이 매터에서 의뢰인이 매도인·공급자측인지 매수인·구매자측인지 — 모든 플레이북
     입장이 측에 따라 바뀜)
3. **매터 정보:**
   - 매터 유형 (벤더 MSA / 고객 계약 / NDA / SaaS 구독 / 변경계약 / 갱신 / 기타)
   - 매터 시작 날짜
   - 비밀 등급 (표준 / 강화 / clean-team — 강화는 다중 매터 환경에서 추가 주의 트리거)
   - 핵심 사실 (2-5문장: 이 매터가 무엇인지, 이해관계자가 누구인지, 무엇이 걸려 있는지,
     디폴트 플레이북과 무엇이 다른지)
   - 실무 수준 플레이북으로부터의 매터-특화 override (예: "이 의뢰인은 책임 cap 12개월 아닌
     24개월 요구", "상대방은 전략적 파트너 — 관계 보존 톤", "준거법은 한국법 아닌 영국법")
   - 관련 매터 (연결된 매터의 slug)
4. **이해상충 점검:** 다른 활성·아카이브 매터에서 같은 상대방·의뢰인 없는지 확인.
   발견 시 플래그: "[다른 매터]가 [동일 당사자]를 포함. 이해상충 점검 필요."
5. `matter.md` 작성 + `history.md`에 매터 생성 entry + 빈 `notes.md` 생성.
6. 새 매터로 **자동 전환 안 함.** 묻기: "지금 `<slug>`로 전환할까요?
   (`/commercial-legal:matter-workspace switch <slug>`)"

## `matter.md` 템플릿

```markdown
[문서 헤더 — 플러그인 config ## 산출물 따라, 역할별 상이; 실무 수준 CLAUDE.md의
`## 누가 이 플러그인을 사용하나` 참조]

# 매터: [의뢰인] — [짧은 설명]

**Slug:** [slug]
**시작:** [YYYY-MM-DD]
**상태:** active
**비밀 등급:** [표준 / 강화 / clean-team]

---

## 당사자

**의뢰인:** [성명]
**상대방:** [성명(들)]
**측(side):** [매도인·공급자측 / 매수인·구매자측 — 한 줄 근거]

## 매터 유형

[벤더 MSA | 고객 계약 | NDA | SaaS 구독 | 변경계약 | 갱신 | 기타 — 한 줄 근거]

## 핵심 사실

[2-5문장. 이 매터가 무엇인지. 이해관계자가 누구인지. 무엇이 걸려 있는지. 디폴트
플레이북과 무엇이 다른지.]

## 매터-특화 override

*이 매터에만, 그리고 이 매터에만 적용되는 실무 수준 플레이북으로부터의 이탈.*

- [예: "책임 cap: 의뢰인이 24개월 요구, 하우스 표준 12개월 아님."]
- [예: "톤: 관계 보존 — 상대방이 전략적 파트너."]
- [예: "준거법: 영국법 필수, 한국법 아님."]

## 관련 매터

- [slug — 관련 이유 한 줄]

## 비밀 등급 비고

[강화·clean-team이면 이유 설명. 누가 매터 파일을 볼 수 있는지. 매터 간 컨텍스트가 전역
on이어도 허용되는지.]
```

## `history.md` seed

```markdown
# 히스토리: [의뢰인] — [짧은 설명]

추가 전용 이벤트 로그. 최신이 위.

---

## [YYYY-MM-DD] — 매터 시작

인테이크 완료. Slug: `[slug]`. 상태: active.
[matter.md 외에 보존할 만한 초기 컨텍스트 — 예: "[상대방]의 MSA 초안 수신에 대응해 시작."]
```

## 매터별 출력

매터가 활성이면 모든 스킬의 산출물은 매터 폴더 `matters/<slug>/outputs/`로. 실무 수준
산출물 폴더가 아님.

## 매터 간 컨텍스트

실무 수준 CLAUDE.md에 `매터 간 컨텍스트:` 플래그가 있음. `off`(디폴트)이면 매터 A에서
작업하는 스킬은 다른 어떤 `B`의 `matters/B/` 파일을 **절대 안 읽음.** 끝. 이게 이 설정이
존재하는 이유인 비밀유지 보장.

`on`이면 사용자가 명시적으로 요청할 때만 매터 폴더를 가로질러 읽을 수 있음 (예: "최근 다섯
벤더 매터에서 책임 cap에 대한 우리 입장 비교"). `on`이어도 디폴트는 활성 매터만 로드하며,
사용자가 매터 간 뷰를 요청할 때만 예외.

## 이 스킬이 하지 않는 것

- **이해상충 점검 실행.** 이해상충은 실무자·로펌의 일; 인테이크는 사용자가 선언한 것만 수집.
- **보유 정책 집행.** 종료는 매터를 아카이브하지 삭제하지 않음. 보유 정책은 범위 밖.
- **산출물 자동 라우팅.** substantive 스킬이 어디 쓸지 결정; 이 스킬은 *어느 폴더*가
  활성인지 알려주지, 무엇을 넣을지 알려주지 않음.
- **매터 간이 적절한지 판단.** 플래그를 읽고 따를 뿐.
