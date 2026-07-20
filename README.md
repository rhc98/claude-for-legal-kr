# claude-for-legal-kr

> [Anthropic의 claude-for-legal](https://github.com/anthropics/claude-for-legal)
> (Apache 2.0)의 **한국 법체계 포팅**.
> 국가법령정보 MCP(`korean-law`, `https://mcp.gomdori.app/law`)를 런타임 데이터 소스로 사용해 한국 법령·판례 위에서 실제 동작합니다.

**현재 상태**: 8개 플러그인 포팅 완료 — `privacy-legal`(개인정보보호법 실무),
`ai-governance-legal`(AI 거버넌스 실무 — AI 기본법 2026.1.22. 시행 + PIPA §37-2 자동화된 결정),
`commercial-legal`(상사·계약 실무 — 약관규제법·하도급법·소비자보호),
`employment-legal`(근로·고용·인사 — 근로기준법·남녀고용평등법),
`corporate-legal`(회사법무 — 상법·자본시장법·기업결합신고),
`ip-legal`(지식재산 — 특허·상표·디자인·저작권·부정경쟁방지법·직무발명),
`litigation-legal`(소송·분쟁 — 민사·형사·행정·가사소송법·민사집행법, 기한 관리·보전처분·강제집행·형사고소),
`regulatory-legal`(규제 모니터링·입법예고 대응 — 규제기관 피드·입법예고/행정예고 대응·정책 diff·재료성 분류·국회 계류 법률안 워치). 나머지 2개 플러그인
(law-student, legal-clinic)은
[`docs/PORTING_GUIDE.md`](docs/PORTING_GUIDE.md) 가이드를 따라 동일한 패턴으로 한국화 가능합니다.

---

## 무엇을 하나

원본 `claude-for-legal`은 미국·EU 법체계 가정 위에 만들어졌습니다. 그대로 한국에서
쓰면:

- GDPR·CCPA 인용으로 PIPA 분석을 가장하고
- US `attorney work product` 헤더를 변호사·의뢰인 비밀유지가 다르게 작동하는
  한국 문서에 붙이고
- 미국 법원 판례 데이터 소스(CourtListener, Westlaw)에 의존해 한국 판례는
  접근하지 못합니다.

이 포팅은 **플러그인 구조는 그대로 두고** 다음만 교체합니다:

1. `CLAUDE.md` 실무 프로파일을 PIPA 중심으로 재작성
2. `.mcp.json`의 서구 법률 커넥터를 국가법령정보 MCP로 교체
3. 모든 `SKILL.md`의 조문 레퍼런스를 한국 법령으로 교체 + 인용 검증
   강제(`mcp__korean-law__legal_analysis {"mode": "verify_citations"}` 호출)

결과: 한국 변호사·법무팀이 PIPA 컴플라이언스, DPA(위·수탁계약) 검토, DSAR(정보주체
권리행사) 응답, PIA(개인정보 영향평가)에 그대로 쓸 수 있는 Claude Code 플러그인.

---

## 왜 국가법령정보 MCP인가

[국가법령정보 MCP(`korean-law`)](https://mcp.gomdori.app/law)는:

- 무료 — 단, 법제처 국가법령정보 Open API의 **OC 인증키가 필요**합니다
  (open.law.go.kr 가입 후 이메일로 즉시 발급, 약 1분). `?oc=<키>` 쿼리 또는
  `LAW_OC` 환경변수로 전달.
- 법제처 국가법령정보 Open API(open.law.go.kr)를 1차 소스로 사용 — 법령·판례·헌재결정·
  행정규칙·자치법규·조약·법령해석례·행정심판재결·위원회결정문을 커버합니다.
- **환각방지 인용 검증(`verify_citations`)** — 에이전트가 인용한 조문의 실존 여부 확인
- **판례 생사 확인(`cite_check` / Citator)** — 인용 판례의 폐기·변경 감지
- **통합 검색(`search_decisions`)** — 판례·헌재·조세심판·공정위·노동위 등 17개 도메인
- **위임조문 체인 조회(`legal_research`)** — 법률 → 시행령 → 시행규칙 관계 추적
- 원격 스트리머블 HTTP 엔드포인트로 라이브 동작 (`https://mcp.gomdori.app/law`)

이 플러그인은 모든 조문·판례 인용을 국가법령정보 MCP로 검증한 뒤 출력합니다. 가짜 조문은
`[unverified ✗]`로 표시됩니다.

---

## 빠른 시작

### 0. 사전 요구

- Claude Code (CLI 또는 Cowork)
- 인터넷 연결 (국가법령정보 MCP는 원격 HTTP)
- 법제처 OC 인증키 — open.law.go.kr 가입 후 이메일로 즉시 발급(무료, 약 1분)

### 1. 국가법령정보 MCP 등록

`<OC키>`를 발급받은 인증키로 교체하세요:

```bash
claude mcp add korean-law "https://mcp.gomdori.app/law?oc=<OC키>" --transport http
```

확인:

```bash
claude mcp list
# korean-law: https://mcp.gomdori.app/law?oc=... (http) - ✓ Connected

claude mcp call korean-law search_law "개인정보보호법"
# {... 법령 검색 결과 ...}
```

### 2. 이 마켓플레이스 추가

```bash
claude plugin marketplace add rhc98/claude-for-legal-kr
```

### 3. privacy-legal 설치

```bash
claude plugin install privacy-legal@claude-for-legal-kr
```

### 4. 콜드스타트 인터뷰

```
/privacy-legal:cold-start-interview
```

10-15분 인터뷰로 실무 프로파일이 `~/.claude/plugins/config/claude-for-legal-kr/privacy-legal/CLAUDE.md`에
저장됩니다. 이후 모든 스킬이 이 파일을 참조합니다.

---

## End-to-End 데모

> **시나리오**: 국내 SaaS 스타트업이 미국 AWS S3에 한국 사용자 개인정보를 저장합니다.
> PIA 의무 여부와 국외이전 컴플라이언스를 검토하세요.

```bash
# 1. 실무 프로파일 확립
/privacy-legal:cold-start-interview

# 2. 처리 활동 트리아지
/privacy-legal:use-case-triage "AWS S3 us-east-1에 한국 회원 개인정보 저장"
# → "PIA 임의, 국외이전 트리거. 다음 단계: /cross-border-transfer"

# 3. 국외이전 5개 트랙 평가 (KR 신규 스킬)
/privacy-legal:cross-border-transfer
# → "별도동의 트랙 권고 + 안전조치 체크리스트"
# → 인용된 PIPA §28-8, 시행령 §29-7~10은 모두 [verified ✓]

# 4. PIA 초안
/privacy-legal:pia-generation "AWS S3 us-east-1 회원정보 저장"
# → 한국 PIA 8개 항목 초안, 모든 조문 인용 verify 통과

# 5. AWS DPA 검토
/privacy-legal:dpa-review aws-dpa.pdf
# → PIPA §26 위·수탁 기준, 재위탁 사전동의 / 국외이전 별도동의 갭 분석
```

전체 흐름은 약 3-5분.

---

## 면책

- **국가법령정보 MCP 출력은 참고용 — 법적 효력 없음.** 1차 데이터(법제처 국가법령정보
  Open API)도 동일하며, 정본은 관보·법령정보센터 원문입니다.
- **모든 출력은 변호사 검토 전제의 초안입니다.** 변호사·의뢰인 비밀유지의 범위는
  업무 형태(사내·법무법인·공익)와 사안에 따라 다릅니다. 이 플러그인이 산출한
  문서를 외부 공개하기 전에 변호사·법무 관리자의 확인을 받으세요.
- **한국법에는 미국식 "attorney work product" 독트린(FRCP 26(b)(3))이 존재하지 않습니다.**
  "PRIVILEGED & CONFIDENTIAL" 표기는 비밀유지 의지 표시일 뿐이며, 그 자체가 공개
  거부 근거가 되지 않습니다. 자세한 내용은 `plugins/privacy-legal/CLAUDE.md`의
  Outputs 섹션 참조.
- **국가법령정보 MCP는 OC 인증키가 필요하며, 호출 한도는 법제처 국가법령정보
  Open API 정책을 따릅니다.** 별도의 고정 분당 한도를 여기서 단정하지 않습니다.
  429 응답 시 지수 백오프 후 사용자 알림으로 처리됩니다.

---

## 디렉토리 구조

```
claude-for-legal-kr/
├── LICENSE                              # Apache 2.0 (원본)
├── NOTICE                               # 원본 attribution + 한국화 기여
├── README.md                            # 이 파일
├── docs/
│   ├── PORTING_GUIDE.md                 # 남은 플러그인 포팅 가이드
│   ├── LAW_MCP_INTEGRATION.md           # 국가법령정보 MCP 사용 패턴
│   └── DATA_GAPS.md                     # 국가법령정보 미커버 데이터(등록원부 등)
├── plugins/
│   ├── privacy-legal/                   # ★ 1순위 풀세트 (PIPA)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                    # 국가법령정보 + Slack + Google Drive
│   │   ├── CLAUDE.md                    # PIPA 실무 프로파일 템플릿
│   │   ├── README.md
│   │   ├── hooks/hooks.json
│   │   ├── references/
│   │   │   ├── currency-watch.md        # 한국 개인정보 currency watch
│   │   │   └── company-profile-template.md
│   │   └── skills/
│   │       ├── cold-start-interview/    # 9개 기존 스킬 한국화
│   │       ├── customize/
│   │       ├── dpa-review/
│   │       ├── dsar-response/
│   │       ├── matter-workspace/
│   │       ├── pia-generation/
│   │       ├── policy-monitor/
│   │       ├── reg-gap-analysis/
│   │       ├── use-case-triage/
│   │       ├── pipa-spi-handling/       # 신규 KR 전용
│   │       └── cross-border-transfer/   # 신규 KR 전용
│   ├── ai-governance-legal/             # ★ 2순위 풀세트 (AI 기본법 + PIPA §37-2)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                    # 국가법령정보 + Slack + Google Drive
│   │   ├── CLAUDE.md                    # AI 거버넌스 실무 프로파일 템플릿
│   │   ├── README.md
│   │   ├── hooks/hooks.json
│   │   ├── references/
│   │   │   └── currency-watch.md        # 한국 AI 거버넌스 currency watch
│   │   └── skills/
│   │       ├── cold-start-interview/    # 10개 기존 스킬 한국화
│   │       ├── customize/
│   │       ├── matter-workspace/
│   │       ├── use-case-triage/
│   │       ├── ai-inventory/
│   │       ├── aia-generation/
│   │       ├── vendor-ai-review/
│   │       ├── policy-starter/
│   │       ├── policy-monitor/
│   │       ├── reg-gap-analysis/
│   │       ├── automated-decision-37-2/ # 신규 KR 전용 (PIPA §37-2)
│   │       └── generative-ai-labeling/  # 신규 KR 전용 (AI 기본법 표시의무)
│   └── commercial-legal/                # ★ 3순위 풀세트 (약관규제법·하도급법·소비자보호)
│       ├── .claude-plugin/plugin.json
│       ├── .mcp.json                    # 국가법령정보 + Slack + Google Drive
│       ├── CLAUDE.md                    # 상사·계약 실무 프로파일 템플릿
│       ├── README.md
│       ├── hooks/hooks.json
│       ├── agents/                      # 신규 요소: 스케줄드·데이터 트리거 에이전트
│       │   ├── deal-debrief.md
│       │   ├── playbook-monitor.md
│       │   └── renewal-watcher.md
│       ├── references/
│       │   ├── currency-watch.md        # 한국 상사·계약 currency watch
│       │   └── company-profile-template.md
│       └── skills/
│           ├── cold-start-interview/    # 12개 기존 스킬 한국화
│           ├── customize/
│           ├── matter-workspace/
│           ├── review/
│           ├── vendor-agreement-review/
│           ├── nda-review/
│           ├── saas-msa-review/
│           ├── renewal-tracker/
│           ├── escalation-flagger/
│           ├── stakeholder-summary/
│           ├── amendment-history/
│           ├── review-proposals/
│           ├── subcontract-payment-protection/ # 신규 KR 전용 (하도급법)
│           └── consumer-protection-overlay/     # 신규 KR 전용 (소비자보호 B2C)
│   ├── employment-legal/                # ★ 4순위 풀세트 (근로기준법·남녀고용평등법)
│   │   ├── .claude-plugin/ · .mcp.json · CLAUDE.md · README.md · hooks/ · references/
│   │   └── skills/                      # 19개 스킬 (해고·근로자성·임금·괴롭힘 조사·취업규칙 등)
│   ├── corporate-legal/                 # ★ 5순위 풀세트 (상법·자본시장법·기업결합신고)
│   │   ├── .claude-plugin/ · .mcp.json · CLAUDE.md(모듈형) · README.md · hooks/ · references/
│   │   ├── agents/dataroom-watcher.md
│   │   └── skills/                      # 16개 스킬 (M&A 실사·표검토·이사회·주총·법인관리·공시)
│   └── ip-legal/                        # ★ 6순위 풀세트 (특허·상표·디자인·저작권·부정경쟁방지법)
│       ├── .claude-plugin/ · .mcp.json · CLAUDE.md · README.md · hooks/ · references/ip-currency-watch.md
│       ├── agents/ip-renewal-watcher.md
│       └── skills/                      # 클리어런스·FTO·침해·경고장·테이크다운·OSS·직무발명·영업비밀·포트폴리오
├── .claude-plugin/marketplace.json
└── scripts/
    └── install-korean-law-mcp.sh
```

---

## 기여

남은 2개 플러그인(law-student, legal-clinic)을
한국화하고 싶으신가요?

[`docs/PORTING_GUIDE.md`](docs/PORTING_GUIDE.md) — privacy-legal MVP에서 추출한
포팅 패턴(8단계 체크리스트 + 국가법령정보 통합 코드 스니펫 + CLAUDE.md 리라이트 템플릿).
한 플러그인 완전 포팅에 약 2-3주(풀타임 1명 기준) 예상.

이슈·PR 환영. 단, 한국 변호사·법무 실무자의 사전 검토를 거친 변경만
머지합니다(법령 해석 오류 방지).

---

## 라이선스

Apache License 2.0. 원본 `claude-for-legal`과 동일. 자세한 내용은
[LICENSE](LICENSE) 및 [NOTICE](NOTICE) 참조.

---

## 참고

- 원본 레포: https://github.com/anthropics/claude-for-legal
- 국가법령정보 MCP: https://mcp.gomdori.app/law
- 법제처 국가법령정보 Open API (OC 인증키 발급): https://open.law.go.kr
- 법제처 법령정보센터: https://www.law.go.kr
- 국회 의안정보시스템: https://likms.assembly.go.kr/bill
- 개인정보보호위원회: https://www.pipc.go.kr
