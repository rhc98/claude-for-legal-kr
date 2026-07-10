# 상사·계약 실무 플러그인 (commercial-legal)

한국 상사·계약 실무를 위한 Claude Code 플러그인. 벤더계약·NDA·SaaS 약관을 매도인측/매수인측
플레이북 대조 검토, 약관규제법 불공정조항 점검, 갱신·해지통보 기한 추적, 하도급법 대금지급 보호,
소비자보호(B2C) overlay, 에스컬레이션 라우팅, 이해관계자 요약.

원본 [`anthropics/claude-for-legal`](https://github.com/anthropics/claude-for-legal)의
`commercial-legal` 플러그인(Apache 2.0)을 한국 법체계 — **민법·상법·약관규제법·하도급법·공정거래법·
표시광고법·부정경쟁방지법** — 로 포팅한 결과물입니다.

**모든 출력은 변호사 검토 전제의 초안입니다** — 인용된 조문·판례는 국가법령정보 MCP로 검증해 표시하고,
변호사가 판단해야 할 지점은 `[검토]` 플래그를 답니다. 결정적 행위(계약 서명, 레드라인 상대방 송부,
에스컬레이션 발송)는 명시적 확인 게이트를 통과해야 합니다.

> **약관규제법 무효는 단정하지 않습니다.** 조항이 약관규제법 §6–14 무효 사유에 걸리는지는
> 신의성실·공정성 balancing으로 법원·공정위가 내리는 결론입니다. 이 플러그인은 **무효 가능성을
> `[검토]`로 플래그하고 어느 조에 걸리는지 식별**할 뿐, "무효입니다"라고 결론짓지 않습니다.

## 누구를 위한 도구인가

| 역할 | 주요 워크플로우 |
|---|---|
| **계약·상사 법무 변호사** | 벤더계약·SaaS 약관 검토, 약관규제법 점검, 하도급 대금 보호, 갱신 관리 |
| **사내 법무(인하우스)** | 매도인/매수인측 플레이북 운영, 에스컬레이션, 이해관계자 요약 |
| **계약 담당·구매·영업지원** | NDA 1차 트리아지, 갱신·해지통보 기한 추적 (에스컬레이션 동반) |
| **법무법인 변호사** | 다중 의뢰인 매터 워크스페이스, 계약 검토 전반 |

## 핵심 한국법

- **민법·상법** — 계약 일반. 손해배상액 예정·위약금은 민법 §398(과다 시 법원 감액 §398②).
- **약관규제법** (약관의 규제에 관한 법률) — 정형 약관의 불공정조항 무효(§6–14). 측(매도인/매수인)과
  무관한 cross-cutting overlay.
- **하도급법** (하도급거래 공정화에 관한 법률) — 원사업자의 대금지급·부당특약 강행 의무. 계약으로 배제 불가.
- **소비자 보호** — 전자상거래법·할부거래법·방문판매법·소비자기본법. 상대방이 소비자(B2C)면 청약철회권·
  필수 고지 등 강행규정.
- **표시광고법** — 부당한 표시·광고. **부정경쟁방지법 §2** — 영업비밀(NDA의 핵심).
- 개인정보가 흐르면 **PIPA §26 위·수탁 / §28-8 국외이전** → [`privacy-legal`](../privacy-legal/) 핸드오프.

## 매도인측 / 매수인측

검토 스킬은 **먼저 회사가 어느 측인지 판정**합니다 — 상대방이 우리 제품을 사면 매도인·공급자측,
우리가 그들 것을 사면 매수인·구매자측. 측이 모든 플레이북 입장(위험 성향·책임 한도·면책 방향·해지권)을
바꿉니다. 매도인측 입장을 매수인측 계약에 적용하지 않습니다.

## 첫 실행: 콜드스타트 인터뷰

플러그인이 인터뷰로 학습합니다: 어느 측인지, 측별 플레이북 입장(책임·면책·개인정보·기간·준거법),
에스컬레이션 임계점, 하우스 스타일, NDA 트리아지 마무리 동작. 그 후 시드 계약(서명된 표준계약·약관·NDA)을
읽어 하우스 포지션을 학습합니다.

설정은 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`에 저장되며 플러그인
업데이트와 무관하게 유지됩니다. 갱신 등록부는 같은 폴더의 `renewal-register.yaml`, 이탈 로그는
`deviation-log.yaml`에 저장됩니다.

```
/commercial-legal:cold-start-interview
```

빠른 시작(2분) 또는 풀 셋업(10-15분). `--side sales|purchasing`로 한쪽 플레이북만 먼저 구축 가능.

## 커맨드

| 커맨드 | 하는 일 |
|---|---|
| `/commercial-legal:cold-start-interview` | 콜드스타트 인터뷰 (`--quick`·`--redo`·`--check-integrations`·`--side`) |
| `/commercial-legal:review [파일]` | 계약을 적합한 검토 스킬로 라우팅(매도인/매수인측 판정 후) |
| `/commercial-legal:renewal-tracker [list\|add\|edit\|show]` | 갱신·해지통보 기한 등록부 + 향후 90일 리포트 |
| `/commercial-legal:escalation-flagger [이슈]` | 에스컬레이션 매트릭스 대조 + 승인자에게 보낼 메모 초안 |
| `/commercial-legal:stakeholder-summary [검토결과]` | 법률 검토를 사업부·경영진용 요약으로 번역 |
| `/commercial-legal:amendment-history [계약+변경계약]` | 변경계약 이력 추적·현행 유효 조항 정리 |
| `/commercial-legal:review-proposals` | playbook-monitor가 생성한 플레이북 업데이트 제안 검토 |
| `/commercial-legal:subcontract-payment-protection [거래]` | **신규** — 하도급법 적용 판정 + 대금지급·부당특약 점검 |
| `/commercial-legal:consumer-protection-overlay [거래]` | **신규** — B2C 소비자 보호(청약철회·고지·표시광고) overlay |
| `/commercial-legal:matter-workspace` | 매터 관리(법무법인·다중 의뢰인 실무만) |
| `/commercial-legal:customize` | 실무 프로파일 일부 항목만 수정 |

`review` 라우터는 다음 검토 스킬로 분배합니다(직접 호출되지 않음): **vendor-agreement-review**(벤더
MSA·용역계약), **nda-review**(NDA 빠른 트리아지), **saas-msa-review**(SaaS 구독·오더폼).

## 인터랙티브 vs 백그라운드 에이전트

| 유형 | 이름 | 트리거 |
|---|---|---|
| 스케줄드(주간) | `deal-debrief` | 최근 서명 계약의 플레이북 이탈을 surface, 맥락 기록 유도 |
| 데이터 트리거 | `playbook-monitor` | 이탈 로그가 임계점(기본 12개월 5회) 도달 시 플레이북 업데이트 제안 |
| 스케줄드(주간) | `renewal-watcher` | 갱신 등록부에서 다가오는 해지통보 기한을 채널에 게시 |

세 에이전트는 자동 의사결정을 하지 않습니다 — 이탈을 기록하고, 제안을 변호사 승인에 부치고, 기한을
알릴 뿐입니다. `playbook-monitor`는 일관 수용된 면책조항이 **약관규제법 무효 위험을 normalize**하는
신호일 수 있음을 "논의 플래그"로 surface합니다.

## 빠른 시작

### 1. 셋업

```
/commercial-legal:cold-start-interview
```

준비물: 매도인/매수인 여부, 표준계약·약관·NDA 시드 문서(있으면), 에스컬레이션 체인.

### 2. 벤더 계약 검토

```
/commercial-legal:review contracts/벤더_MSA.pdf
```

매수인측 판정 → 플레이북 대조 조항별 표(법적 위험 + 사업 마찰 이중 심각도) → 약관규제법 무효
overlay `[검토]` → 외과적 레드라인 → 개인정보 흐르면 `/privacy-legal:dpa-review` 핸드오프.

### 3. 하도급 대금지급 점검 (신규)

```
/commercial-legal:subcontract-payment-protection "부품 제조를 협력사에 위탁, 납품 후 90일 어음 지급"
```

하도급법 적용 판정(위탁 유형 + 규모 — `[검토]`) → 대금 지급기한·지연이자·직접지급·어음 강행 의무 점검.

### 4. 소비자 약관 overlay (신규)

```
/commercial-legal:consumer-protection-overlay "개인 회원 대상 월 구독, 자동결제"
```

B2C/B2B 분류 게이트(`[검토]`) → 청약철회권·필수 고지·자동결제·표시광고 점검.

### 5. 갱신 관리

```
/commercial-legal:renewal-tracker list
```

해지통보 기한 밴드(🔴 0–13일 / 🟠 14–44일 / 🟡 45–89일). `renewal-watcher` 에이전트가 주간 게시.

## 학습 메커니즘

`CLAUDE.md`의 플레이북은 정적이지 않습니다. `deal-debrief`가 서명된 계약의 이탈을 기록하고,
`playbook-monitor`가 패턴이 임계점에 도달하면 플레이북 업데이트를 제안하며, 변호사가
`/commercial-legal:review-proposals`로 수용·거부·편집합니다. 플레이북은 실무와 함께 살아 움직입니다.

## 파일 구조

```
commercial-legal/
├── .claude-plugin/plugin.json
├── .mcp.json                       # 국가법령정보(korean-law) + Slack + Google Drive
├── CLAUDE.md                       # 상사·계약 실무 프로파일 템플릿
├── README.md                       # 이 파일
├── hooks/hooks.json
├── agents/
│   ├── deal-debrief.md             # 주간: 이탈 디브리프
│   ├── playbook-monitor.md         # 데이터 트리거: 플레이북 제안
│   └── renewal-watcher.md          # 주간: 갱신 알림
├── references/
│   ├── currency-watch.md           # 한국 상사·계약 currency watch
│   └── company-profile-template.md
└── skills/
    ├── cold-start-interview/
    ├── customize/
    ├── matter-workspace/
    ├── review/                     # 라우터
    ├── vendor-agreement-review/    # (review가 호출)
    ├── nda-review/                 # (review가 호출)
    ├── saas-msa-review/            # (review가 호출)
    ├── renewal-tracker/
    ├── escalation-flagger/
    ├── stakeholder-summary/
    ├── amendment-history/
    ├── review-proposals/
    ├── subcontract-payment-protection/ # 신규 KR 전용 (하도급법)
    └── consumer-protection-overlay/     # 신규 KR 전용 (소비자보호 B2C)
```

## 비고

- **약관규제법 무효·하도급법 적용·B2C 분류는 결론이 아니라 `[검토]` 플래그**입니다. 무효·위반은
  법원·공정위가, 적용 여부는 규모 요건(시행령, 변동)이 결정합니다 — 단정하지 않고 국가법령정보 현행 대조로 라우팅합니다.
- **공정위 의결례·표준약관, 한국소비자원·분쟁조정위 결정례는 국가법령정보에 포함되어 있지 않습니다.** 인용 시
  공정위·소비자원 사이트 직접 검색 또는 수동 첨부로 보완. `docs/DATA_GAPS.md` 참조.
- **준거법이 외국이거나 외국 당사자·외국 소비자가 관련되면 외국법 overlay**입니다. 한국이 디폴트
  관할이며 외국법 인용은 `[외국법 — 외국 변호사 검증 필요]`로 플래그합니다.
- 한국법에는 미국식 work-product 독트린(FRCP 26(b)(3))이 없습니다 — 문서 헤더는 비밀유지 의지의
  표시이지 공개거부의 법적 근거가 아닙니다(변호사법 §26·부정경쟁방지법 §2는 별개·좁은 근거).
- 개인정보가 관련되면 [`privacy-legal`](../privacy-legal/), AI 시스템·벤더 AI 약관은
  [`ai-governance-legal`](../ai-governance-legal/) 플러그인과 연계됩니다.
