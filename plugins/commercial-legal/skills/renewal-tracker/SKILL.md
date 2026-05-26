---
name: renewal-tracker
description: >
  유지되는 갱신 등록부를 기준으로, 자동갱신이 닥쳐오는 계약과 해지통보(notice) 창이 닫히기
  전 알려야 할 계약을 surface한다. 사용자가 "갱신 뭐 있나", "갱신 점검", "해지통보 기한
  추가", "갱신 추적", "갱신 등록부", "이거 갱신 트래커에 넣어줘", "해지창 놓쳤나"라고 하거나
  스케줄로 돌 때 사용. saas-msa-review·vendor-agreement-review에서 핸드오프를 받는다.
argument-hint: "[--days N 창 변경 | --missed 놓친 해지창]"
---

# /renewal-tracker

무엇이 갱신되는지, 그리고 언제까지 해지통보를 보내야 하는지를 surface한다.

가드레일·헤더·검토자 메모·태그 어휘·결정 자세·산출물 포맷·대시보드 제안은 모두 이 플러그인의
`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`가 정본이다 — 여기서
재진술하지 않고 가리킨다. 충돌 시 그 CLAUDE.md가 우선한다. 이 스킬은 거의 전부 데이터·캘린더
작업이라 인용은 최소다 — 법 인용이 실제로 들어가는 곳(약관규제법 §9 해지권, 민법 기간 계산
등)에만 출처 태그를 붙인다.

## 무엇을 하나

1. **config 읽기.** `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`
   읽기. 없거나 `[PLACEHOLDER]`가 남아 있으면 substantive 작업 전 멈추고
   `/commercial-legal:cold-start-interview`로 안내. (단순 등록부 조회는 셋업 없이도 동작하나,
   알림 목적지·에스컬레이션은 config에서 온다.)

2. **등록부 읽기.** 라이브 등록부는
   `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/renewal-register.yaml`
   (config 디렉토리 — 플러그인 업데이트에도 살아남음). 없으면 첫 추가 시 빈 `renewals:`
   목록으로 생성. 이 스킬의 `references/renewal-register.yaml`은 TEMPLATE/예시일 뿐 라이브
   데이터가 아니다.

3. **디폴트 모드:** Mode 2 — 향후 90일 안에 닥쳐오는 것을, half-open 구간으로 긴급도별
   그룹핑(각 기한이 정확히 한 밴드에만 들어가게). 🔴 해지통보 기한 0–13일 / 🟠 14–44일 /
   🟡 45–89일. 14·45·90일은 경계 — 각각 정확히 한 밴드에 속한다(두 밴드 아님).

4. **`--days N`:** 조회 창을 바꾼다.

5. **`--missed`:** Mode 4 — 해지통보 없이 지나간 해지창(놓친 창) 리포트.

6. **등록부가 비어 있고 CLM이 연결되어 있으면:** Mode 3 제안 — CLM에서 갱신일이 있는 활성
   계약을 스캔해 일괄 적재. CLM 미연결이면 이 제안을 하지 않고 로컬 등록부로만 동작한다.

7. **출력에 권고 행동 포함:** 누구에게 핑할지(각 레코드의 사업 담당자), 갱신가가 무제한
   (uncapped)인 것은 어느 것인지(창이 닫히기 전 협상 leverage 확보).

## 예시

```
/commercial-legal:renewal-tracker
```

```
/commercial-legal:renewal-tracker --days 180
```

```
/commercial-legal:renewal-tracker --missed
```

---

## 목적

아무도 계약을 두 번 읽지 않는다. 갱신일·해지통보 기한은 검토 시점에 한 번 추출되고, 그 뒤
어딘가에 산다 — 이상적으로는 해지통보 기한 45일 *전*에 당신에게 소리치는 곳에. 45일 *후*가
아니라.

이 스킬은 갱신 등록부를 유지하고 다가오는 것을 surface한다.

## 등록부

라이브 등록부는 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/renewal-register.yaml`
(config 디렉토리 — 플러그인 업데이트에도 살아남음). 키는 machine-stable 영문, 사람이 보는
값·코멘트는 한국어. 각 레코드:

```yaml
- counterparty: "에이콘 SaaS"
  agreement_type: "에이콘 플랫폼 구독계약"
  signed_date: 2025-06-15
  initial_term_end: 2026-06-15
  current_term_end: 2026-06-15      # 자동갱신마다 앞으로 굴러감; cancel_by_* 계산은 이 값 기준
  auto_renew: true                  # 자동갱신 여부 (true면 해지통보 없으면 갱신)
  renewal_mechanism: "연 단위 자동갱신"
  notice_period_days: 60            # 해지통보 기한 — 계약상 며칠 전까지 통보해야 하나
  notice_method: "이메일"           # 이메일 / 포털 / 내용증명 / 등기 / 계약 §X
  transit_buffer_days: 0            # 전자 0, 국내 내용증명 5, 국제 등기 10 — 또는 계약 명시 시 그대로
  cancel_by_calendar: 2026-04-16    # current_term_end − notice_period_days (raw 산술)
  cancel_by_effective: 2026-04-16   # 필요 시 직전 영업일로 roll-back
  send_by_effective: 2026-04-16     # cancel_by_effective − transit_buffer_days — 실제 통보를 "보내야" 하는 날
  cancel_by_roll_note: ""           # 예: "일요일 2026-11-01에서 roll-back; 계약상 영업일 정의 대조 필요"
  cancel_by_provenance: "[모델 계산 — 해지통보 조항 대조 검증 필요]"
  price_on_renewal: "갱신 시점 정가 (무제한)"
  annual_value: 48000000            # 연 금액 (원)
  owner: "jane@company.com"         # 사업 담당자
  clm_id: "IC-12345"                # CLM 연결 시
  esign_envelope: "abc-123"         # 전자서명(모두싸인·DocuSign 등) 연결 시
  status: "active"                  # active | cancelled | renewed | lapsed
  next_review: 2026-03-01           # 등록부 다음 점검일
  notes: "갱신가 무제한 — 갱신 전 재협상. 대체 벤더: X, Y."
```

**해지통보 전달 시간 — 알림은 `cancel_by_effective`가 아니라 `send_by_effective` 기준.**
60일 창인데 내용증명을 요구하면 실제로는 약 55일이다. 도달일(received-by) 기준으로 알리는
트래커가 곧 기한을 놓치는 트래커다. `send_by_effective = cancel_by_effective − transit_buffer_days`로
계산하고, 알림(Mode 2의 🔴 / 🟠 / 🟡 밴드)은 `send_by_effective` 기준으로 발사한다. Mode 2의
긴급도 컬럼은 `send_by_effective`를 보이고, 상세 컬럼에서 `cancel_by_effective`·`notice_method`·
`transit_buffer_days`를 노출해 독자가 그 차이를 보고 버퍼를 따져볼 수 있게 한다.

**굴러가는 갱신 — 앞으로 굴러가지 않는 등록부는 딱 한 번만 맞는 등록부다.** `initial_term_end`는
기록용으로 저장하되, `cancel_by_*`는 `current_term_end`에서 계산한다. 갱신이 발사되면(해지창이
지났는데 통보가 없었으면) 묻는다:

> 이 계약은 [날짜]에 자동갱신됐습니다. 등록부를 갱신할까요: 새 `current_term_end`는
> [날짜 + 갱신기간], 새 `cancel_by_effective`는 [계산값], 새 `send_by_effective`는 [계산값].
> 확인?

1년 차 이후엔 `initial_term_end`는 틀린 값이 되고 `current_term_end`만 올바른 해지통보 기한을
만든다.

## 모든 해지통보 기한에 영업일 점검

**등록부의 해지통보 기한은 통보가 유효하게 효력을 갖는 마지막 영업일이어야 한다 — 달력상
날짜가 아니라.** 주말에 걸리는 달력 날짜는 갱신 기한을 놓치는 가장 흔한 단일 경로다.
등록부가 그것을 잡는다.

해지통보 기한을 계산(또는 ingest)할 때:

1. **달력 날짜 계산.** `cancel_by_calendar = current_term_end − notice_period_days`(또는 조항이
   정한 대로). raw 산술.
2. **준거법 기준 영업일 roll-back.** 한국 준거법이면 「관공서의 공휴일에 관한 규정」상
   공휴일·대체공휴일과 토·일을 본다. 토요일·일요일·공휴일이면 **직전** 영업일로 roll-back —
   절대 뒤로(forward) 굴리지 않는다. 뒤로 굴리면 창이 닫힌 뒤 통보가 도달한다. **외국 준거법이면**
   그 관할 공휴일 캘린더를 쓰고, 확정할 수 없으면 플래그: "준거법이 [X]입니다 — 영업일
   roll-back은 한국 공휴일을 placeholder로 썼습니다. 효력일에 의존하기 전 [관할] 공휴일
   캘린더 대조 필요. `[외국법 — 외국 변호사 검증 필요]`"
3. **계약 자체의 기간 계산 규칙 점검.** "영업일", "도달주의", "도달 간주", "오후 5시
   [현지시간]", 통보 방법 조항을 찾는다. 계약이 "영업일"을 정의하거나 도달 메커니즘(내용증명·
   읽음확인 이메일)을 정하면 그 정의가 우선한다. 한국 민법상 기간 계산(초일 불산입 등 §155
   이하)과 계약 자체 규칙이 다르면 플래그. `[검토]`
4. **두 날짜를 등록부에 기록.** `cancel_by_calendar`는 raw 산술, `cancel_by_effective`는 통보가
   유효한 마지막 영업일, `cancel_by_roll_note`는 둘이 다른 이유. 계산된 `cancel_by_effective`는
   모두 `cancel_by_provenance` 태그 `[모델 계산 — 해지통보 조항 대조 검증 필요]`를 달아, 검증
   플래그가 주변 산문이 아니라 날짜와 함께 다니게 한다.
5. **알림은 효력일 기준으로 발사 — 달력 날짜 아님.** 긴급도 밴드(Mode 2의 🔴 / 🟠 / 🟡)는
   `send_by_effective`(전달 버퍼 반영) 기준. Mode 2 출력은 긴급도 컬럼에 효력일을 보이고,
   roll-back이 일어난 곳에서는 상세 컬럼에 `cancel_by_calendar`·`cancel_by_roll_note`를 노출해
   독자가 보고 따질 수 있게 한다.

`cancel_by: 2026-11-01`(일요일)을 요일·경고 없이 출력하는 Mode 2 리포트는 조용히 틀린 효력
기한이다. 잡을 곳은 등록부 — ingest 시 한 번 — 이지, 나중에 창이 이미 움직인 뒤가 아니다.

## 모드

### Mode 1: 갱신 ingest (검토에서 핸드오프 / 수동 추가·편집)

saas-msa-review·vendor-agreement-review가 갱신·해지 조항을 찾으면 레코드를 핸드오프한다.
등록부에 append한다. 같은 상대방의 레코드가 이미 있으면, 이게 교체(갱신된 계약)인지 추가
계약인지 묻는다.

수동 추가·편집도 여기서: 한 번에 한 필드씩 묻거나(또는 paste 수용) 기존 레코드의 한 필드를
갱신하고 확인 후 기록. 필수 필드는 `counterparty`, `agreement_type`, `current_term_end`,
`notice_period_days`, `auto_renew`, `owner`. `cancel_by_*`는 위 영업일 점검을 거쳐 계산한다.

### Mode 2: 다가오는 것 (디폴트 — 갱신 워처 에이전트의 주 출력)

**디폴트 조회 창:** 향후 90일. (renewal-watcher 에이전트가 주 1회 이 모드를 돌려 알림 목적지에
게시한다.)

**긴급도 밴드는 half-open 구간 — 기한은 정확히 한 밴드에 산다.** `send_by_effective − today`
(전달 버퍼 반영)를 쓴다. 14·45·90일은 각각 정확히 한 밴드에만 속한다 — 여기서 off-by-one이
나면 가장 급한 항목이 덜 급한 버킷으로 들어간다.

- 🔴 **해지통보 기한 0–13일** (14일 미만 — 오늘 포함)
- 🟠 **해지통보 기한 14–44일**
- 🟡 **해지통보 기한 45–89일**
- (90일 이상은 디폴트 창 밖 — 사용자가 `--days`로 90 너머를 줬을 때만 포함)

```markdown
## 갱신 — 향후 90일

### 🔴 해지통보 기한 0–13일

| 상대방 | 해지통보 기한 | 갱신일 | 연 금액 | 담당 | 비고 |
|---|---|---|---|---|---|
| [상대방] | **[날짜]** | [날짜] | [금액] | [담당자] | [비고] |

### 🟠 해지통보 기한 14–44일

[같은 표]

### 🟡 해지통보 기한 45–89일

[같은 표]

---

**권고 행동:**
- [ ] [상대방] — [사업 담당자]에게 핑: 유지할 것인가?
- [ ] [상대방] — 갱신가 무제한; 창이 닫히기 전 대체 벤더 견적으로 leverage 확보
```

등록부에 창 내 갱신이 약 10건 이상이거나 사용자가 요청하면: 대시보드를 제안한다(CLAUDE.md
`## 산출물` → 데이터 무거운 산출물의 대시보드 옵션 참조). 이 출력에 맞춰 제안 — 긴급도 밴드별
(🔴 / 🟠 / 🟡) 카운트, 해지통보 기한 타임라인, 상대방·갱신일·연 금액·담당자로 정렬 가능한
등록부 뷰.

### Mode 3: CLM·전자서명 도구 스캔으로 등록부 채우기 (CLM 연결 시)

CLM이 연결되어 있고 등록부가 비어 있거나 stale일 때만:

1. CLM에서 상태 "활성"이고 갱신일 필드가 있는 모든 계약을 조회
2. 전자서명 도구에서 최근 24개월 완료 봉투 중 메타데이터에 "구독"·"갱신"·"자동갱신"이 있는 것 조회
3. 각 hit에서 갱신 메커니즘을 추출해 등록부에 추가
4. 메타데이터로 갱신일을 정할 수 없는 것은 플래그 — 사람이 계약을 읽어야 함

CLM·전자서명 도구가 연결되어 있지 않으면 이 모드는 동작하지 않는다 — 로컬 등록부로만
동작하고, 추가는 Mode 1(검토 핸드오프·수동 입력)에서 온다. 특정 벤더 MCP를 가정하지 않는다 —
CLM이 무엇이든(Ironclad·Agiloft 등) 연결된 도구를 쓴다. 이것은 일회성 일괄 적재다. 그 후엔
검토 시점에 ingest한다.

### Mode 4: 놓친 창 (나쁜 소식 리포트 — `--missed`)

```markdown
## 놓친 해지통보 창

다음 계약은 해지통보 기한이 이미 지났고 해지 기록이 없습니다:

| 상대방 | 해지통보 기한(지남) | 갱신일 | 상태 |
|---|---|---|---|
| [상대방] | [날짜] | [날짜] | [날짜]에 자동갱신 예정 |

**옵션:**
- 늦은 해지 협상 (거의 안 통하지만 물어볼 가치는 있음)
- 갱신 수용, 내년 해지통보 기한을 지금 표시
- 계약의 다른 해지권 점검 (임의해지·사유 있는 해지). 갱신·자동연장 조항이 고객 해지권을
  부당하게 제한·배제하면 **약관규제법 §9** 무효 검토 대상일 수 있다 — 정형 약관이면. `[검토]`
```

## 게이트: 갱신 수락 또는 거절

갱신일을 추적하는 것은 리서치다. 그것에 *행동*하는 것 — 해지(불갱신) 통보를 보내거나,
자동갱신을 발사하게 두거나, 갱신서에 서명·날인하는 것 — 은 consequential한 법적 단계다.

**갱신을 수락·거절하기 전(불갱신 통보 발송, 또는 해지통보 기한이 지나도록 자동갱신을
방치하는 것 포함):** `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`의
`## 누가 이 플러그인을 사용하나`를 읽는다. 역할이 변호사가 아니면:

> 이 단계는 법적 결과를 낳습니다(다음 기간을 약정하거나 관계를 종료). 변호사와 검토하셨나요?
> 예면 진행합니다. 아니면, 변호사에게 가져갈 브리프입니다:
>
> [1페이지 요약 생성: 상대방, 현 계약기간 종료일과 해지통보 기한, 갱신가 메커니즘, 아무것도
> 안 하면 어떻게 되는지, 옮길 경우 대체 벤더, 창이 닫히기 전 변호사에게 물을 세 가지.]
>
> 변호사를 찾아야 하면: 대한변호사협회·지방변호사회 또는 대한법률구조공단(공익) 상담 안내를 이용하세요.

이 게이트를 명시적 yes 없이 넘어가지 않는다.

## 통합: 갱신 워처 에이전트

이 플러그인의 renewal-watcher 에이전트가 이 스킬을 스케줄(디폴트 주 1회)로 돌려 "다가오는"
리포트를 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md` →
`## 하우스 스타일` → 갱신 알림 목적지(Slack 채널 또는 이메일)에 게시한다. Mode 2가 에이전트의
주 출력이다.

## 이 스킬이 하지 않는 것

- 계약을 해지하지 않는다. 언제 결정할지 알려준다.
- 갱신 여부를 결정하지 않는다. 기한과 사업 담당자를 surface한다.
- 갱신일을 찾으려 계약을 읽지 않는다 — 그것은 검토 시점에 일어난다. 갱신일 없이 등록부에 든
  계약은 수동으로 추가된 것이고 누군가 빈칸을 채워야 한다.
