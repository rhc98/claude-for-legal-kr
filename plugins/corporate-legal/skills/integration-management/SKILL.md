---
name: integration-management
description: >
  종결 후 M&A 통합(PMI) 트래커 — 단계별 workplan(Day 1/30/90/180), 동의·승계 추적,
  계약 이전 대규모 처리, 주간 상태 보고. 거래구조(주식양수도/영업양수도/합병/분할)별
  계약 이전 메커니즘을 자동 분류하고, closing-checklist.yaml의 종결 후 이월 항목을
  인계받아 시작한다. 다음 키워드가 있을 때 사용: "통합", "PMI", "종결 후", "동의 미완료",
  "계약 이전", "통합 현황", "딜 잔여 사항", "post-close", "integration".
argument-hint: "[--init | --contracts | --report | --update | --export [--format csv|table] [--section all|consents|contracts|workplan]] [--deal [코드]]"
---

# /corporate-legal:integration-management

1. `~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/deals/[코드]/deal-context.md` 로드 — 거래코드, 대상회사, 종결일, 담당자, 거래구조 확인.
2. `integration-tracker.yaml` 존재 시 로드; `--init`이면 신규 생성.
3. closing-checklist.yaml이 존재하면 종결 후 이월 항목(post-closing)을 Day 1/Day 30 워크플랜 항목으로 승계한다.
4. 플래그별 라우팅:
   - `--init`: Mode 1 — PA 읽기, 단계별 workplan 생성, 동의 트래커 초기화
   - `--contracts`: Mode 2 — 계약 목록 import, 거래구조별 분류·티어 지정
   - `--report`: Mode 3 — 상태 보고서 생성
   - `--update`: Mode 4 — 수동 업데이트 또는 업로드 문서 파싱
   - `--export`: Mode 5 — CSV 또는 테이블 내보내기
5. `~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/deals/[코드]/integration-tracker.yaml` 읽기/쓰기.
6. 쓰기 후: 변경 요약 표시, 새 플래그 부상.

## 매터 컨텍스트

practice-level CLAUDE.md의 `## 매터 워크스페이스` 확인. `활성화`가 `✗`(사내법무 기본값)이면 이 단락 건너뜀 — 스킬은 플러그인 레벨 컨텍스트를 사용한다. 활성화 상태이고 활성 매터가 없으면: "어느 매터입니까? `/corporate-legal:matter-workspace switch <slug>` 를 실행하거나 '플러그인 레벨'이라고 말씀해 주세요." 활성 매터의 `matter.md`를 로드하고, 출력물을 `~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/matters/<matter-slug>/`에 저장. 다른 매터 파일은 `Cross-matter context`가 `on`일 때만 읽는다.

## 목적

종결 후 법무팀 워크플랜을 단일 트래커로 관리한다:

- **단계별 workplan (Day 1/30/90/180):** 법무 담당(legal-owns)·법무 지원(legal-supports) 항목 분리
- **필수 동의(Required Consents) 트래커:** PA(인수계약) 기한과 연동. closing-checklist에서 미완료 상태로 이월된 동의·승계 항목 포함
- **계약 이전 대규모 처리:** 거래구조(주식양수도/영업양수도/합병·분할)별 이전 메커니즘 자동 분류
- **주간 상태 보고:** 딜팀·경영진용(조용한 모드 적용 가능)
- **Export:** 사외 로펌·Corp Dev·이사회 공유용 CSV/테이블

## 트래커 파일

`~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/deals/[코드]/integration-tracker.yaml`에 위치. `deal-context.md`에서 거래코드, 대상회사명, 종결일, 담당자를 읽는다. `closing-checklist.yaml`이 존재하면 종결 후 항목을 상속한다.

```yaml
# integration-tracker.yaml

metadata:
  deal_code: "[코드]"
  target: "[회사명]"
  deal_structure: "[주식양수도 / 영업양수도 / 합병 / 분할 / 분할합병]"
  close_date: "[YYYY-MM-DD]"
  deal_lead: "[담당자]"
  outside_counsel: "[법무법인 및 담당 변호사]"
  last_updated: "[날짜]"
  last_status_report: "[날짜 또는 null]"

pa_dates:
  required_consents_deadline: "[YYYY-MM-DD — PA에서 추출]"
  rep_survival_expires: "[YYYY-MM-DD]"
  escrow_release: "[YYYY-MM-DD 또는 null]"
  earnout_milestones:
    - description: "[마일스톤]"
      measurement_date: "[YYYY-MM-DD]"
      payment_date: "[YYYY-MM-DD]"
      owner: finance   # 항상 finance — 법무는 날짜만 추적

workplan:
  day_1:
    target_date: "[close_date + 7일]"
    items: []
  day_30:
    target_date: "[close_date + 30일]"
    items: []
  day_90:
    target_date: "[close_date + 90일]"
    items: []
  day_180:
    target_date: "[close_date + 180일]"
    items: []

required_consents: []
desired_consents: []

contracts:
  source: "[repository / manual-upload / disclosure-schedule]"
  repository_path: "[경로 또는 null]"
  last_imported: "[날짜]"
  total: 0
  tier_1: []
  tier_2: []
  tier_3: []
  tier_4: []
```

**워크플랜 항목 구조:**
```yaml
- id: "W-001"
  description: "[액션 아이템]"
  phase: "[day_1 / day_30 / day_90 / day_180]"
  owner: "[legal-owns / legal-supports]"
  workstream: "[legal / hr / it / finance / real-estate / other]"
  priority: "[critical / high / medium / low]"
  deadline: "[YYYY-MM-DD 또는 null]"
  deadline_basis: "[pa-obligation / regulatory / best-practice]"
  status: "[not_started / in_progress / complete / blocked / deferred]"
  blocker: "[설명 또는 null]"
  depends_on: "[항목 id 또는 null]"
  notes: ""
```

**동의 항목 구조:**
```yaml
- id: "CON-001"
  counterparty: "[상대방명]"
  contract_type: "[고객 / 벤더 / 임대차 / IP라이선스 / 금융 / 기타]"
  required_consent: true        # true = PA 필수동의 목록에 명시
  pa_deadline: "[YYYY-MM-DD]"   # required_consent: true인 경우에만
  status: "[not_started / outreach_sent / in_negotiation / obtained / waived / refused]"
  assigned_to: "[담당자 또는 null]"
  outreach_date: "[날짜 또는 null]"
  obtained_date: "[날짜 또는 null]"
  notes: ""
```

**계약 항목 구조:**
```yaml
- id: "C-001"
  name: "[계약명 또는 파일명]"
  counterparty: "[당사자명]"
  contract_type: "[MSA / SaaS / 임대차 / IP라이선스 / 고용 / NDA / 기타]"
  annual_value: "[금액 또는 unknown]"
  assignment_mechanism: "[auto-assign / consent-required / coc-provision / universal-succession / silent]"
  tier: 1   # 1=필수동의, 2=중요계약+동의필요, 3=COC, 4=자동승계
  required_consent: false
  pa_deadline: "[YYYY-MM-DD 또는 null]"
  status: "[not_reviewed / no_action / consent_pending / outreach_sent / in_negotiation / consent_obtained / assignment_complete / waived / refused / coc_triggered]"
  assigned_to: "[담당자 또는 null]"
  notes: ""
  last_updated: "[날짜]"
```

---

## Mode 1: 초기화 (--init)

```
/corporate-legal:integration-management --init [--deal [코드]]
```

### Step 1: 딜 컨텍스트 로드

`~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/deals/[코드]/deal-context.md` 읽기. 파일이 없으면: 거래코드, 대상회사, 종결일, 담당자, 사외 법무법인, **거래구조(주식양수도/영업양수도/합병/분할)** 를 질문한다. deal-context.md가 없으면 해당 정보로 새로 작성.

`closing-checklist.yaml`이 있으면 읽어 종결 후 이월 항목(미완료 동의·승계 포함)을 Day 1/Day 30 워크플랜에 선반입한다.

### Step 2: 딜 입력 읽기

**PA(인수계약) 전문이 있을 때 가장 완전한 트래커가 생성된다.** PA의 필수동의 목록과 종결 후 의무 조항이 기한과 법적 의무의 권위 있는 출처다. 단, 입력이 부분적이어도 시작 트래커를 생성할 수 있다.

> 어떤 딜 자료가 있으십니까? 아래에서 해당하는 것을 공유해 주세요:
>
> **이상적:** PA(인수계약) — 종결 후 의무, 필수동의 목록, 진술보증 생존 기간, 에스크로 조건, 실적 조정 조항을 읽겠습니다.
>
> **함께 있으면 유용:**
> - 딜 요약서 또는 텀시트 (핵심 경제조건·일정 파악)
> - 사외 법무법인의 종결 후 체크리스트 또는 to-do 목록
> - 기존 워크플랜 또는 통합 트래커 (이어받아 계속 진행)
> - closing-checklist — M&A cold-start 스킬로 생성된 경우 `closing-checklist.yaml`에서 자동 상속
> - 필수동의 목록만 있는 경우 (PA를 사외 법무법인이 보유한 경우)
>
> **아무 것도 없는 경우:** 딜을 구두로 설명해 주시면 — 피인수회사, 종결일, 주요 미결 항목 — 표준 Day 1/30/90/180 워크플랜 골격을 만들어 드립니다.

**입력에 따른 산출물 차이:**

| 입력 | 산출물 |
|---|---|
| PA 전문 | 완전한 워크플랜 + 필수동의(기한 포함) + PA 날짜 |
| PA + 계약 목록 | 전체 트래커 + 계약 이전 티어 목록 |
| 딜 요약 / to-do | 표준 워크플랜 골격, 필수동의 항목은 placeholder |
| 없음 | 표준 워크플랜 골격; 변호사가 동의·계약 목록 직접 입력 |

**PA에서 추출:**

*필수동의 목록:*
- 각 동의 항목: 상대방명, 계약 유형, 계약상 기한. `required_consent: true`, `pa_deadline` 설정.

*종결 후 의무:*
- 각 의무를 워크플랜 항목으로 매핑. 기한 기준으로 해당 단계(phase)에 배정. `deadline_basis: pa-obligation` 태그.

*핵심 날짜:*
- 필수동의 기한 — PA에서 추출
- 진술보증 생존 기간 — PA에서 일반·기본·세금 진술보증의 각기 다른 생존 기간을 개별로 추출. 기본값 가정 금지.
- 에스크로 해제일 — PA에서 추출
- 실적 조정 측정일·지급일 — `pa_dates.earnout_milestones`에 추가, owner는 항상 `finance`

### Step 3: 단계별 workplan 생성

표준 워크플랜 항목을 각 단계별로 생성. Step 2에서 추출한 PA 의무를 추가. closing-checklist에서 상속된 항목은 선반입.

**한국 특유 항목을 거래구조별로 조건부 포함:**

> 거래구조가 **영업양수도**인 경우: 근로관계 승계 후속(「근로기준법」 제24조 [검토]), 인허가 변경신고 후속을 Day 1/Day 30에 추가.
> 거래구조가 **합병·분할**인 경우: 합병등기·분할등기 완료 확인을 Day 1에 추가; 포괄승계 전제 계약 중 COC·양도금지 조항 점검을 Day 30에 추가.
> 거래구조가 **주식양수도**인 경우: 대상회사 계약은 법인격 동일 → 원칙적 이전 불요; COC 트리거 계약 점검을 Day 30에 추가.

**Day 1 — legal-owns:**
- 법인등기 후속 확인 — 합병·분할등기 완료, 상호·목적 변경등기 [priority: critical]
- 대표이사·이사 변경등기 (해당 시) [priority: critical]
- 사업자등록증 변경신고 [priority: critical]
- 인허가 명의변경신고 또는 지위승계신고 (영업양수도·합병 해당) [priority: critical] [검토: 인허가 유형별 근거 법령]
- 주요 IP 양도 실행 — 종결에서 이월된 건 [priority: critical]
- 핵심 인물 고용계약 검토·서명 확인 [priority: high]
- D&O 보험 — 피인수회사 이사의 tail policy 결합 확인 [priority: critical]

**Day 1 — legal-supports:**
- 근로자 공지 및 커뮤니케이션 (HR 주도, 법무 검토) — 영업양수도의 경우 근로관계 승계 내용 포함 [priority: critical]
- 4대보험 취득·상실 신고 (HR 주도, 법무 지원) [priority: critical]
- 고객 커뮤니케이션 서한 (사업부 주도, 법무 검토) [priority: high]

**Day 30 — legal-owns:**
- 필수동의 초기 연락 — 모든 상대방 접촉, 발신 문서화 [priority: critical]
- 특허·상표 양도 등록 (특허청) [priority: high]
- 저작권 양도 등록 [priority: medium]
- 중요계약 검토 — Tier 1·Tier 2 계약 이전 분석 완료 [priority: high]
- COC 트리거 계약 상대방 즉시 연락 (Tier 3) [priority: critical]
- 보험 tail policy 최종 확인 [priority: high]

**Day 30 — legal-supports:**
- 데이터 이전 개인정보 검토 (IT 주도, 법무 자문) [priority: high]
- 부동산 임대차 양도 조항 검토 (시설 주도, 법무 자문) [priority: medium]

**Day 90 — legal-owns:**
- 필수동의 기한 — 모든 필수동의 취득 또는 에스컬레이션 [priority: critical, deadline: pa_dates.required_consents_deadline]
- 법인 정리 방향 결정 — 별도 유지·합병·청산 권고 [priority: high]
- 잔여 동의 2차 연락 [priority: high]
- Tier 3 COC 계약 해소 [priority: critical]
- 급여·복리후생 통합 문서화 (HR 주도, 법무 지원) [priority: medium]

**Day 90 — legal-supports:**
- 인사제도 통합 법무 자문 (HR 주도) [priority: medium]

**Day 180 — legal-owns:**
- 합병등기 신청 — 법인 정리 방향이 흡수합병인 경우 [priority: high]
- 청산 신청 — 법인 정리 방향이 청산인 경우 [priority: high]
- 계약 명의변경(novation) 전체 — 인수인 명의가 필요한 계약 [priority: high]
- 진술보증 생존 기간 추적 — 만료 예정일 메모 [priority: medium]

생성 후 요약 표시:

```
통합 트래커 초기화 완료 — [거래코드] / [대상회사]

종결일: [날짜]
필수동의 기한: [날짜] (오늘로부터 [N]일)
진술보증 생존 만료: [날짜]

워크플랜 항목: [N]개 (법무 담당 [N]개, 법무 지원 [N]개)
필수동의: [N]개 (PA 목록 기준)
희망 동의: [N]개 (계약 검토에서 식별 — PA 의무 없음)

거래구조: [주식양수도 / 영업양수도 / 합병 / 분할]
계약 이전 메커니즘: [구조별 분류 결과 요약]

다음 단계: 계약 목록 import 시 '--contracts' 실행.
```

---

## Mode 2: 계약 이전 처리 (--contracts)

```
/corporate-legal:integration-management --contracts [--deal [코드]]
```

계약 이전 전용 초기화. 계약 목록이 변경될 때 독립적으로 재실행 가능.

### Step 1: 계약 목록 확보

두 경로 중 해당하는 것 사용:

**경로 A: 연결된 저장소**

> 계약 저장소가 연결되어 있습니까? (Google Drive, Box, SharePoint 또는 VDR)
>
> 네: 피인수회사 계약 폴더 경로 또는 폴더명을 알려 주세요. 목록을 가져와 각 계약의 양도 조항과 상대방을 읽겠습니다.

저장소 검색. 각 문서에서: 파일명·경로, 상대방명, 계약 유형, 양도 조항 문구, COC 조항 문구, 연간 금액(있는 경우) 추출.

**경로 B: 수동 목록 업로드**

> 계약 목록을 업로드해 주세요:
> - PA 공시서류의 중요계약 별표
> - 계약관리 시스템의 CSV/Excel 내보내기
> - 수동 작성 목록
>
> 필수 컬럼: 계약명, 상대방. 선택(있으면 유용): 계약 유형, 연간 금액, 양도 조항 원문.

양도 조항 원문이 없는 계약은 `assignment_mechanism: not_reviewed`로 설정, 후속 검토 플래그.

**경로 C: 공시서류**

저장소도 목록도 없는 경우, PA 공시서류의 중요계약 별표(--init에서 업로드한 PA)를 읽는다. 최소 목록(당사자·계약 유형) 확보. 양도 조항은 수동 검토 필요.

### Step 2: 거래구조별 양도 메커니즘 분류

**한국 거래구조에 따라 계약 이전 방식이 근본적으로 다르다:**

| 거래구조 | 원칙적 이전 방식 | 예외·주의 사항 |
|---|---|---|
| **주식양수도** | 대상회사 법인격 동일 — 계약 이전 불요 | COC 조항이 있는 계약은 종결 자체로 트리거 가능. 점검 필수. |
| **영업양수도** | 계약인수(민법 제548조 [검토]) — 상대방 개별 동의 필요 | 동의 없이 이전 불가. 동의 거부 시 계약 해지 또는 신규 체결 필요. |
| **합병·분할** | 권리·의무 포괄승계 (상법 제530조의10 등 [검토]) | COC 조항·양도금지 조항이 있는 경우 상대방 개별 동의 필요할 수 있음 [검토]. |

각 계약에 대해 양도 메커니즘 분류:

| 메커니즘 | 정의 | 티어 |
|---|---|---|
| `universal-succession` | 합병·분할 포괄승계 — 원칙적 이전, 단 COC·양도금지 조항 없는 경우 | 4 (단, COC 있으면 3으로 상향) |
| `consent-required` | 양도 금지 조항 — 상대방 동의 없이 이전 불가 | 1 또는 2 |
| `coc-provision` | COC 조항 — 지배권 변경 시 상대방 해지권·동의권 발생 | 3 |
| `auto-assign` | 제한 없거나 계열사·승계인에게 양도 명시 허용 | 4 |
| `silent` | 양도 조항 없음 — 준거법 기본 원칙 적용. 준거법별 기본 원칙 확인 후 변호사 검토 플래그. | 2 |
| `not_reviewed` | 양도 조항 확인 불가 | 수동 검토 플래그 |

PA 필수동의 목록에 명시된 계약: 양도 메커니즘 분류 무관하게 Tier 1로 강제 지정.

### Step 3: 티어 배정

```
Tier 1 — 필수동의: [N]개
  PA 목록 명시, 기한 [날짜], 반드시 동의 취득 필요

Tier 2 — 중요계약·동의 필요: [N]개
  양도 제한 있음, PA 목록 미명시
  권고 일정: Day 90 이내 취득

Tier 3 — COC 조항: [N]개 ⚠️
  종결로 상대방 해지권·동의권 트리거 가능
  즉시 조치 필요: 종결일에 이미 트리거됐을 수 있음

Tier 4 — 자동 승계 / 조치 불요: [N]개
  자동 이전 또는 계열사·승계인 조항에 해당
  추적만 — 별도 연락 불요

미검토: [N]개
  양도 메커니즘 확인 불가 — 수동 검토 필요
```

Tier 3는 별도로 눈에 띄게 표시. COC 조항은 종결일에 이미 트리거됐을 수 있으며, 상대방이 현재 해지권을 행사 중일 수 있다.

### Step 4: 트래커 항목 생성

각 계약에 대해:
- 추출된 필드 전체 (상대방, 유형, 금액, 메커니즘, 티어)
- 초기 상태: Tier 4 → `no_action`; Tier 3 → `coc_triggered`; Tier 1·2 → `consent_pending`; 미검토 → `not_reviewed`
- Tier 1은 PA 필수동의 목록에서 `pa_deadline` 설정

---

## Mode 3: 상태 보고서 (--report)

```
/corporate-legal:integration-management --report [--deal [코드]]
```

현재 트래커 상태를 읽어 보고서를 생성한다.

```
[산출물 헤더 — 플러그인 config ## 산출물 기준, 역할별 상이; `## 누가 이 플러그인을 사용하나` 참조]

> 이 상태 보고서는 인수계약, 실사 결과, 종결 후 통합 기록에서 도출됩니다. 해당 문서들의 비밀유지·법무비밀(attorney-client privilege) 지위를 그대로 승계합니다 — 권한 범위 밖으로 배포하면 특권이 해제될 수 있습니다. 수신 목록을 발송 전 반드시 확인하십시오.

통합 현황 — [거래코드] / [대상회사]
[날짜] — 종결 후 Day [N]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

총괄 요약
[2-3문장: 전체 현황, 최대 리스크, 지난 보고 이후 주요 성과]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

필수동의  [기한: [날짜] — [N]일 남음]
  취득:      [N] / [합계]  ████████░░  [%]
  협상 중:   [N]
  연락 발송: [N]
  미시작:    [N]
  거부:      [N] ⚠️

⚠️ 위험: [상대방] — [N]일 내 기한, 연락 미응답
⚠️ 거부: [상대방] — PA 의무 미이행; 사외 법무법인 즉시 에스컬레이션

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

계약 이전 현황
  Tier 1 (필수동의):         [N] 완료 / [N] 진행 중 / [N] 미시작
  Tier 2 (중요계약):         [N] 완료 / [N] 진행 중 / [N] 미시작
  Tier 3 (COC 조항):         [N] 해소 / [N] 미해소 ⚠️
  Tier 4 (자동 승계):        [N] — 별도 조치 불요

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

워크플랜 — 법무 담당
  🔴 기한 초과 ([N]개):
    [항목] — 당초 기한 [날짜]

  ⏰ 이번 주 마감 ([N]개):
    [항목] — 기한 [날짜]

  ✅ 지난 보고 이후 완료 ([N]개):
    [항목] — 완료 [날짜]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

차단 항목 및 의사결정 필요 사항
  [항목] — 차단 원인: [설명] — 담당: [이름]
  [항목] — 결정 필요: [설명] — 권고안: [옵션]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

예정된 주요 일정
  [날짜] — [마일스톤 / 기한]
  [날짜] — 진술보증 생존 만료 예정 — 보상 청구 미결 건 확인
  [날짜] — 에스크로 해제 예정 (해당 시)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Mode 4: 업데이트 (--update)

```
/corporate-legal:integration-management --update [--deal [코드]]
```

**수동 업데이트:** 변호사가 변경 사항을 직접 말한다.

> "XX 동의 취득했습니다. 상태 업데이트하고 담당자·취득일 기록해 주세요."
> "법인 정리 방향은 흡수합병으로 결정. 상태 업데이트하고 Day 180에 합병등기 항목 추가해 주세요."
> "[상대방]이 동의를 거부했습니다. 플래그 세우고 PA 보상 청구 트리거 여부를 사외 법무법인에 확인해야 한다는 메모 추가해 주세요."

Claude는 해당 트래커 항목을 업데이트하고, 하위 상태를 재산출하며(예: Tier 1 전체 동의 취득 시 PA 의무 이행 플래그), 변경 사항을 표시한다.

**업로드 업데이트:** 워크스트림 담당자 또는 사외 법무법인이 상태 문서를 전송한다.

> "[사외 법무법인 / HR 팀 / Corp Dev]의 상태 업데이트 문서를 업로드하겠습니다. 파싱해서 트래커에 반영해 주세요.

업로드된 문서를 읽는다. 설명된 항목을 상대방명 또는 워크플랜 항목 설명으로 트래커 항목과 매칭. 상태 필드 업데이트. 트래커에 기존 항목이 없는 내용은 플래그 — 신규 추가 항목일 수 있음.

업데이트 후 표시:
```
[N]개 항목 업데이트.

변경 사항:
  CON-003 [상대방]: not_started → obtained
  W-014 법인 정리: in_progress → complete

새 플래그:
  CON-007 [상대방]: refused — PA 의무 미이행 가능. 고려 사항:
  보상 청구 여부 사외 법무법인 검토. ⚠️
```

---

## Mode 5: 내보내기 (--export)

```
/corporate-legal:integration-management --export [--format csv|table] [--section all|consents|contracts|workplan]
```

플랫 CSV 또는 마크다운 테이블 생성. 기본값: 전체 섹션, CSV.

CSV 포맷 — 항목당 1행, `section` 컬럼으로 섹션 구분.

*워크플랜:* id, phase, description, owner, workstream, priority, deadline, status, blocker

*동의:* id, counterparty, contract_type, required_consent, pa_deadline, status, assigned_to, obtained_date, notes

*계약:* id, name, counterparty, contract_type, annual_value, assignment_mechanism, tier, required_consent, pa_deadline, status, assigned_to, notes

내보내기는 공유 포맷 — 사외 법무법인, Corp Dev, 이사회 통합 보고에 적합.

---

## 다음 단계 의사결정 트리로 마무리

모든 응답의 끝에 현재 상태에 맞는 다음 단계 중 2-3개를 제시:

```
다음으로 할 수 있는 것:
→ /corporate-legal:integration-management --contracts  (계약 목록 import 및 분류)
→ /corporate-legal:integration-management --report     (상태 보고서 생성)
→ /corporate-legal:integration-management --update     (항목 상태 업데이트)
→ /corporate-legal:integration-management --export     (CSV 내보내기)
```

---

## 이 스킬이 하지 않는 것

- **계약 협상:** 동의 취득 전략이나 협상 포인트를 조언하지 않는다. 양도 조항의 법적 해석은 플래그만 표시하고, 변호사 또는 사외 법무법인에 이관.
- **인사·노무 실질 판단:** 근로관계 승계 여부, 해고 가부, 단체협약 승계 범위 등 노동법 실질 판단은 HR 전문 법무 또는 사외 법무법인 이관.
- **규제 실체 판단:** 인허가 승계 가부, 변경신고 필요 여부의 실체적 판단은 규제 전문가 이관. 스킬은 일정·담당자·상태를 추적할 뿐이다.
- **PA 해석:** 필수동의 의무의 범위, 보상 청구 트리거 요건 등 PA 해석은 사외 법무법인 이관.
- **법령 번호의 보증:** 이 스킬에 인용된 조문 번호는 `[검토]` 태그가 붙은 경우 런타임에 검증하지 않았다. 적용 전 반드시 현행 법령 확인.

## 수식 삽입 방어

CSV 내보내기 시: 셀 값이 `=`, `+`, `-`, `@`로 시작하면 앞에 작은따옴표(`'`)를 추가한다. 스프레드시트 수식 주입 방지.
