# 개인정보 실무 플러그인 (privacy-legal)

한국 개인정보보호법(PIPA) 실무를 위한 Claude Code 플러그인. 처리 활동 트리아지,
PIA(개인정보 영향평가) 작성, 위·수탁계약(DPA) 양방향 검토, 정보주체 권리행사
응답 초안, 정책 변경 모니터링.

원본 [`anthropics/claude-for-legal`](https://github.com/anthropics/claude-for-legal)의
`privacy-legal` 플러그인(Apache 2.0)을 한국 법체계로 포팅한 결과물입니다.

**모든 출력은 변호사 검토 전제의 초안입니다** — 인용된 조문·판례는 법망 MCP로
검증해 표시하고, 변호사가 판단해야 할 지점은 `[검토]` 플래그를 답니다. 결정적
행위(권리행사 응답 송부, DPA 서명, PIPC 자료 제출, 침해통지 발송)는 명시적 확인
게이트를 통과해야 합니다.

## 누구를 위한 도구인가

| 역할 | 주요 워크플로우 |
|---|---|
| **개인정보 변호사** | DPA 검토, PIA 결재, 정책 갭 분석 |
| **개인정보 보호책임자(CPO)·DPO** | 권리행사 처리, PIA 인테이크, 수탁자 점검 |
| **제품 법무 카운슬** | 신규 기능 PIA 작성 |
| **운영·고객지원** | 권리행사 1차 응답 (에스컬레이션 동반) |

## 첫 실행: 콜드스타트 인터뷰

플러그인이 인터뷰로 학습합니다: 위탁자인지 수탁자인지, 어떤 규제가 적용되는지,
위·수탁계약에서 무엇은 받아들이고 무엇은 거부하는지. 그 후 세 개의 시드 문서를 읽습니다 —
개인정보처리방침, 표준 위·수탁계약, 만족하는 PIA 하나 — 그리고 실제 입장과 하우스
스타일을 학습합니다.

설정은 `~/.claude/plugins/config/claude-for-legal/privacy-legal/CLAUDE.md`에 저장되며
플러그인 업데이트와 무관하게 유지됩니다.

```
/privacy-legal:cold-start-interview
```

## 커맨드

| 커맨드 | 하는 일 |
|---|---|
| `/privacy-legal:cold-start-interview` | 콜드스타트 인터뷰 |
| `/privacy-legal:use-case-triage [활동]` | PIA 필요? 빠른 분류 + 조건 |
| `/privacy-legal:dpa-review [파일]` | 위·수탁계약 양방향 검토(위탁/수탁 자동 감지) |
| `/privacy-legal:dsar-response` | 정보주체 권리행사 처리·응답 초안 |
| `/privacy-legal:pia-generation [기능]` | 하우스 스타일로 PIA 작성 |
| `/privacy-legal:reg-gap-analysis [규제]` | 새 규제 vs 현행 정책·실무 diff |
| `/privacy-legal:policy-monitor` | 정책 drift 정기 sweep, 또는 신규 실무 직접 질의 |
| `/privacy-legal:pipa-spi-handling` | **신규** — 민감정보·고유식별정보·주민번호 처리 적법성 |
| `/privacy-legal:cross-border-transfer` | **신규** — PIPA §28-8 국외이전 5트랙 평가 |
| `/privacy-legal:matter-workspace` | 매터 관리(법무법인·다중 의뢰인 실무만) |
| `/privacy-legal:customize` | 실무 프로파일 일부 항목만 수정 |

## 빠른 시작

### 1. 셋업

```
/privacy-legal:cold-start-interview
```

준비물: 공개 처리방침 URL, 표준 위·수탁계약, 표준 PIA 하나.

### 2. 신규 기능·처리 활동 트리아지

```
/privacy-legal:use-case-triage "마케팅이 행동 데이터를 광고 개인화에 사용하려 함"
```

출력: 진행 가능 / PIA 권장 / PIA 의무 / 중단 — 조건 표, 적법 처리 근거 질문, 이어서
PIA를 같은 대화에서 시작할지 제안.

### 3. 고객사 위·수탁계약 검토

```
/privacy-legal:dpa-review customer-dpa.pdf
```

출력: 위탁/수탁 방향 자동 감지, 조항별 vs 플레이북 대조, 레드라인 제안, 처리방침
일관성 점검.

### 4. 정보주체 권리행사 처리

```
/privacy-legal:dsar-response
```

분류 → 본인확인 → 시스템 walk → 면제 사유 평가 → 응답 초안. 시스템 목록은
CLAUDE.md에서 사용.

### 5. 신규 기능 PIA

```
/privacy-legal:pia-generation "위치 공유 기능"
```

인테이크 질문 → 하우스 포맷으로 PIA → 처리방침 diff → 조건 목록.

## 학습 메커니즘

`~/.claude/plugins/config/claude-for-legal/privacy-legal/CLAUDE.md`의 실무 프로파일은
정적이지 않습니다 — 플러그인을 쓸수록 개선됩니다. 스킬은 출력이 어떤 디폴트를
사용했는지 알려주어 튜닝하도록 안내합니다. `policy-monitor` 스킬은 정책과 실무의
drift를 감지해 업데이트를 제안합니다. 재셋업 실행, 파일 직접 수정, 또는 스킬에게
새 입장을 기록해달라고 말할 수 있습니다.

## 파일 구조

```
privacy-legal/
├── .claude-plugin/plugin.json
├── .mcp.json                       # 법망(beopmang) + Slack + Google Drive
├── CLAUDE.md                       # PIPA 실무 프로파일 템플릿
├── README.md                       # 이 파일
├── hooks/hooks.json
├── references/
│   ├── currency-watch.md           # 한국 개인정보 currency watch
│   └── company-profile-template.md
└── skills/
    ├── cold-start-interview/
    ├── customize/
    ├── dpa-review/
    ├── dsar-response/
    ├── matter-workspace/
    ├── pia-generation/
    ├── policy-monitor/
    ├── reg-gap-analysis/
    ├── use-case-triage/
    ├── pipa-spi-handling/          # 신규 KR 전용
    └── cross-border-transfer/      # 신규 KR 전용
```

## 비고

- DPA 검토는 양방향: 같은 스킬이 고객사 DPA(우리가 수탁자)와 벤더 DPA(우리가 위탁자)
  모두 처리. 방향 자동 감지, 모호하면 질문.
- PIA 포맷은 시드 PIA에서. 셋업에서 제공하지 않으면 PIPC 가이드라인 양식의 일반 구조
  사용 — 표준 PIA로 셋업 재실행하여 보정.
- 갭 분석(`reg-gap-analysis`)은 들어오는 규제 처리. 정책 모니터는 내부 실무 drift 처리.
  다른 변화 방향에 다른 도구.
- 정책 모니터는 sweep 동작을 위해 산출물 폴더 구성 필요(셋업 중 설정). 직접 질의 모드는
  그것 없이 동작.
- **개인정보위 결정례, 분쟁조정 결정례, 노동위 판정례, 공정위 의결례는 법망에
  포함되어 있지 않습니다.** 이런 행정 결정례를 인용해야 하는 경우 수동 첨부 또는
  PIPC 공식 사이트 직접 검색으로 보완. `docs/DATA_GAPS.md` 참조.
