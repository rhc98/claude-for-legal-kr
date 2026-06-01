# employment-legal 스킬 포팅 로드맵

이 디렉토리는 Phase A(스캐폴드)에서 **구조만** 만들어졌다. 개별 `<skill>/SKILL.md`는 아직
포팅되지 않았으며, 아래 로드맵에 따라 Phase B 이후 순차 작성한다. 기준 템플릿은
`../../commercial-legal/skills/`, 상류 원본은 `anthropics/claude-for-legal/employment-legal/skills/`.

상류는 **미국 다주(多州) 관할 인식**(주별 최종임금·FMLA/CFRA·at-will 고용)이 전제다. 한국 노동법은
**전국 단일 관할이며 임의해고(at-will)가 없다** — 근기법 §23은 모든 해고에 "정당한 이유"를 요구한다.
미국의 "어느 주냐" 축은 한국의 **상시 근로자 수(headcount) 기준 적용 차등** 축으로 매핑된다.

## 포팅 매핑

| 상류 스킬 | KR 포팅 | Phase | 핵심 재맥락화 |
|---|---|---|---|
| cold-start-interview | 1:1 + KR | B ✅ | "주(state) footprint" → **상시 근로자 수·업종·사업장·노조·취업규칙 footprint** |
| customize | 1:1 | B ✅ | CLAUDE.md 부분 수정 (고용 섹션 맵) |
| matter-workspace | 1:1 | B ✅ | 타 플러그인 패턴, 측(side) 제거·조사 매터 강화 등급 |
| termination-review | 재작성(최대) | C ✅ | §23 정당한 이유·§26 해고예고·§27 서면통지·징계절차·경영상해고 §24. **at-will 없음** |
| worker-classification | 재작성 | C ✅ | 대법원 종속노동성 판단기준·특수형태근로종사자·도급/위임 vs 근로계약·4대보험/퇴직금 소급 |
| wage-hour-qa | 재작성 | C ✅ | 통상임금(2024.12. 대법원 전합 → 2025 현행 기준)·평균임금·연장·야간·휴일 가산·최저임금·주52시간·포괄임금제. ※ 최저임금액 등 구체 수치 하드코딩 금지, 법망 시점 조회 |
| hiring-review | 재작성 | C ✅ | 근로계약·수습/시용·경업금지(직업선택의 자유 형량)·채용절차공정화법·채용 시 개인정보 |
| **labor-committee-procedure** (KR 신규) | 신규 | C ✅ | 노동위 부당해고·부당노동행위 구제신청 절차 + **노동위 data gap 대응(수동 첨부·태그)** |
| policy-drafting | 재맥락화 | D ✅ | "handbook" → **취업규칙·사규**(법정 문서) |
| handbook-updates | 재맥락화 | D ✅ | 취업규칙 변경: §94 불이익변경 과반수 동의·§93 신고 의무. "주 supplement" 대부분 N/A |
| internal-investigation(프레임워크) + investigation-open/add/query/memo/summary | 재맥락화 | D ✅ | 직장 내 괴롭힘 §76-2·§76-3 조사의무·성희롱(남녀고평법 §14) |
| leave-tracker(스킬) + log-leave | 재맥락화 | D ✅ | 연차 §60·육아휴직·출산전후휴가·연차 사용촉진. FMLA/CFRA → 한국 휴가·휴직 |
| **industrial-accident** (KR 신규) | 신규 | D ✅ | 산재보험 인정·요양급여·이의제기(산재보험법·산안법) |
| leave-tracker (agent, 주간) | 재맥락화 | D ✅ | 법정 기한 알림: 육아휴직 신청기한·출산휴가·연차 촉진·산재 요양 → FMLA/USERRA/ADA 대체 |
| expansion-kickoff / expansion-update / international-expansion(프레임워크) | **후순위** | E | 미국 회사 해외 진출 전제 → 보류. 재개 시 "한국 기업 해외 진출"/"외국 기업 한국 진출" 관점 재구성 |

## 권장 실행 순서

**A(스캐폴드, 완료) → B(인프라 스킬: cold-start-interview·customize·matter-workspace, 완료) →
C(핵심 검토: termination·hiring·worker-classification·wage-hour + labor-committee-procedure, 완료) →
D(policy·investigation·leave·industrial-accident + leave-tracker agent, 완료) → E(expansion 계열, 보류) →
F(E2E 검증: 6개 시나리오 통과, 갭 2건 픽스 완료) ✅**
