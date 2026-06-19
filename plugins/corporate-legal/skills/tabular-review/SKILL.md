---
name: tabular-review
description: >
  문서세트를 행(문서)×열(데이터포인트) 구조의 표로 검토. 셀마다 원문 인용·출처 첨부.
  .xlsx / Google Sheets / .csv / 마크다운 출력. material-contract-schedule 입력 제공.
  사용자가 "계약 일괄 검토", "표로 정리", "COC·양도 일괄 추출", "실사 표", "데이터포인트 추출"
  이라고 하거나 복수 문서에서 동일 항목을 반복 추출하려 할 때 사용.
argument-hint: "[--schema .review-schema.yaml] [--docs ./vdr/02-계약/] [--template ma-diligence] [--output xlsx|gsheets|csv] [--sample N]"
---

# /tabular-review

1. `~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/CLAUDE.md` 로드 → 실사 구조·임계점·하우스 포맷.
2. 확인: 어느 문서, 어느 열, 출력 어디로.
3. 타입 스키마 작성. `.review-schema.yaml` 저장. 사용자 확인.
4. 샘플 실행 (3–5건). 스키마 조정. 확인.
5. 팬아웃 — 문서 1건당 서브에이전트 1개, 병렬. 셀마다: 값 + 상태 + 원문 인용 + 위치.
6. 정규화 패스. 이상치·불일치 플래그.
7. 출력: `.xlsx` 또는 Google Sheets (어느 것인지 묻기), `.csv` + `_sources.csv` + 마크다운 항상 병행. 산출물 헤더.
8. 요약: 검증 부담(열별 not_present / unclear / needs_review 카운트), 플래그된 열, 파일 위치, "모든 셀은 발견이 아닌 단서" 알림.

```
/corporate-legal:tabular-review
/corporate-legal:tabular-review --schema .review-schema.yaml --docs ./vdr/02-계약/
/corporate-legal:tabular-review --template ma-diligence
```

**`--schema <경로>`:** 기존 스키마 파일 사용. 재실행·점진 추가에 유용.

**`--template <이름>`:** `references/`의 템플릿으로 시작. 현재: `ma-diligence`.

**`--docs <경로>`:** 문서 소스. 로컬 폴더, Drive 폴더 ID, VDR 경로. 생략 시 묻는다.

**`--output <xlsx|gsheets|csv>`:** 출력 포맷. 생략 시 묻는다.

**`--sample <n>`:** 스키마 확인용 샘플 크기. 기본 5.

---

## 매터 컨텍스트

실무 수준 CLAUDE.md `## 매터 워크스페이스` 점검. `활성화`가 `✗`(사내 사용자 디폴트)이면 이 단락 skip —
스킬은 실무 수준 컨텍스트를 쓰고 매터 기구는 보이지 않음. 단, **사내라도 M&A는 딜 단위로 분리**될 수
있으니 deal-context가 있으면 우선. 활성인데 활성 매터가 없으면 묻기: "어느 매터인가요?
`/corporate-legal:matter-workspace switch <slug>` 또는 `practice-level`." 활성 매터의 `matter.md`를
로드. 출력은 `~/.claude/plugins/config/claude-for-legal-kr/corporate-legal/matters/<매터-slug>/`에.
**다른 매터 파일은 절대 안 읽음(매터 간 컨텍스트 `off`).** M&A는 정보장벽이 특히 중요.

---

## 목적

문서 300건. 모든 계약에서 지배권 변경 조항, 양도제한, 자동갱신 여부를 일일이 찾는 것은 비효율적이다.
이 스킬은 문서마다 정해진 데이터포인트를 추출해 행=문서·열=데이터포인트의 표를 만든다. 검토자는
표를 보고 이상치를 찾고, 원문 인용을 눌러 확인한다. 이것이 표 검토다.

---

## 컨텍스트 로드

- 실무 CLAUDE.md `## M&A → 실사 구조`(카테고리·중요성 임계점)
- 실무 CLAUDE.md `## M&A → 이슈 메모 포맷`(발견 진술 방식)
- `deals/[코드]/deal-context.md`(딜별 임계점·VDR 위치·거래 구조)

deal-context.md가 없으면 어느 딜인지 묻는다.

---

## 열 타입 시스템

스키마의 모든 열은 타입을 가진다. 타입이 집계·검색·이상치 탐지를 결정한다.

| 타입 | 설명 | 예 |
|---|---|---|
| `verbatim` | 문서에서 그대로 복사 | 상대방명, 준거법 |
| `classify` | 정해진 옵션 중 하나 | 계약 유형, 지배권 변경 처리 |
| `date` | ISO 날짜 (YYYY-MM-DD) | 효력발생일, 만료일 |
| `duration` | 기간 | 초기 기간, 해지 통지 기간 |
| `currency` | 금액 + 통화 + 단위 | 책임한도액, 위약금 |
| `number` | 순수 숫자 | 갱신 횟수, 통지일수 |
| `free` | 짧은 자유 형식 텍스트 | 비고, 요약 |

타입과 무관하게 모든 셀은 원문 인용 + 문서 내 위치가 있어야 한다.

---

## "없음"의 세 가지 상태

| 상태 | 의미 | 값 |
|---|---|---|
| `not_present` | 조항 없음이 명확히 확인됨 | null |
| `unclear` | 조항이 있을 수 있으나 판독 불가·모호 | null 또는 부분값 |
| `needs_review` | 서브에이전트가 판단 불가 — 검토자 판단 필요 | null |

`not_present`와 `unclear`는 다르다. `not_present`는 "읽었고 없다"이며 긍정적 발견이다. `unclear`는 "있을 수 있으나 확신 못 한다"이다. 정규화 패스가 이 구분을 점검한다.

---

## 워크플로우

### Step 0: 무엇을, 어디서

확인:
1. **문서.** 어디에 있나? VDR MCP(Box·Datasite·Intralinks), 로컬 폴더, Google Drive 폴더, 파일 목록. 몇 건? 200건 초과이면 시간이 걸린다고 알리고 중요성 필터 적용 후 부분 시작 제안.
2. **스키마.** 어느 열? 두 경로:
   - `references/`의 템플릿 사용 (M&A 실사 표준이 기본)
   - 자연어로 열을 설명하면 타입 스키마로 구조화
3. **출력.** Excel(`.xlsx`) 또는 Google Sheets — 팀이 사용하는 것을 묻는다. CSV·마크다운은 항상 병행 저장. 출력은 딜 폴더 또는 사용자 지정 위치.

### Step 1: 스키마 작성 및 확인

사용자 열 목록을 구조화 스키마로 변환. 각 열: 안정적 `id`, 사람이 읽는 `label`, `type`, `prompt`(문서를 읽는 검토자가 할 질문), `classify` 열은 `options` 목록.

`.review-schema.yaml`을 출력 옆에 저장. 재사용 가능한 산출물 — 사용자가 수정하고, 열을 추가하고, 새 문서에 재실행 가능. 사용자에게 보여주고 팬아웃 전 확인.

```yaml
schema:
  name: "M&A 실사 — 프로젝트 [코드]"
  created: 2026-06-07
  columns:
    - id: counterparty
      label: "상대방"
      type: verbatim
      prompt: "대상 법인 이외의 계약 당사자는 누구인가? 문서에 표기된 그대로."
    - id: effective_date
      label: "효력발생일"
      type: date
      prompt: "계약이 언제 효력을 발생했나?"
    - id: change_of_control
      label: "지배권 변경"
      type: classify
      options: [침묵, 사전동의_필요, 동의_불합리하게_거부_불가, 자동해지, 통지만, 상대방_해지권]
      prompt: "계약이 대상 법인의 지배권 변경을 다루나? 트리거 조건과 효과는?"
    - id: assignment
      label: "양도제한"
      type: classify
      options: [침묵, 사전동의_필요, 동의_불합리하게_거부_불가, 자유양도, 계열사_양도_가능, 양도_불가]
      prompt: "대상 법인이 이 계약을 양도할 수 있나? 제한 조건은?"
    # ... 열 추가
```

### Step 2: 샘플 실행

3–5건으로 실행. 추출 결과를 사용자에게 보여준다 — 원문 인용 포함. 스키마를 함께 검토: 빠진 열이 있나? 타입이 맞나? `classify` 옵션이 충분히 세밀한가? 확인 후 팬아웃.

### Step 3: 팬아웃

문서 1건당 서브에이전트 1개, 병렬. 각 서브에이전트:

1. 문서 전체를 읽는다 (RAG 청크가 아닌 전체).
2. 각 열마다 해당 조항을 찾는다.
3. 구조화 행을 반환: 각 열마다 `{value, state, quote, location}`.
   - `value`는 타입 답변 (또는 `state`가 `answered`가 아니면 null)
   - `state`는 `answered | not_present | unclear | needs_review`
   - `quote`는 지지 원문 그대로 (정확히, 요약 없음, 문장 중간 생략 없음 — 문장 경계에서 자를 때는 표시)
   - `location`은 인용 위치 (조항 번호, 제목, 페이지 — 문서가 주는 것)

**원문 인용은 선택이 아니며, 원문 의무는 형식이 아닌 실질이다.** 각 서브에이전트는 `state: answered`인 셀을 반환하기 전 다음을 모두 충족해야 한다:

- `quote`는 소스 문서의 연속 텍스트를 문자 그대로 복사한 것이어야 한다. 서브에이전트가 인용한 `location`에서 검색 가능해야 한다. 조항 제목과 예상 표준 문언을 합성하지 않는다. 요약하고 원문이라고 하지 않는다. "보통 이런 조항은..." 기억으로 인용을 재구성하지 않는다. 불연속 텍스트를 말줄임표로 이어 붙이지 않는다.
- `location`은 정규화 패스가 문서를 다시 열어 같은 구간을 읽을 수 있을 만큼 구체적이어야 한다 — 조항 번호, 제목, 페이지 참조.
- 서브에이전트가 정확한 텍스트를 찾아 복사할 수 없으면 (소스가 잘렸거나, OCR 손상, 조항이 암시만 됐거나, 섹션 제목만 보이고 본문이 없는 경우), 셀 상태는 `needs_review`, `value`는 null, `notes`에 `quote_unavailable: <이유>` 기재. `state: answered`에 합성·재구성 인용을 넣는 것은 절대 허용하지 않는다.
- 같은 의무가 `verbatim` 열뿐 아니라 `classify` / `date` / `duration` / `currency` / `number` / `free` 셀에 첨부된 원문 인용에도 적용된다. 지지 인용도 셀 값과 같은 원문 의무를 가진다.

Step 4의 정규화 패스가 인용 위치에서 소스를 다시 열어 저장된 `quote`를 문자 대 문자로 비교해 spot-check한다. 불일치이면 셀을 `needs_review`로 다운그레이드하고 `quote_mismatch`를 기록하며 해당 열 전체를 광범위 spot-check 플래그 — 한 서브에이전트가 인용을 합성했다면 같은 실행의 다른 서브에이전트도 그랬을 수 있다.

### Step 4: 정규화

각 서브에이전트 행을 수집한 후:

- **인용 spot-check.** 랜덤 샘플 (또는 플래그된 셀 전체)에 대해 `location`으로 돌아가 `quote`를 원문과 대조. 불일치이면 해당 셀과 해당 열 전체 플래그.
- **타입 강제.** `date`는 ISO 형식. `currency`는 통화 단위. `duration`은 일/월/년 단위. 불일치이면 정규화하거나 `needs_review`.
- **열 간 이상치.** 같은 열의 값 분포를 검토. 기간이 대부분 1년인데 한 행이 99년이면 플래그. 준거법이 대부분 대한민국인데 한 행이 Delaware이면 플래그.
- **classify 누락.** 서브에이전트가 `options`에 없는 값을 반환했다면 가장 가까운 옵션에 매핑하거나 `needs_review`. 임의 값 허용 안 함.
- **정규화 로그.** 각 변경 사항 기록 — 무엇을, 왜, 어느 셀에.

### Step 5: 출력

`references/excel-output.md` (Excel) 또는 `references/gsheets-output.md` (Google Sheets) 참조.

항상 병행 저장:
- **`.csv`** — 값만. 각 데이터 열 뒤에 `_source` 열 (인용 | 위치).
- **`_sources.csv`** — 행=문서, 열=데이터포인트, 셀 값은 원문 인용 그대로.
- **마크다운 표** — 인라인 렌더 확인용.

**산출물 헤더.** 실무 CLAUDE.md `## 산출물`의 헤더를 prepend. M&A 실사 자료면 미공개중요정보 관리 주의 문구 추가.

**파일명.** `[딜코드]-tabular-review-[YYYY-MM-DD].[확장자]`. 소스 파일 `.review-schema.yaml`도 같은 위치에.

### Step 6: 요약

```markdown
## 표 검토 요약: [딜 코드]

**실행:** [YYYY-MM-DD] | **문서:** [N]건 | **열:** [N]개

### 검증 부담

| 열 | answered | not_present | unclear | needs_review |
|---|---|---|---|---|
| 지배권 변경 | 42 | 18 | 7 | 3 |
| 양도제한 | 55 | 12 | 3 | 0 |
| ... | | | | |

**검토자 우선순위:** `needs_review` 셀 [N]개, `unclear` 셀 [N]개.

### 정규화 플래그

- [열]: [이상치 또는 불일치 설명]

### 파일 위치

- 주 표: `[경로].xlsx`
- 플래그 시트: 위 파일 내 `Flags` 시트
- 소스: `[경로]_sources.csv`
- 스키마: `[경로]/.review-schema.yaml`

> ※ 이 표의 모든 셀은 발견이 아닌 단서다. 셀을 클릭해 원문 인용을 확인하고, `needs_review`·`unclear`
> 셀은 검토자가 직접 판단한다. 표는 읽기를 건너뛰게 하는 도구가 아니라 읽기를 빠르게 하는 도구다.
```

---

## 다음 단계 의사결정 트리로 마무리

CLAUDE.md `## 산출물`의 의사결정 트리로 종료. 표 검토 후 자연스러운 분기:

1. **이슈 추출** — `diligence-issue-extraction`으로. 표에서 이상치(unusual COC 조항, 주요 고객 동의 필요, IP-only 면책 등)를 식별해 이슈 메모로.
2. **공개목록 초안** — `material-contract-schedule`로. 이 표가 직접 입력.
3. **후속 요청** — 상대방에게 필요한 누락 정보(not_present / unclear / needs_review 셀에서 도출) 질문 목록 초안.
4. **스키마 조정 후 재실행** — 열 추가·수정 후 `--schema .review-schema.yaml`로 재실행.
5. **다른 것** — 이 결과로 무엇을 하고 싶은지 알려주세요.

---

## 이 스킬이 하지 않는 것

- 법률적 판단을 내리지 않음. 지배권 변경 조항이 이 거래로 트리거되는지는 서브에이전트가 아닌 변호사가 판단. 스킬은 데이터포인트를 추출하고 `[검토]` 플래그.
- bulk AI 검토 플랫폼을 대체하지 않음. 대량 계약 조항 추출이 필요하면 Luminance·Kira 핸드오프 고려. 이 스킬은 중간 규모(수십~수백 건)의 정밀 추출 레이어.
- 모든 조항을 읽지 않음. 타입 스키마의 열이 추출 범위를 정의한다 — 스키마 밖 조항은 캡처되지 않는다. 스키마를 신중히 설계.

---

## 다른 스킬과의 관계

- `diligence-issue-extraction`은 이슈를 찾는다; 이 스킬은 데이터포인트를 추출한다. 추출이 이슈를 드러내면 (특정 이익 목표를 참조하는 MAC 조항, 독성 조항) 메모하고 `diligence-issue-extraction`으로 해당 문서 검토 제안.
- `material-contract-schedule`은 공개목록이라는 특정 표를 만든다. 이 스킬의 출력을 직접 소비 가능 — 공개목록은 표 검토의 필터·재포맷 뷰.
- `ai-tool-handoff`는 bulk 검토를 Luminance·Kira로 넘긴다. 이 스킬이 처리할 수 있는 규모이면 먼저 실행하고 나머지를 핸드오프.

---

## 산출물 가드레일

모든 출력에 산출물 헤더. 모든 셀에 출처 인용 또는 플래그된 상태. 요약에 검증 필요 명시. Excel `Verified` 열이 검증 상태를 감사 가능하게 만든다. 이 도구는 읽기를 건너뛰게 하지 않는다; 읽기를 빠르게 한다.

**외부에서 온 셀 값은 HTML 렌더 전 반드시 이스케이프한다.** 상대방 문서 텍스트, 회사명, VDR 추출 문자열 등 이 세션 외부에서 온 값은 공격자 통제 입력으로 취급. 인라인 JS sorter·filter에서 셀 텍스트는 `textContent`로만 설정 — `innerHTML` 금지. URL은 emit 전 scheme 검사 (`http:` / `https:` / `mailto:`만 허용). 스프레드시트 셀 주입 방어는 `references/excel-output.md`와 `references/gsheets-output.md`의 수식 주입 방어 섹션 참조.
