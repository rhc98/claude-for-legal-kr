# AI 거버넌스 실무 플러그인 (ai-governance-legal)

한국 AI 거버넌스 실무를 위한 Claude Code 플러그인. AI 활용사례 트리아지, AI 시스템
인벤토리 관리, AI 영향평가(AIA) 작성, 벤더 AI 약관 검토, AI 정책 초안·현행화.

원본 [`anthropics/claude-for-legal`](https://github.com/anthropics/claude-for-legal)의
`ai-governance-legal` 플러그인(Apache 2.0)을 한국 법체계 — **AI 기본법(2026.1.22. 시행)** +
**개인정보보호법 §37-2(자동화된 결정)** — 로 포팅한 결과물입니다.

> **⚠️ AI 기본법은 신법입니다.** 「인공지능 발전과 신뢰 기반 조성 등에 관한 기본법」은
> 2026.1.22. 막 시행됐고 시행령·과기정통부 고시가 정착 중입니다. 이 플러그인은 **AI 기본법
> 조문 번호를 하드코딩하지 않고** 모든 인용을 국가법령정보 MCP로 조회·검증한 뒤 표시하며, 미검증
> 인용은 `[AI 기본법 현행 텍스트 대조 — 검증 필요]`로 플래그합니다.

**모든 출력은 변호사 검토 전제의 초안입니다** — 인용된 조문·판례는 국가법령정보 MCP로 검증해
표시하고, 변호사가 판단해야 할 지점은 `[검토]` 플래그를 답니다. 결정적 행위(활용사례
승인·거부, 정보주체 자동화 결정 응답 송부, 벤더 계약 서명, 규제 당국 제출)는 명시적 확인
게이트를 통과해야 합니다.

## 누구를 위한 도구인가

| 역할 | 주요 워크플로우 |
|---|---|
| **AI 거버넌스·법무 변호사** | 활용사례 분류, AIA 결재, 벤더 AI 약관 검토, 정책 갭 분석 |
| **개인정보 보호책임자(CPO)·AI 위험 담당** | AI 시스템 인벤토리, §37-2 자동화 결정 대응 |
| **제품 법무 카운슬** | 신규 AI 기능 트리아지·영향평가, 생성형 표시의무 점검 |
| **컴플라이언스·운영** | 활용사례 1차 트리아지 (에스컬레이션 동반) |

## AI 기본법 ↔ PIPA 역할 분담

- **AI 기본법** — 사업자 역할(AI개발사업자/AI이용사업자), 고영향 인공지능 의무, 생성형 AI
  표시의무, 고영향 AI 영향평가. 소관: 과학기술정보통신부.
- **PIPA §37-2** — 완전 자동화된 결정(AI 포함)에 대한 정보주체의 거부권·설명요구권. 소관: PIPC.
- 두 법은 **중첩되지만 별개**입니다. AI 채용·대출심사 등은 AI 기본법 고영향 영역이면서 PIPA
  §37-2 자동화 결정에 동시 해당할 수 있고, 각각 의무를 충족해야 합니다. AI 영향평가(AIA)와
  개인정보 영향평가(PIA, privacy-legal 플러그인)도 별개·보완 관계입니다.

## 첫 실행: 콜드스타트 인터뷰

플러그인이 인터뷰로 학습합니다: 어떤 AI 시스템을 운영하는지, 시스템별 사업자 역할·유형은
무엇인지, 활용사례 등기부·레드라인·거버넌스 등급, 벤더 AI 표준, 에스컬레이션 체인. 그 후 시드
문서(AI 정책, 참조 영향평가, 핵심 벤더 AI 계약)를 읽어 하우스 스타일을 학습합니다.

설정은 `~/.claude/plugins/config/claude-for-legal-kr/ai-governance-legal/CLAUDE.md`에 저장되며
플러그인 업데이트와 무관하게 유지됩니다. 시스템별 분류는 같은 폴더의 `ai-systems.yaml`에 저장됩니다.

```
/ai-governance-legal:cold-start-interview
```

## 커맨드

| 커맨드 | 하는 일 |
|---|---|
| `/ai-governance-legal:cold-start-interview` | 콜드스타트 인터뷰 |
| `/ai-governance-legal:use-case-triage [활용사례]` | 승인 / 조건부 / 거부 분류 + 조건·거버넌스 등급 |
| `/ai-governance-legal:ai-inventory [list\|add\|edit\|classify\|show]` | AI 시스템별 인벤토리·역할·유형 분류 |
| `/ai-governance-legal:aia-generation [시스템]` | 하우스 스타일로 AI 영향평가 작성 |
| `/ai-governance-legal:vendor-ai-review [파일]` | 벤더 AI 약관 검토(학습데이터·책임·감사·통지) |
| `/ai-governance-legal:policy-starter` | AI/이용정책 초안 생성 |
| `/ai-governance-legal:reg-gap-analysis [규제]` | 새 규제 vs 현행 AI 정책·실무 diff |
| `/ai-governance-legal:policy-monitor` | 정책 drift 정기 sweep, 또는 신규 실무 직접 질의 |
| `/ai-governance-legal:automated-decision-37-2` | **신규** — PIPA §37-2 자동화된 결정 거부·설명요구 대응 |
| `/ai-governance-legal:generative-ai-labeling` | **신규** — AI 기본법 생성형 AI 표시의무 컴플라이언스 |
| `/ai-governance-legal:matter-workspace` | 매터 관리(법무법인·다중 의뢰인 실무만) |
| `/ai-governance-legal:customize` | 실무 프로파일 일부 항목만 수정 |

## 빠른 시작

### 1. 셋업

```
/ai-governance-legal:cold-start-interview
```

준비물: 운영 중인 AI 시스템 목록, AI/이용정책(있으면), 핵심 벤더 AI 계약.

### 2. 신규 AI 활용사례 트리아지

```
/ai-governance-legal:use-case-triage "영업팀이 리드를 AI로 자동 스코어링하고 싶어함"
```

출력: 승인 / 조건부 / 거부 — 조건 표, 거버넌스 등급, AI 기본법 고영향 영역·PIPA §37-2·외국법
overlay 교차 점검, 이어서 AIA를 같은 대화에서 시작할지 제안.

### 3. AI 시스템 인벤토리 분류

```
/ai-governance-legal:ai-inventory classify chatbot-v2
```

시스템별 역할(AI개발/AI이용)·유형(고영향/생성형/일반) 분류, PIPA §37-2 nexus·외국 nexus 기록.
**의무는 표에서 도출하지 않고** 변호사 검토로 라우팅.

### 4. 벤더 AI 약관 검토

```
/ai-governance-legal:vendor-ai-review vendor-ai-terms.pdf
```

학습데이터 이용·재이용, AI 산출물 책임·면책, 모델 변경 통지, 감사권을 우리 표준 대조.
개인정보가 흐르면 PIPA §26·§28-8 중첩 플래그 + `/privacy-legal:dpa-review` 핸드오프.

### 5. 자동화 결정 대응 (PIPA §37-2)

```
/ai-governance-legal:automated-decision-37-2 "정보주체가 AI 대출거절에 설명요구서를 보냄"
```

3요건(완전 자동화·중대 영향·예외 미해당) 판정 → 처리자 의무 점검 또는 응답 초안.

## 학습 메커니즘

`CLAUDE.md`의 실무 프로파일과 `ai-systems.yaml` 인벤토리는 정적이지 않습니다 — 플러그인을
쓸수록 개선됩니다. 스킬은 출력이 어떤 디폴트를 사용했는지 알려주어 튜닝하도록 안내합니다.
`policy-monitor`는 정책과 실무의 drift를 감지하고, AI 기본법 하위 고시·시행령의 변화는
`reg-gap-analysis`로 라우팅합니다.

## 파일 구조

```
ai-governance-legal/
├── .claude-plugin/plugin.json
├── .mcp.json                       # 국가법령정보(korean-law) + Slack + Google Drive
├── CLAUDE.md                       # AI 거버넌스 실무 프로파일 템플릿
├── README.md                       # 이 파일
├── hooks/hooks.json
├── references/
│   └── currency-watch.md           # 한국 AI 거버넌스 currency watch
└── skills/
    ├── cold-start-interview/
    ├── customize/
    ├── matter-workspace/
    ├── use-case-triage/
    ├── ai-inventory/
    ├── aia-generation/
    ├── vendor-ai-review/
    ├── policy-starter/
    ├── policy-monitor/
    ├── reg-gap-analysis/
    ├── automated-decision-37-2/    # 신규 KR 전용 (PIPA §37-2)
    └── generative-ai-labeling/     # 신규 KR 전용 (AI 기본법 표시의무)
```

## 비고

- **AI 기본법은 2026.1.22. 시행 신법**입니다. 조문·시행령·고시가 빠르게 추가되므로 모든 인용은
  국가법령정보 MCP 또는 과기정통부 고시 대조가 필요하며, `references/currency-watch.md`를 자주 확인하세요.
- **역할·유형은 회사가 아닌 AI 시스템별로 판정**합니다. 회사 수준 단일 라벨은 틀린 답을 만듭니다.
  인벤토리는 변호사를 위한 등기부이고, 의무 분석은 변호사가 소유합니다(자동 도출하지 않음).
- **고영향 AI 영향평가가 강행 의무인지 노력의무인지**는 현행 조문 대조가 필요한 핵심 판단
  지점입니다(`aia-generation`이 `[검토]`로 플래그).
- **EU AI Act·미국 주 AI법은 외국법 overlay**로만 다룹니다. 한국이 디폴트 관할이며 외국법
  인용은 `[외국법 — 외국 변호사 검증 필요]`로 플래그해 외국 변호사 자문을 권고합니다.
- **과기정통부·PIPC AI 가이드라인, 행정 결정례는 국가법령정보에 포함되어 있지 않습니다.** 인용 시
  사이트 직접 검색 또는 수동 첨부로 보완. `docs/DATA_GAPS.md` 참조.
- 개인정보가 관련되면 [`privacy-legal`](../privacy-legal/) 플러그인과 연계됩니다(PIA, DPA,
  국외이전, 정보주체 권리행사).
