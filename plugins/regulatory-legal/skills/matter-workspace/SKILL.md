---
name: matter-workspace
description: >
  매터 워크스페이스 관리 — 새로 만들기·목록·전환·종료·분리(실무 수준). 다중 의뢰인 실무자
  (법무법인·단독·소규모 사무소)를 위해 한 규제 매터(규제 변경 자문·의견제출 기간·갭 시정
  프로젝트·규제기관 조회 대응)의 컨텍스트를 다른 모든 것과 분리. substantive 스킬이 어느
  매터에서 작업하는지 읽는다. 새 매터 열기, 매터 전환, 목록, 종결·아카이브, 실무 수준에서만
  작업하고 싶을 때 사용.
argument-hint: "<new | list | switch | close | none> [slug]"
triggers:
  - "매터 전환"
  - "매터 워크스페이스"
  - "새 워크스페이스"
  - "매터 목록"
---

# /matter-workspace

법무법인·단독 사무소 실무자는 여러 의뢰인·매터를 가로질러 일함. 매터 워크스페이스는 한 매터의
컨텍스트를 다른 모든 것과 분리. 이 스킬이 그 워크스페이스를 관리.

regulatory-legal에서 "매터"는 일반적으로 **한 의뢰인에 대한 특정 규제 변경 자문, 진행 중인
의견제출 기간, 갭 시정 프로젝트, 규제기관 조회 대응**이다: 규제 변경 자문 | 의견제출 기간 |
갭 시정 프로젝트 | 규제기관 조회 대응 | 상시 topic(계속 watch) | 기타. 피드 워칭은 디폴트로
실무 수준에서 돈다 — 매터 워크스페이스가 켜져 있어도 `/regulatory-legal:reg-feed-watcher`는
watch 기관 전체를 실무 수준에서 점검한다. 매터 워크스페이스는 그 결과에서 파생된 **특정
의뢰인 대응 작업**을 격리하기 위한 것이다.

## 서브커맨드

- `/regulatory-legal:matter-workspace new <slug>` — 새 매터 워크스페이스 생성, 짧은 인테이크 실행, `matter.md` 작성
- `/regulatory-legal:matter-workspace list` — 상태·활성 플래그와 함께 매터 목록
- `/regulatory-legal:matter-workspace switch <slug>` — 활성 매터 설정
- `/regulatory-legal:matter-workspace close <slug>` — 매터 아카이브
  (`~/.claude/plugins/config/claude-for-legal-kr/regulatory-legal/matters/_archived/`로 이동, 절대 삭제 안 함)
- `/regulatory-legal:matter-workspace none` — 활성 매터에서 분리, 실무 수준에서만 작업

## 지침

1. `~/.claude/plugins/config/claude-for-legal-kr/regulatory-legal/CLAUDE.md` 읽기 — `## 매터 워크스페이스`
   섹션 populate 확인. `활성화`가 `✗`이면: "매터 워크스페이스 off — 의뢰인 하나의 사내 규제 대응
   실무로 구성되어 있어 플러그인이 실무 수준 컨텍스트에서 자동 동작합니다. 실제로 다중 의뢰인
   작업(법무법인·단독 사무소)이면 `/regulatory-legal:cold-start-interview --redo` 실행하고 해당
   실무 환경 선택. 그게 아니면 `/matter-workspace` 전혀 필요 없음." 오류 처리 안 함 — 비활성
   상태는 사내 사용자의 예상 상태.
2. 아래 서브커맨드 로직 사용.
3. `$ARGUMENTS`의 첫 토큰으로 디스패치:
   - `new` → 인테이크 인터뷰 실행, `matters/<slug>/matter.md` 작성, `history.md`·`notes.md` seed.
   - `list` → `matters/*/matter.md` enumerate, 표 출력, 활성 매터 표시.
   - `switch` → 실무 수준 CLAUDE.md의 `활성 매터:` 라인 갱신.
   - `close` → `matters/<slug>/`를 `matters/_archived/<slug>/`로 이동, `history.md`에 종결 날짜 로그.
   - `none` → `활성 매터:`를 `없음 — 실무 수준 컨텍스트만`으로 설정.
4. 무엇이 변경되는지 사용자에게 보여주고 작성 전 확인.

## 비고

- `매터 간 컨텍스트`가 실무 수준 CLAUDE.md에서 `on`이 아니면 스킬은 매터를 가로질러 절대 안 읽음.
- 아카이브는 삭제가 아님 — 종결된 매터는 보유·이해상충 점검 목적으로 readable.
- Slug는 lowercase + 하이픈. 아카이브된 것과 활성 사이에 slug 재사용 시 아카이브된 것은 `_archived/<slug>/`에 보존.

---

다중 의뢰인 실무자(법무법인·단독·소규모 사무소)는 여러 매터를 가로질러 일함. 한 매터의 컨텍스트는
다른 매터로 leak되면 안 됨. 이 스킬은 그것을 진실로 만드는 thin 파일 관리 레이어.

**디폴트 상태는 off.** 사내 사용자는 이걸 거의 안 봄 — 실무 수준에서만 실행. 매터 워크스페이스는
콜드스타트에서 법무법인·단독·소규모 사용자에 활성화되거나 실무 수준 CLAUDE.md의 `## 매터 워크스페이스`
편집으로. `활성화`가 `✗`이면 이 스킬은 실행 안 함; 위 워크플로우가 비활성 상태 설명하고 실제로
매터 격리가 필요한 사용자에게 `/regulatory-legal:cold-start-interview --redo` 제안.

## 저장 레이아웃

모든 매터 데이터는:

```
~/.claude/plugins/config/claude-for-legal-kr/regulatory-legal/
├── CLAUDE.md                          # 실무 수준 실무 프로파일
├── matters/
│   ├── <slug>/
│   │   ├── matter.md                  # 의뢰인·매터유형·핵심 사실·override
│   │   ├── history.md                 # 결정·제출·의견서·기한별 로그
│   │   ├── notes.md                   # 자유 형식 작업 노트
│   │   └── outputs/                   # 이 매터의 diff·갭 리포트·의견서 초안 결과
│   └── _archived/
│       └── <slug>/                    # 종결된 매터(읽기 가능)
├── gap-tracker.yaml                    # 실무 수준 갭 트래커(매터가 off일 때 기본 경로)
└── comment-tracker.yaml                # 실무 수준 의견제출 트래커(매터가 off일 때 기본 경로)
```

Slug는 lowercase + 하이픈. 예: `2026-acme-개인정보보호법-대개정`, `2026-공정위-의결-대응`,
`2025-금융위-감독규정-의견제출`.

## 활성 매터는 실무 CLAUDE.md에

실무 수준 CLAUDE.md `## 매터 워크스페이스` 아래 `활성 매터:` 라인이 single source of truth.
매터 전환은 그 라인을 편집. 별도 상태 파일 없음.

## 서브커맨드 로직

### `new <slug>`

1. **슬러그 점검:** `matters/<slug>/` 또는 `matters/_archived/<slug>/`에 이미 있는지 확인. 재사용이면 다른 slug 요청.
2. **인테이크:** 아래 항목을 수집:
   - **의뢰인** (또는 사내면 해당 사업부)
   - **매터 유형** (규제 변경 자문 | 의견제출 기간 | 갭 시정 프로젝트 | 규제기관 조회 대응 | 상시 topic | 기타)
   - **관련 규제기관** (해당 의안·입법예고·행정예고·의결의 소관 부처·위원회)
   - **비밀 등급** (표준 | 강화 | clean-team)
   - **핵심 사실** (2-5문장: 무엇에 관한 매터인지, 이해관계자, 걸려 있는 것)
   - **매터-특화 override** (예: "이 의뢰인은 재료성 임계값을 더 보수적으로 — 소규모 지역 고시도 즉시 알림", "업계 협회 공동제출 조율 중")
   - **관련 매터** (연결된 매터의 slug)
3. **이해상충 점검:** 다른 활성·아카이브 매터에서 같은 의뢰인·이해관계 충돌이 없는지 확인.
   발견 시 플래그: "[다른 매터]가 [동일 의뢰인·이해관계]를 포함. 이해상충 점검 필요."
4. `matters/<slug>/matter.md` 작성 (아래 템플릿) + `history.md`에 매터 생성 entry + 빈 `notes.md`.
5. 새 매터로 **자동 전환 안 함.** 묻기: "지금 `<slug>`로 전환할까요? (`/regulatory-legal:matter-workspace switch <slug>`)"

### `list`

`matters/*/matter.md` enumerate. 각 파일 앞부분 읽어 상태 추출. 표 출력:

| Slug | 의뢰인 | 매터 유형 | 관련 규제기관 | 다음 기한 | 상태 | 활성 |
|---|---|---|---|---|---|---|

현재 활성 매터에 `*` 표시. `_archived/*`는 별도 "아카이브" 제목 아래.

### `switch <slug>`

1. `matters/<slug>/matter.md` 존재 확인. 없으면 `/regulatory-legal:matter-workspace new <slug>` 제안.
2. 실무 수준 CLAUDE.md `활성 매터:` 라인을 `활성 매터: <slug>`로 편집.
3. matter.md 요약을 보여줘 올바른 매터인지 확인.

### `close <slug>`

1. `matters/<slug>/` 존재 확인.
2. `matters/<slug>/history.md`에 오늘 날짜로 "종결" entry 추가.
3. `matters/<slug>/` → `matters/_archived/<slug>/` 이동.
4. 종결한 매터가 활성이었으면 `활성 매터:`를 `없음 — 실무 수준 컨텍스트만`으로 설정.

> **종결 전 확인 사항:** 이 매터에서 발생한 열린 갭·미결정 의견제출이
> `~/.claude/plugins/config/claude-for-legal-kr/regulatory-legal/gap-tracker.yaml`·
> `comment-tracker.yaml`에 남아 있는지 확인. 남아 있으면 실무 수준으로 재라우팅할지,
> 아카이브 상태로 남길지 사용자에게 묻는다 — 매터 폴더가 아카이브되어도 트래커 항목은
> 자동으로 닫히지 않는다.

### `none`

실무 수준 CLAUDE.md `활성 매터:`를 `없음 — 실무 수준 컨텍스트만`으로 설정. 사용자 확인.

## `matter.md` 템플릿

```markdown
[문서 헤더 — 플러그인 config ## 산출물 따라, 역할별 상이; 실무 수준 CLAUDE.md `## 누가 이 플러그인을 사용하나` 참조]

# 매터: [의뢰인] — [짧은 매터명]

**Slug:** [slug]
**등록일:** [YYYY-MM-DD]
**상태:** active
**비밀 등급:** [표준 / 강화 / clean-team]

---

## 당사자

**의뢰인:** [명칭] (또는 사내 사업부)
**관련 규제기관:** [소관 부처·위원회]
**내부 담당자:** [담당자 + 에스컬레이션 라인]

## 매터 유형

[규제 변경 자문 | 의견제출 기간 | 갭 시정 프로젝트 | 규제기관 조회 대응 | 상시 topic | 기타 — 한 줄 근거]

## 핵심 사실

[2-5문장. 이 매터가 무엇인지. 이해관계자가 누구인지. 무엇이 걸려 있는지. 실무 수준 디폴트와 무엇이 다른지.]

## 기한

| 유형 | 날짜 | 근거 | 비고 |
|---|---|---|---|
| [시행일 / 의견제출 마감 / 조회 회신 기한] | [YYYY-MM-DD] | [공고문 / 관보 / 조회 문서] | `[검증 필요]` |

## 매터-특화 override

*이 매터에만 적용되는 실무 수준 재료성 임계값·watchlist·플레이북으로부터의 이탈.*

- [예: "이 의뢰인은 소규모 지역 고시도 즉시 알림 — 실무 수준 재료성보다 보수적."]
- [예: "업계 협회 공동제출 조율 중 — 단독 의견 제출 보류."]

## 관련 매터

- [slug — 관련 이유 한 줄]

## 비밀 등급 비고

[강화·clean-team이면 이유 설명. 매터 간 컨텍스트가 전역 on이어도 허용되는지.]
```

## `history.md` seed

```markdown
# 히스토리: [의뢰인] — [짧은 매터명]

추가 전용 이벤트 로그. 최신이 위.

---

## [YYYY-MM-DD] — 매터 등록(인테이크)

인테이크 완료. Slug: `[slug]`. 상태: active.
[matter.md 외에 보존할 초기 컨텍스트 — 예: "입법예고 공고 확인 후 의뢰인 요청으로 등록."]
```

## 매터별 출력

매터가 활성이면 모든 스킬의 산출물(다이제스트·diff·갭 리포트·의견서 초안)은 매터 폴더
`matters/<slug>/outputs/`로. gap-tracker.yaml·comment-tracker.yaml도 매터 폴더 안에 별도로
유지된다 — 실무 수준 트래커가 아니다.

## 매터 간 컨텍스트

실무 수준 CLAUDE.md에 `매터 간 컨텍스트:` 플래그가 있음. `off`(디폴트)이면 매터 A에서 작업하는
스킬은 다른 어떤 `B`의 `matters/B/` 파일을 **절대 안 읽음.** 끝. 이게 이 설정이 존재하는 이유인
비밀유지 보장.

`on`이면 사용자가 명시적으로 요청할 때만 매터 폴더를 가로질러 읽을 수 있음.

## 이 스킬이 하지 않는 것

- **이해상충 분석 실행.** 이해상충은 실무자·변호사의 일; 인테이크는 사용자가 선언한 것만 수집.
- **보유 정책 집행.** 종결은 매터를 아카이브하지 삭제하지 않음. 보유 정책은 범위 밖.
- **산출물 자동 라우팅.** substantive 스킬이 어디 쓸지 결정; 이 스킬은 *어느 폴더*가 활성인지 알려주지, 무엇을 넣을지 알려주지 않음.
- **트래커 항목 자동 종결.** 매터를 close해도 gap-tracker.yaml·comment-tracker.yaml의 열린 항목은 자동으로 닫히지 않는다 — 종결 전 확인 사항 참조.
