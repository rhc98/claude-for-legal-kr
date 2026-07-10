# 국가법령정보 MCP 통합 가이드

> 국가법령정보 MCP(`korean-law`)를 claude-for-legal-kr 플러그인의 런타임 데이터 소스로
> 사용하는 방법.

## 국가법령정보 MCP란

`korean-law`은 한국 법령·판례·행정 결정 등을 검색 가능한 MCP(Model Context Protocol)
서버로 제공합니다. 원격 스트리머블 HTTP 엔드포인트: `https://mcp.gomdori.app/law`.

데이터는 법제처 국가법령정보 Open API(open.law.go.kr)를 1차 소스로 사용합니다 — 이전
서구 커넥터 및 사설 미러가 동기화하던 것과 동일한 authoritative 원천입니다.

## 수록 데이터

국가법령정보 MCP는 법제처 국가법령정보 Open API가 제공하는 범위를 커버합니다:

- 법령 (헌법·법률·시행령·시행규칙 등)
- 판례
- 헌법재판소 결정
- 행정규칙 (고시·훈령·예규)
- 자치법규 (조례·규칙)
- 조약
- 법령해석례
- 행정심판재결
- 위원회 결정문 (조세심판·공정위·노동위·개인정보위 등 다수 도메인)

건수는 법제처 Open API 갱신에 따라 변하므로 여기서 특정 수치를 단정하지 않습니다.
최신 커버리지는 open.law.go.kr에서 확인하세요.

> **참고:** 국회 의안(법률안) 검색은 이 커넥터의 범위가 아닙니다 — 국가법령정보 MCP에
> `/bill` 등가 도구는 없습니다. 입법안 추적이 필요하면 국회 의안정보시스템
> (https://likms.assembly.go.kr/bill)을 직접 사용하세요.

## 인증·Rate Limit

- **인증:** 법제처 국가법령정보 Open API의 **OC 인증키 필요**. open.law.go.kr 가입 후
  이메일로 즉시 발급(무료, 약 1분). `?oc=<키>` 쿼리 파라미터 또는 `LAW_OC` 환경변수로 전달.
- **Rate Limit:** 법제처 국가법령정보 Open API 정책을 따릅니다. 별도의 고정 분당 한도를
  여기서 단정하지 않습니다.

## 등록

Claude Code에서 (`<OC키>`를 발급받은 인증키로 교체):
```bash
claude mcp add korean-law "https://mcp.gomdori.app/law?oc=<OC키>" --transport http
```

확인:
```bash
claude mcp list
```

`korean-law: https://mcp.gomdori.app/law?oc=... (http) - ✓ Connected` 표시되어야 함.

또는 본 레포의 헬퍼 스크립트 (`LAW_OC` 환경변수 사용):
```bash
export LAW_OC="<OC키>"
./scripts/install-korean-law-mcp.sh
```

### 로컬 설치 대안

원격 엔드포인트 대신 로컬에서 실행하려면 (Node 18+):
```bash
LAW_OC="<OC키>" npx korean-law-mcp
```

### 커버리지 최대화 대안 MCP

위원회 결정문 24종 등 더 넓은 커버리지가 필요하면 `ChangooLee/mcp-kr-legislation`
(132개 도구, 이메일 기반 키)을 함께 등록할 수 있습니다.

## MCP 도구 카탈로그

국가법령정보 MCP는 10개 도구 제공:

| 도구 | 용도 |
|---|---|
| `search_law` | 법령검색 → lawId/MST 반환 |
| `get_law_text` | 조문 전문 조회 |
| `get_annexes` | 별표·서식 조회 |
| `ordinance_radar` | 자치법규 검색 |
| `search_decisions` | 17개 도메인 통합검색 (판례·헌재·조세심판·공정위·노동위·관세·해석례·행정심판·개인정보위·권익위·소청·학칙·공사공단·공공기관·조약·영문법령) |
| `get_decision_text` | 결정·판례 본문 조회 |
| `legal_research` | task 8종: full_research/law_system/action_basis/dispute_prep/amendment_track/ordinance_compare/procedure_detail/document_review |
| `legal_analysis` | mode 4종: verify_citations/cite_check/applicable_law/impact_map |
| `discover_tools` | 사용 가능한 도구 탐색 |
| `execute_tool` | 도구 동적 실행 |

### `search_law` — 법령검색

```
mcp__korean-law__search_law {"query": "개인정보보호법"}
```

법령명·본문 키워드로 검색, `lawId`/`MST`(마스터 일련번호) 반환. 이후 `get_law_text`에서
이 식별자로 조문 전문을 가져옴.

### `get_law_text` — 조문 전문

```
mcp__korean-law__get_law_text {"query": "개인정보보호법 제28조의8"}
```

특정 조문의 현행 전문. 위임조문 관계(법률-시행령-시행규칙) 추적은 `legal_research`의
`law_system` task 활용.

### `get_annexes` — 별표·서식

```
mcp__korean-law__get_annexes {"query": "개인정보보호법 시행규칙 별지 제3호서식"}
```

### `search_decisions` — 판례·결정 통합검색

```
mcp__korean-law__search_decisions {"query": "개인정보 영향평가 의무", "domain": "판례"}
```

`domain`으로 17개 도메인 중 선택 (판례·헌재·공정위·노동위·개인정보위 등). 이후
`get_decision_text`로 본문 조회.

### `legal_analysis` — 인용검증·분석 (환각방지 핵심)

**인용 검증 (verify_citations):** 인용 조문의 실존 확인.
```
mcp__korean-law__legal_analysis {"mode": "verify_citations", "citation": "개인정보보호법 §28-8①1호"}
```

**판례 생사 확인 (cite_check / Citator):** 인용 판례의 폐기·변경 감지.
```
mcp__korean-law__legal_analysis {"mode": "cite_check", "citation": "대법원 2011다XXXXX"}
```

다른 mode: `applicable_law`(적용법령 판정), `impact_map`(영향관계 매핑).

### `legal_research` — 종합 리서치

```
mcp__korean-law__legal_research {"task": "law_system", "query": "개인정보보호법 제33조"}
```

task 8종: `full_research`(종합)·`law_system`(위임조문 체계)·`action_basis`(처분 근거)·
`dispute_prep`(분쟁 준비)·`amendment_track`(개정 추적)·`ordinance_compare`(자치법규 비교)·
`procedure_detail`(절차 상세)·`document_review`(문서 검토).

## 표준 스킬 통합 패턴

### 패턴 1: 조문 인용 검증 (모든 스킬에 포함 권장)

스킬이 PIPA·정보통신망법 등 법조를 인용할 때:

```markdown
인용: PIPA §28-8①1호.

```
mcp__korean-law__legal_analysis {"mode": "verify_citations", "citation": "개인정보보호법 §28-8①1호"}
```

응답이 실존 확인이면 출력에 `[국가법령정보 ✓]` 태그, 실패면 `[검증 실패]`.
```

### 패턴 2: 위임조문 체인 조회

```markdown
PIPA §33 (영향평가)와 시행령의 의무 트리거를 한 번에:

```
mcp__korean-law__legal_research {"task": "law_system", "query": "개인정보보호법 제33조"}
```

응답에 본법 + 시행령 + 시행규칙의 위임 관계·관련 조문 포함.
```

### 패턴 3: 판례 검색

```markdown
"개인정보 영향평가 의무 위반"에 대한 판례:

```
mcp__korean-law__search_decisions {"query": "개인정보 영향평가 의무 위반", "domain": "판례"}
```

대법원 판례 우선, 인용 시 `[국가법령정보 — 대법원 YYYY-MM-DD 선고 YYYY다XXXX 판결]` 형식.
인용 전 `cite_check`로 폐기·변경 여부 확인 권장.
```

### 패턴 4: 종합 조회 (research-heavy 스킬에서)

```markdown
한 법령에 대한 종합 컨텍스트 (조문 + 위임체계 + 관련 판례·결정):

```
mcp__korean-law__legal_research {"task": "full_research", "query": "위치정보의 보호 및 이용 등에 관한 법률"}
```

위치정보법 전체 + 관련 판례·인용된 다른 법령을 한 번에 받음.
```

## 429 응답 (Rate Limit 초과) 처리

법제처 Open API 정책 한도 초과 시 HTTP 429. 단순 지수 백오프:

```
1. 429 응답 받음
2. 1초 대기 후 재시도
3. 다시 429면 2초 대기 후 재시도
4. 다시 429면 4초 대기 후 재시도
5. 최대 3회 재시도, 그래도 429면 사용자에게 알림:
   "국가법령정보 API rate limit 초과. 잠시 후 재시도하거나 다른 도구로 진행."
```

스킬은 이 백오프 로직을 명시적으로 구현할 필요 없음 — Claude Code의 MCP 클라이언트가 표준
HTTP 재시도 로직 적용. 단, 지속적 429 발생 시 사용자에게 friendly한 메시지 출력.

## 인증키(OC) 트러블슈팅

- **OC 인증키 없이 등록:** 검색·조회가 인증 오류로 실패. open.law.go.kr에서 발급 후
  `?oc=<키>` 또는 `LAW_OC` 환경변수로 재등록.
- **키 노출 주의:** OC 인증키는 개인 발급분이므로 커밋·공유 금지. 환경변수·시크릿 매니저 사용.

## 모범 사례

### Do
- 모든 법조 인용에 `legal_analysis {"mode": "verify_citations"}` 호출 (특히 핀포인트 인용)
- 인용 판례는 `legal_analysis {"mode": "cite_check"}`로 폐기·변경 확인
- 위임조문 체계는 `legal_research {"task": "law_system"}`로 1회 조회
- 검증된 인용에 `[국가법령정보 ✓]` 태그 명시
- 검증 실패는 `[검증 실패]` 또는 `[모델 지식 — 검증 필요]`로 정직하게 표시

### Don't
- 같은 조문을 매 turn마다 verify 호출 — 한 세션 내 캐싱 (Claude Code MCP 캐시 활용)
- 판례 본문 전체를 매번 fetch — 검색 결과 요약으로 충분한 경우 많음
- 커버 범위 밖 자료(등록원부·해외법 등)를 국가법령정보에서 찾으려 하기 — `docs/DATA_GAPS.md`

## 국가법령정보 미커버 영역

자세한 내용은 [`DATA_GAPS.md`](DATA_GAPS.md). 요약:

- 국회 의안(법률안) — `/bill` 등가 도구 없음, 국회 의안정보시스템 직접 사용
- 특허청 KIPRIS 등록원부·출원 경과정보
- 특허심판원 심결
- 하급심 미공개 판결문
- 외국법 (GDPR·CCPA 등)

일부 위원회 결정문(개인정보위·공정위·노동위 등)은 `search_decisions`의 17개 도메인
통합검색으로 **부분 커버 가능**합니다. 더 넓은 커버리지는 `ChangooLee/mcp-kr-legislation`
등 대안 MCP를 병용하세요. 이런 경우 웹 검색·수동 첨부·외국법 변호사 자문으로 대체.

## 트러블슈팅

### 등록 실패

```
$ claude mcp add korean-law "https://mcp.gomdori.app/law?oc=<OC키>" --transport http
ERROR: ...
```

확인:
- OC 인증키가 올바른가 (open.law.go.kr 발급분)
- 인터넷 연결
- Claude Code 버전 (MCP HTTP transport 지원 버전)
- 방화벽·프록시 (회사 환경에서 외부 HTTPS 차단 가능성)

### 응답 없음

```
$ claude mcp call korean-law search_law "개인정보보호법"
(no response or timeout)
```

확인:
- `claude mcp list`에 korean-law가 `✓ Connected`인가
- OC 인증키 유효성
- Rate limit (429 응답이 silently swallow되는지)

### 인용 검증 false positive·negative

국가법령정보 데이터는 법제처 Open API 갱신 주기를 따릅니다. 최신 시행 조문은 반영 지연
가능. 의심 시 법제처 (`https://www.law.go.kr`) 직접 확인.

## 참고

- 국가법령정보 MCP: https://mcp.gomdori.app/law
- 법제처 국가법령정보 Open API (OC 인증키 발급): https://open.law.go.kr
- 법제처 법령정보센터 (1차 데이터): https://www.law.go.kr
- 국회 의안정보시스템 (의안은 별도): https://likms.assembly.go.kr/bill
- 커버리지 최대화 대안 MCP: https://github.com/ChangooLee/mcp-kr-legislation
