# claude-for-legal-kr

> [Anthropic의 claude-for-legal](https://github.com/anthropics/claude-for-legal)
> (Apache 2.0)의 **한국 법체계 포팅**.
> 법망 MCP(`https://api.beopmang.org/mcp`)를 런타임 데이터 소스로 사용해 한국 법령·판례 위에서 실제 동작합니다.

**현재 상태**: 1순위 플러그인 `privacy-legal` (개인정보보호법 실무) MVP. 다른 9개
플러그인은 [`docs/PORTING_GUIDE.md`](docs/PORTING_GUIDE.md) 가이드를 따라 동일한
패턴으로 한국화 가능합니다.

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
2. `.mcp.json`의 서구 법률 커넥터를 법망 MCP로 교체
3. 모든 `SKILL.md`의 조문 레퍼런스를 한국 법령으로 교체 + 인용 검증
   강제(`mcp__beopmang__verify` 호출)

결과: 한국 변호사·법무팀이 PIPA 컴플라이언스, DPA(위·수탁계약) 검토, DSAR(정보주체
권리행사) 응답, PIA(개인정보 영향평가)에 그대로 쓸 수 있는 Claude Code 플러그인.

---

## 왜 법망인가

[법망(Beopmang)](https://api.beopmang.org)은:

- 무료, 인증키 없음
- 분당 100회 제한 (IP/클라이언트 단위로 추정 — 각 사용자가 자기 quota 사용)
- 법령 6,000건 / 판례 172,000건 / 헌재결정 37,000건 / 행정규칙 24,000건 /
  자치법규 159,000건 / 의안 114,000건 / 조약 4,000건 (2026년 3월 기준)
- 조문 검색 5ms / 판례 검색 9ms
- **환각방지 인용 검증** — 에이전트가 인용한 조문·판례 존재 여부 확인
- **위임조문 체인 조회** — 법률 → 시행령 → 시행규칙을 1회 요청으로
- 법제처·국회 Open API 1차 데이터 동기화(매주 토요일)

이 플러그인은 모든 조문·판례 인용을 법망으로 검증한 뒤 출력합니다. 가짜 조문은
`[unverified ✗]`로 표시됩니다.

---

## 빠른 시작

### 0. 사전 요구

- Claude Code (CLI 또는 Cowork)
- 인터넷 연결 (법망 MCP는 원격 HTTP)

### 1. 법망 MCP 등록

```bash
claude mcp add beopmang https://api.beopmang.org/mcp --transport http
```

확인:

```bash
claude mcp list
# beopmang: https://api.beopmang.org/mcp (http) - ✓ Connected

claude mcp call beopmang law search "개인정보보호법"
# {... 법령 검색 결과 ...}
```

### 2. 이 마켓플레이스 추가

```bash
claude plugin marketplace add <user-or-org>/claude-for-legal-kr
```

### 3. privacy-legal 설치

```bash
claude plugin install privacy-legal@claude-for-legal-kr
```

### 4. 콜드스타트 인터뷰

```
/privacy-legal:cold-start-interview
```

10-15분 인터뷰로 실무 프로파일이 `~/.claude/plugins/config/claude-for-legal/privacy-legal/CLAUDE.md`에
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

- **법망 출력은 참고용 — 법적 효력 없음.** 1차 데이터(법제처·국회 Open API)도
  동일하며, 정본은 관보·법령정보센터 원문입니다.
- **모든 출력은 변호사 검토 전제의 초안입니다.** 변호사·의뢰인 비밀유지의 범위는
  업무 형태(사내·법무법인·공익)와 사안에 따라 다릅니다. 이 플러그인이 산출한
  문서를 외부 공개하기 전에 변호사·법무 관리자의 확인을 받으세요.
- **한국법에는 미국식 "attorney work product" 독트린(FRCP 26(b)(3))이 존재하지 않습니다.**
  "PRIVILEGED & CONFIDENTIAL" 표기는 비밀유지 의지 표시일 뿐이며, 그 자체가 공개
  거부 근거가 되지 않습니다. 자세한 내용은 `plugins/privacy-legal/CLAUDE.md`의
  Outputs 섹션 참조.
- **법망 MCP의 분당 100회 제한은 공식 문서에 명시되지 않음** — IP/클라이언트
  단위로 추정되나 정책 변경 가능성 있음. 429 응답 시 지수 백오프 후 사용자
  알림으로 처리됩니다.

---

## 디렉토리 구조

```
claude-for-legal-kr/
├── LICENSE                              # Apache 2.0 (원본)
├── NOTICE                               # 원본 attribution + 한국화 기여
├── README.md                            # 이 파일
├── docs/
│   ├── PORTING_GUIDE.md                 # 다른 9개 플러그인 포팅 가이드
│   ├── BEOPMANG_INTEGRATION.md          # 법망 MCP 사용 패턴
│   └── DATA_GAPS.md                     # 법망 미커버 데이터(행정 결정례 등)
├── plugins/
│   └── privacy-legal/                   # ★ MVP 풀세트
│       ├── .claude-plugin/plugin.json
│       ├── .mcp.json                    # 법망 + Slack + Google Drive
│       ├── CLAUDE.md                    # PIPA 실무 프로파일 템플릿
│       ├── README.md
│       ├── hooks/hooks.json
│       ├── references/
│       │   ├── currency-watch.md        # 한국 개인정보 currency watch
│       │   └── company-profile-template.md
│       └── skills/
│           ├── cold-start-interview/    # 9개 기존 스킬 한국화
│           ├── customize/
│           ├── dpa-review/
│           ├── dsar-response/
│           ├── matter-workspace/
│           ├── pia-generation/
│           ├── policy-monitor/
│           ├── reg-gap-analysis/
│           ├── use-case-triage/
│           ├── pipa-spi-handling/       # 신규 KR 전용
│           └── cross-border-transfer/   # 신규 KR 전용
├── .claude-plugin/marketplace.json
└── scripts/
    └── install-beopmang-mcp.sh
```

---

## 기여

다른 9개 플러그인(commercial-legal, corporate-legal, employment-legal,
regulatory-legal, ai-governance-legal, ip-legal, litigation-legal,
law-student, legal-clinic)을 한국화하고 싶으신가요?

[`docs/PORTING_GUIDE.md`](docs/PORTING_GUIDE.md) — privacy-legal MVP에서 추출한
포팅 패턴(8단계 체크리스트 + 법망 통합 코드 스니펫 + CLAUDE.md 리라이트 템플릿).
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
- 법망 API: https://api.beopmang.org
- 법망 OpenAPI 명세: https://api.beopmang.org/openapi.json
- 법제처 법령정보센터: https://www.law.go.kr
- 국회 의안정보시스템: https://likms.assembly.go.kr/bill
- 개인정보보호위원회: https://www.pipc.go.kr
