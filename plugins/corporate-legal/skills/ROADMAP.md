# corporate-legal 스킬 포팅 로드맵

**현재 상태: Phase A~E 완료 — 전 스킬 포팅.** 업스트림 13스킬 + KR 신규 3스킬(merger-control-filing·
shareholder-meeting·public-disclosure) + dataroom-watcher 에이전트. 남은 것은 Phase F(E2E 런타임 검증 —
국가법령정보 복구 후). 기준 템플릿은 `../../commercial-legal/skills/`, 상류 원본은
`anthropics/claude-for-legal/corporate-legal/skills/`.

상류는 **미국 다주(多州) 관할 + 미국 회사법(델라웨어 설립) + SEC 공시**가 전제다. 한국은
**전국 단일 상법 관할**이며 회사법이 상법 회사편에 통합되어 있다. 미국의 "어느 주에 설립?(Delaware)" +
"registered agent(CT Corp)" 축은 한국에서 **상장/비상장 + 자본금 규모 + 상업등기(본점 관할 등기소)** 축으로
매핑된다. 미국 M&A의 HSR 사전신고는 한국 **공정거래법 기업결합신고(§11)**로, 미국식 "unanimous written
consent" 관행은 한국 상법상 제한적인 **서면결의**(소규모회사 주총 §363④·정관상 이사회 화상회의 §391②)로
재맥락화한다 — 1:1 매핑이 안 되는 지점은 단정하지 말고 `[검토]` 플래그.

상류는 4개 모듈로 구성된다: **M&A / 이사회·간사(Board & Secretary) / 상장사(Public Company) /
법인관리(Entity Management)**. cold-start-interview가 모듈별로 활성화하고 해당 섹션만 실무 프로파일에 쓴다.

## 포팅 매핑

| 상류 스킬 | 모듈 | KR 포팅 | Phase | 핵심 재맥락화 |
|---|---|---|---|---|
| cold-start-interview | All | 1:1 + KR | B ✅ | 모듈 선택형. "state footprint" → **상장/비상장·자본금·법인 수·계열 footprint** + 모듈별 타겟 인터뷰 |
| customize | All | 1:1 | B ✅ | CLAUDE.md 부분 수정 (모듈 섹션 맵) |
| matter-workspace | All | 1:1 | B ✅ | commercial·employment과 동일 패턴. "매터" = 한 딜 / 한 이사회 사이클 / 한 법인. M&A 정보장벽 격리 |
| diligence-issue-extraction | M&A | 재작성 | C ✅ | 한국 실사 카테고리(회사일반·등기, 재무·세무, **인사·노동(근로관계 승계)**, 계약, 인허가, 소송, IP, 부동산, **공정거래(기업결합·내부거래)**, 환경, 우발채무). 중요성 임계점 적용 |
| tabular-review (+refs) | M&A | 재작성 | C ✅ | 문서세트 표 검토·셀별 인용. `ma-diligence-columns` 한국 실사 컬럼화. `excel-output`·`gsheets-output` 출력 패턴 재사용 |
| material-contract-schedule | M&A | 재작성 | C ✅ | 공개목록(disclosure schedule) — SPA 진술보장 정의 기준 중요계약 스케줄. COC·양도제한 조항 추출 |
| closing-checklist | M&A | 재작성 | C ✅ | 선행조건·**기업결합신고 승인·주총 특별결의(영업양도 §374·합병 §522)·채권자보호절차(§527-5)·반대주주 주식매수청구권(§522-3)**. 실사·스케줄에서 self-update |
| deal-team-summary | M&A | 재맥락화 | C ✅ | 계층 브리프(경영진/딜리드/실무) — commercial `stakeholder-summary` 패턴 재사용 |
| **merger-control-filing** (KR 신규) | M&A | 신규 | C ✅ | 공정거래법 §11 **기업결합신고**(규모별 사전/사후, 신고대상·기한·간이/일반). US HSR 대응물. **공정위 의결례 data gap 대응** |
| ai-tool-handoff | M&A | 1:1(옵션) | D ✅ | Luminance/Kira 핸드오프 — 그대로 또는 KR 도구 매핑. 도구 없으면 직접 추출로 폴백 |
| integration-management | M&A | 재작성 | D ✅ | 종결 후 통합(PMI) Day1/30/90/180, 계약이전 **승계동의(COC·양도금지)**, 필수동의 트래커. 합병 시 권리·의무 포괄승계 |
| board-minutes | Board | 재작성 | D ✅ | 이사회 의사록 — 상법 **§391-3**(의안·경과·결과·반대자와 이유 기재, 출석이사 기명날인·서명), **의사록 공증**(등기 첨부용) |
| written-consent | Board | **재작성(최대)** | D ✅ | **한국엔 미국식 unanimous written consent가 제한적.** 이사회는 원칙 회의체(정관상 화상회의 §391②), 주주 서면결의는 **소규모회사 §363④·1인회사**에 한정. 선례검색. 1:1 안 되는 부분 `[검토]` |
| entity-compliance | Entity | **재작성(최대)** | D ✅ | "state filing + CT Corp registered agent" → **상업등기 변경등기 기한(본점 2주·지점 3주, 해태 과태료 §635)·정기주총·재무제표 승인·사업보고서·법인세**. 등기소 관할. registered agent 개념 없음 |
| **shareholder-meeting** (KR 신규) | Board | 신규 | D/E ✅ | 주주총회 운영(소집통지 기한·전자투표·전자위임장·결의요건(보통/특별)·검사인·집중투표). 한국 거버넌스 핵심 워크플로우 |
| **public-disclosure** (KR 신규) | 상장사 | 신규 | E ✅ | 자본시장법 공시(수시공시·주요사항보고서·공정공시), 임원·주요주주 소유상황보고(§173). **상류 Public Company 모듈은 미출시 → KR이 선도** |
| dataroom-watcher (agent) | M&A | 재맥락화 | D ✅ | VDR 신규 업로드 모니터·고우선 카테고리 플래그·종결 체크 — commercial `agents/` 패턴 재사용 |

## KR 신규 스킬 요약

타 플러그인(privacy의 `cross-border-transfer`, commercial의 `subcontract-payment-protection` 등)처럼
한국 실무 고유 영역을 신규 추가:

1. **merger-control-filing** (M&A) — 공정거래법 기업결합신고. 한국 M&A 필수 절차, US HSR 대응물.
2. **shareholder-meeting** (Board) — 주주총회 운영. 한국 거버넌스 핵심.
3. **public-disclosure** (상장사) — 자본시장법·거래소 공시. 상류 미출시 모듈을 KR이 선도.

## 국가법령정보 데이터 갭 (corporate 특유 — `docs/DATA_GAPS.md` 보강 필요)

- **거래소 상장규정**(유가증권시장·코스닥·코넥스) — 한국거래소 자율규정, 국가법령정보 미커버 → `[거래소 규정 — 직접 검증 필요]`
- **공정위 기업결합 심사 의결례** — 국가법령정보 미커버(기존 갭) → `[공정위 의결 — 직접 검증 필요]`
- **금융위·증선위·금감원 공시/제재 의결** — 부분 커버 → `[금융당국 의결 — 직접 검증 필요]`
- **상업등기 등기선례·등기예규** — 국가법령정보 행정규칙 부분 커버, 누락 가능 → 인용 시 검증
- ✓ 잘 커버: 상법·자본시장법·외부감사법·상업등기법·공정거래법 — 법령 + 법원 판례 충실

## 권장 실행 순서

**A(스캐폴드: plugin.json·.mcp.json 국가법령정보·CLAUDE.md 모듈형 템플릿·hooks·README·references·marketplace 등록) ✅ →
B(인프라: cold-start-interview 모듈형·customize·matter-workspace — commercial 재사용) ✅ →
C(M&A 핵심: diligence-issue-extraction·tabular-review·material-contract-schedule·closing-checklist·deal-team-summary +
신규 merger-control-filing) ✅ →
D(이사회·법인: board-minutes·written-consent·entity-compliance + 신규 shareholder-meeting +
dataroom-watcher agent·ai-tool-handoff·integration-management) ✅ →
E(상장사 모듈: public-disclosure — KR 선도) ✅ →
F(E2E 검증: M&A 딜 1건 시나리오 — 실사→이슈추출→공개목록→기업결합신고→종결체크→통합. 갭 픽스)**
