---
name: review
description: >
  들어온 계약(벤더 MSA·서비스계약, NDA, SaaS 구독계약)을 플레이북 대조 검토하기 전 라우터.
  계약서·별첨 제목으로 구조를 식별해 맞는 검토 서브스킬(vendor-agreement-review,
  nda-review, saas-msa-review)로 라우팅하고, 결과를 하나의 메모로 통합한다. 사용자가
  "이 계약 검토", "계약 검토해줘", "이 MSA 봐줘", "이 NDA 괜찮나", "이 SaaS 계약 좀",
  "이거 어느 검토"라고 하거나 검토할 계약을 첨부할 때 사용.
argument-hint: "[파일 경로 | Drive 링크 | [CLM ID] | 텍스트 paste]"
---

# /review

들어온 계약을 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`의
플레이북 대조 검토한다. 이 스킬 자체는 검토하지 않는다 — **라우터**다: 제목으로 계약 구조를
식별하고, 매도인측인지 매수인측인지 먼저 판정하고, 맞는 서브스킬을 고르고, `confirm_routing`이
켜져 있으면 진행 전 사용자에게 확인한 뒤 dispatch한다.

라우팅·확인·핸드오프 규칙은 실무 수준
`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`(공유 가드레일·플레이북·
산출물·검토 선호)에서 읽는다 — 그 파일이 정본이고, 이 텍스트와 충돌하면 그 파일이 우선한다.

## 매터 컨텍스트

실무 수준 CLAUDE.md `## 매터 워크스페이스` 확인. `활성화`가 `✗`(사내 사용자의 디폴트)이면 이
단락 skip — 스킬은 실무 수준 컨텍스트 사용, 매터 머시너리 비활성. 활성이고 활성 매터 없으면:
"어느 매터입니까? `/commercial-legal:matter-workspace switch <slug>` 실행하거나 `practice-level`
말씀." 활성 매터의 `matter.md` 로드. 산출물은
`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/matters/<매터-slug>/`. `매터 간
컨텍스트`가 `on`이 아니면 다른 매터 파일 절대 안 읽음.

---

## 목적

라우터는 게이트웨이지 종착지가 아니다. 일은 계약 구조를 식별하고, 어느 측 플레이북이 적용되는지
판정하고, 맞는 검토 스킬로 라우팅하는 것 — 깊은 조항별 검토는 서브스킬이 한다. "이거 그냥 빨리
봐줘"로 들어온 계약이 잘못된 플레이북(매도인측 입장을 매수인측 계약에)으로 검토되는 것을 막는
지점이 여기다.

## 절차

### Step 1: 플레이북 로드

`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`를 읽는다. 파일이 없거나
`[PLACEHOLDER]`를 포함하면 멈추고:

> "이 플러그인은 유용한 검토를 내기 전 셋업이 필요합니다. `/commercial-legal:cold-start-interview`를
> 먼저 실행하세요 — 플레이북을 학습해야 그 대조 검토를 할 수 있습니다."

같은 파일의 `## 검토 선호` → `confirm_routing`도 읽는다. 필드가 없으면 `true`로 취급한다.

### Step 2: 계약 받기

파일 경로·Drive 링크·[CLM ID]·텍스트 paste 중 하나로 받는다. 없으면 묻는다. 파일을 못 읽으면
공유 가드레일 `## 파일 접근 실패`대로 — 침묵으로 실패하지 않고 무엇이 일어났는지 말하고 paste·fix 요청.

### Step 3: 매도인측 vs 매수인측 먼저 판정

**라우팅 전 가장 먼저 하는 일.** 어느 측인지가 서브스킬이 적용할 플레이북 행 전체를 좌우한다 —
위험 성향, 표준·폴백 조건, 책임 한도, 면책 방향, IP 귀속, 해지권이 측에 따라 뒤집힌다. 매도인측
입장을 매수인측 계약에, 또는 그 반대로 적용하는 것은 라우터가 막아야 할 1차 실패 모드다.

`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md` `## 플레이북`의 `활성
측(side)`을 먼저 읽는다. 그 뒤 이 계약에서 회사가 어느 측인지 판정:

- **매도인·공급자측** — 회사가 제품·서비스를 판매. 우리가 공급자. 보통 우리 계약서. 상대방이 우리
  것을 산다.
- **매수인·구매자측** — 회사가 제3자 벤더·공급자로부터 구매. 우리가 고객. 보통 그들 계약서. 우리가
  그들 것을 산다.

보통 누구 계약서인지로 명확하다(서두·당사자 정의·수수료 흐름 방향). 불명확하면 묻는다: "이 계약에서
우리가 파는 쪽입니까(공급자), 사는 쪽입니까(고객)?" 측을 침묵으로 가정하지 않는다.

### Step 4: 문서 구조 읽기 — 제목 먼저

본문을 읽기 전에 추출한다:

- 주계약 제목(예: "용역계약서", "물품공급계약서", "비밀유지계약서", "소프트웨어 구독계약")
- 모든 별첨·부속서·부록·첨부 제목(예: "별첨 1 — 개인정보 처리위탁 계약", "별지 2 — 발주서/주문서",
  "부속서 B — 서비스 수준 합의(SLA)")

이게 라우팅 신호다. 본문 키워드만으로 판단하지 않는다 — "비밀유지"가 곳곳에 나오는 40쪽짜리 MSA는
NDA가 아니다.

### Step 5: 서브스킬 선택

각 문서·섹션 제목을 스킬에 매핑한다. 라우팅 대상은 실제 KR 커맨드명을 쓴다:

| 문서/섹션 제목이 담고 있는 것 | 스킬 |
|---|---|
| 비밀유지계약서, NDA, 기밀유지약정(주계약일 때) | **`/commercial-legal:nda-review`** (빠른 트리아지) |
| 용역계약, 업무위탁, 컨설팅, 기본계약(MSA), 작업기술서(SOW) | **`/commercial-legal:vendor-agreement-review`** |
| 구독, SaaS, 클라우드 서비스, 자동갱신 발주서, 정기 요금 소프트웨어 라이선스 | **`/commercial-legal:saas-msa-review`** (vendor-agreement-review에 overlay) |
| 개인정보 처리위탁 계약, DPA(별첨 또는 단독) | **`/commercial-legal:vendor-agreement-review`** → 개인정보 보호 섹션에 노트(PIPA 분석은 `/privacy-legal:dpa-review` 핸드오프) |
| 서비스 수준 합의, SLA(별첨) | **`/commercial-legal:saas-msa-review`** → SLA 섹션에 노트 |

복수 스킬이 적용될 수 있다. 흔한 조합:

- MSA + DPA 별첨 → `/commercial-legal:vendor-agreement-review`, DPA는 노트
- SaaS 구독 + 발주서 + SLA 별첨 → `/commercial-legal:saas-msa-review`(셋 다 cover)
- MSA + 자동갱신 발주서 → `/commercial-legal:vendor-agreement-review` + `/commercial-legal:saas-msa-review` overlay

제목만으로 구조가 진짜 모호하면(예: 별첨 목록 없이 "계약서"라고만 된 문서), 본문 첫 2쪽을 읽어
해소한다 — 그 뒤 멈추고 라우팅한다. 이게 P0 차단 조항인지, NDA가 아니라 MSA인지 같은 주관적
판단이 불확실하면 `[검토]`로 플래그한다(공유 가드레일 `## 주관적 법률 판단의 결정 자세`).

### Step 6: confirm_routing honoring

`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md` `## 검토 선호`의
`confirm_routing`이 `true`(또는 필드 부재)이면, 진행 전 확인한다:

```
이렇게 검토하려 합니다:

측(side): [매도인측 / 매수인측] — [근거 한 줄, 예: "우리 표준 용역계약서, 우리가 공급자"]

식별된 문서:
- [주계약 제목] → [스킬]
- [별첨 A 제목] → [처리 방식]
- [별첨 B 제목] → [처리 방식]

맞나요? (예 / 아니오 — 또는 제가 잘못 본 것을 알려주세요)
```

확인을 기다린 뒤 진행한다. 사용자가 측이나 라우팅을 정정하면 그 지시를 적용하고 진행한다.

`confirm_routing`이 `false`이면 묻지 않고 진행한다. 라우팅 결정(측 판정 포함)을 검토 메모 상단에
로깅해 무엇이 적용됐는지 사용자가 볼 수 있게 한다.

### Step 7: 서브스킬 실행

각 스킬의 워크플로우를 끝까지 따른다. 판정된 측과 식별된 문서 구조를 핸드오프로 전달한다 — 서브스킬이
측을 다시 판정하지 않게 한다. 복수 스킬이 적용되면 순차 실행하고 결과를 **하나의 메모로 통합**한다 —
별도 메모를 여러 개 만들지 않는다. 스킬 간 심각도 바닥 규칙(공유 가드레일)을 지킨다: 업스트림 🔴
발견은 다운스트림이 침묵으로 낮추지 않는다.

### Step 8: 에스컬레이션 점검

어떤 발견이든 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`
`## 에스컬레이션` 매트릭스의 검토자 권한을 초과하면(금액 임계점, 무제한 책임, IP 양도, 플레이북
"절대 안 됨", 약관규제법 무효 가능 조항 등) `/commercial-legal:escalation-flagger`로 라우팅해 경로를
정하고 요청 초안을 잡는다.

### Step 9: 후속 제안

산출물 형식·마무리는 `~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`
`## 산출물`을 따른다(문서 헤더, ⚠️ 검토자 메모 한 블록, 깔끔한 본문, 다음 단계 의사결정 트리,
데이터 무거우면 대시보드 옵션). 이 라우터가 자체로 덧붙이는 자연스러운 후속:

- 사업 담당자용 이해관계자 요약(`/commercial-legal:stakeholder-summary`)
- 트래킹된 변경(레드라인) .docx
- [CLM] 레코드 생성(연결된 경우)
- 갱신 등록부 추가(자동갱신 발견 시 — `/commercial-legal:renewal-tracker`)

실제로 관련 있는 핸드오프만 제안한다. 모든 것을 boilerplate로 append하지 않는다.

---

## confirm_routing 설정

`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md`의 `## 검토 선호`에서 읽는다:

```markdown
## 검토 선호

confirm_routing: true   # false로 두면 라우팅 확인을 건너뛰고 자동 진행
```

콜드스타트 인터뷰가 이 선호를 묻는다. 디폴트는 `true` — 라우팅 확인 켜짐. 신뢰가 쌓이면 사용자가
`false`로 둘 수 있다.

---

## 예시

```
/commercial-legal:review vendor-msa.pdf
```

```
/commercial-legal:review https://drive.google.com/file/d/ABC123
```

```
/commercial-legal:review
[계약 텍스트 paste]
```

---

## 엣지 케이스

**측이 계약과 안 맞는다.** 실무 프로파일의 `활성 측`은 매도인측인데 들어온 계약이 명백히 벤더가
우리에게 파는 매수인측 계약이면 — 침묵으로 활성 측을 적용하지 않는다. 플래그: "실무 프로파일은
매도인측이 기본인데 이 계약은 우리가 사는 쪽으로 보입니다. 매수인측 플레이북으로 검토하겠습니다 —
맞나요?" 측은 계약 사실이지 디폴트가 아니다.

**잘못된 스킬로 강제하지 않는다.** 사용자가 단일 계약 검토 실행 중 거래 메모나 이해관계자 알림을
요청하면, 공유 가드레일 `## 셔터지 차안경 아님`대로 — 잘못된 템플릿에 강제하지 않고 요청한 것을
직접 산출하되 플러그인 가드레일을 적용한다.

**doctrinal 질문은 직접 답한다.** 사용자가 문서 검토 질문이 아니라 상사·계약법 doctrine 질문을
하면(약관규제법 무효 사유, 민법 §398 손해배상액 예정 감액 등), 라우팅하지 말고 직접 답하되
가드레일(출처 attribution·인용 위생·결정 자세)을 적용한다.

## 마무리

`~/.claude/plugins/config/claude-for-legal-kr/commercial-legal/CLAUDE.md` `## 산출물`의 다음 단계
의사결정 트리로 마무리한다 — 통합 검토 메모에 옵션 맞춤화. 트리가 산출물. 변호사가 고른다.
