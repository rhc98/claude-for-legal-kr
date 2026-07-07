# corporate-legal — 한국 회사법무 플러그인

> [Anthropic claude-for-legal `corporate-legal`](https://github.com/anthropics/claude-for-legal)의
> **한국 법체계 포팅**. 국가법령정보 MCP(`https://mcp.gomdori.app/law`)로 상법·자본시장법·외감법·공정거래법
> 위에서 동작.

사내 회사법무 워크플로우를 4개 모듈로 다룬다 — **M&A 딜 / 이사회·간사 / 상장사 / 법인관리**. 본인 역할에
해당하는 모듈만 활성화한다. 콜드스타트 인터뷰가 모듈형이라 활성 모듈별로 타겟 질문만 하고 관련 섹션만
실무 프로파일에 쓴다.

**모든 산출물은 변호사 검토 전제의 초안이다 — 인용·플래그·게이트를 거치되 법적 결론이 아니다.**

---

## ✅ 현재 상태: 전 스킬 포팅 완료 (Phase A~E)

corporate-legal 플러그인의 **모든 스킬 포팅 완료** — 인프라 3 + M&A 핵심 6 + 이사회 2 + 법인관리 1 +
M&A 부가 2 + KR 신규 상장사/주총 2 = **16개 스킬 + `dataroom-watcher` 에이전트 1개**. 남은 것은
Phase F(E2E 런타임 검증 — 국가법령정보 MCP 복구 후 인용 verify). 상세는 [`skills/ROADMAP.md`](skills/ROADMAP.md) 참조.

상류는 미국 다주 관할 + 미국 회사법(델라웨어) + SEC 공시가 전제다. 한국 포팅의 핵심 재맥락화:

- 미국 "설립 주(델라웨어)" + "registered agent(CT Corp)" → **상장/비상장 + 자본금 규모 + 상업등기(본점 관할 등기소)**
- 미국 M&A의 **HSR 사전신고** → 한국 **공정거래법 기업결합신고(§11)** (KR 신규 스킬 `merger-control-filing`)
- 미국식 **unanimous written consent** → 한국 상법상 제한적 **서면결의**(소규모회사 주총 §363④·정관상 이사회 화상회의 §391②)
- 이사회 의사록 → 상법 **§391-3** 기재사항 + **의사록 공증**(등기 첨부)

---

## 누구를 위한 것인가

| 역할 | 활성 모듈 |
|---|---|
| **사내 M&A 법무** | M&A |
| **법인·이사회 간사** | 이사회·간사 |
| **상장사 GC** | M&A + 상장사 + 이사회·간사 |
| **비상장사 GC** | M&A + 이사회·간사 + 법인관리 |
| **법무 운영·단독 GC** | 해당되는 것 — 조합 가능 |

---

## 첫 실행

```
/corporate-legal:cold-start-interview
```

모듈 선택 후 활성 영역별 짧은 타겟 인터뷰. 활성 모듈 섹션만 담은
`~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/CLAUDE.md` 작성. 플러그인 업데이트에도 유지.

딜 단위 설정 (M&A 모듈):

```
/corporate-legal:cold-start-interview --new-deal
```

---

## 계획된 스킬 (ROADMAP 기준)

| 스킬 | 모듈 | 용도 | 상태 |
|---|---|---|---|
| cold-start-interview | All | 모듈형 인터뷰 — 활성 섹션만 작성 | ✅ 포팅 완료 (B) |
| customize / matter-workspace | All | 실무 프로파일 부분 수정 / 매터 격리 | ✅ 포팅 완료 (B) |
| diligence-issue-extraction | M&A | 실사 문서 → 한국 실사 카테고리별 이슈 메모 | ✅ 포팅 완료 (C) |
| tabular-review | M&A | 문서세트 표 검토, 셀별 인용, xlsx·csv·md 출력 | ✅ 포팅 완료 (C) |
| material-contract-schedule | M&A | 진술보장 정의 기준 중요계약 공개목록 | ✅ 포팅 완료 (C) |
| closing-checklist | M&A | 종결 체크리스트 — 기업결합신고·주총특별결의·채권자보호 | ✅ 포팅 완료 (C) |
| deal-team-summary | M&A | 계층 브리프 (경영진/딜리드/실무) | ✅ 포팅 완료 (C) |
| **merger-control-filing** | M&A | 공정거래법 기업결합신고 (KR 신규) | ✅ 신규 완료 (C) |
| ai-tool-handoff | M&A | Luminance/Kira 핸드오프 (옵션) | ✅ 포팅 완료 (D) |
| integration-management | M&A | 종결 후 통합(PMI)·승계동의·필수동의 트래커 | ✅ 포팅 완료 (D) |
| board-minutes | 이사회 | 이사회 의사록 (§391-3·공증) | ✅ 포팅 완료 (D) |
| written-consent | 이사회 | 서면결의 (한국 제한 반영) + 선례검색 | ✅ 포팅 완료 (D) |
| **shareholder-meeting** | 이사회 | 주주총회 운영 (KR 신규) | ✅ 신규 완료 (D/E) |
| entity-compliance | 법인관리 | 상업등기 변경등기 기한·법인 컴플라이언스 트래커 | ✅ 포팅 완료 (D) |
| **public-disclosure** | 상장사 | 자본시장법·거래소 공시 (KR 신규, 상류 미출시) | ✅ 신규 완료 (E) |
| dataroom-watcher (agent) | M&A | VDR 신규 업로드 모니터·종결 체크 | ✅ 포팅 완료 (D) |

---

## 통합

`.mcp.json`에 포함:

- **국가법령정보(korean-law)** — 한국 법령·판례 조회·검증. **1순위.** 없으면 모든 인용이 `[모델 지식 — 검증 필요]`.
- **Slack** — 딜팀 브리핑·알림·에스컬레이션
- **Google Drive** — 의사록·서면결의 선례·실사 요청목록·정관 로드
- **Box** — 데이터룸(VDR)·문서 관리. Intralinks·Datasite 등은 URL 확보 시 추가.

---

## 국가법령정보 데이터 갭 (corporate 특유)

국가법령정보가 커버하지 않는 회사법무 자료는 사용자 제공 + 태그로 처리한다([`../../docs/DATA_GAPS.md`](../../docs/DATA_GAPS.md)):

- **공정위 기업결합 심사 의결례** → `[공정위 의결 — 직접 검증 필요]`
- **금융위·증선위·금감원 공시/제재 의결** → `[금융당국 의결 — 직접 검증 필요]`
- **한국거래소 상장규정·공시규정**(자율규정) → `[거래소 규정 — 직접 검증 필요]`
- **상업등기 등기선례·등기예규** → `[등기선례 — 검증 필요]`
- ✓ 잘 커버: 상법·자본시장법·외부감사법·상업등기법·공정거래법 — 법령 + 법원 판례

---

## 라이선스

Apache License 2.0. 원본 `claude-for-legal`과 동일. [`../../LICENSE`](../../LICENSE)·[`../../NOTICE`](../../NOTICE) 참조.
