# 법망 (Beopmang) MCP 통합 가이드

> 법망 MCP를 claude-for-legal-kr 플러그인의 런타임 데이터 소스로 사용하는 방법.

## 법망이란

법망(Beopmang)은 한국 법령·판례·행정규칙 등을 검색 가능한 MCP(Model Context Protocol)
서버로 제공하는 무료 공공 서비스. URL: `https://api.beopmang.org/mcp`.

데이터는 법제처 Open API와 국회 Open API를 1차 소스로 사용, 매주 토요일 동기화.

## 수록 데이터 (2026.3.28. 기준)

| 분류 | 건수 | 코멘트 |
|---|---|---|
| 법령 | 약 6,000건 | 헌법·법률·시행령·시행규칙·국회규칙·대법원규칙·헌법재판소규칙·중앙선거관리위원회규칙·감사원규칙 |
| 판례 | 약 172,000건 | 대법원·고등법원·지방법원 |
| 헌재결정 | 37,577건 | 위헌·합헌·각하 등 모든 종국결정 |
| 의안 | 약 114,000건 | 국회 의안정보시스템 + 국회 회의록 |
| 행정규칙 | 약 24,000건 | 각부처 고시·훈령·예규 |
| 해석례 | 약 9,000건 | 법제처 법령해석 |
| 자치법규 | 약 159,000건 | 광역·기초자치단체 조례·규칙 |
| 조약 | 약 4,000건 | 양자·다자 |

## 인증·Rate Limit

- **인증:** 없음 (인증키 불필요)
- **Rate Limit:** 분당 100회 (IP·클라이언트 단위로 추정 — 공식 명시 없음. 자세한 내용은
  본 가이드 하단 참조)
- **응답 속도:** 조문 검색 5ms / 판례 검색 9ms (공식 발표)

## 등록

Claude Code에서:
```bash
claude mcp add beopmang https://api.beopmang.org/mcp --transport http
```

확인:
```bash
claude mcp list
```

`beopmang: https://api.beopmang.org/mcp (http) - ✓ Connected` 표시되어야 함.

또는 본 레포의 헬퍼 스크립트:
```bash
./scripts/install-beopmang-mcp.sh
```

## MCP 도구 카탈로그

법망 MCP는 5개 엔드포인트, 13개 액션 제공:

### `/law` — 법령

**검색:**
```
mcp__beopmang__law search "[검색어]"
mcp__beopmang__law search {"query": "개인정보", "mode": "semantic"}  # semantic 검색
```

`mode`: `keyword` (기본) / `semantic` / `hybrid`.

**가져오기:**
```
mcp__beopmang__law get {"name": "개인정보보호법 제28조의8"}
mcp__beopmang__law get {"name": "개인정보보호법", "depth": 2}  # 본법 + 시행령 + 시행규칙
```

`depth`: `0` (해당 법령만) / `1` (시행령 포함) / `2` (시행규칙까지).
**위임조문 체인** 조회의 핵심 — 1회 요청으로 본법-시행령-시행규칙 모두.

**히스토리·diff:**
```
mcp__beopmang__law history {"name": "개인정보보호법"}
mcp__beopmang__law diff {"name": "...", "from": "2023-09-15", "to": "current"}
```

### `/case` — 판례

**검색:**
```
mcp__beopmang__case search "[검색어]"
mcp__beopmang__case search {"query": "개인정보 영향평가 의무", "court": "대법원"}
```

**가져오기:**
```
mcp__beopmang__case get {"id": "[판례 ID]"}
```

### `/bill` — 의안

```
mcp__beopmang__bill search "AI 기본법"
mcp__beopmang__bill get {"id": "[의안 번호]"}
```

### `/tools` — 종합 도구

**종합 조회 (overview):** 한 법령에 대한 조문 + 관련 판례 + 관련 의안 + 인용 법령을 1회 요청으로:
```
mcp__beopmang__tools overview {"law": "개인정보보호법"}
```

**환각방지 인용 검증 (verify):**
```
mcp__beopmang__tools verify {"citation": "개인정보보호법 §28-8①1호"}
```

응답:
```json
{
  "exists": true,
  "current_text": "...",
  "last_updated": "2023-09-15",
  "warnings": []
}
```

또는:
```json
{
  "exists": false,
  "suggestions": ["개인정보보호법 §28-7", "개인정보보호법 §28-8①2호"],
  "warnings": ["citation may be outdated or fabricated"]
}
```

**비교 (compare):**
```
mcp__beopmang__tools compare {"laws": ["개인정보보호법 §15", "정보통신망법 §22"]}
```

### `/help` — API 스키마

```
mcp__beopmang__help
```

## 표준 스킬 통합 패턴

### 패턴 1: 조문 인용 검증 (모든 스킬에 포함 권장)

스킬이 PIPA·정보통신망법 등 법조를 인용할 때:

```markdown
인용: PIPA §28-8①1호.

```
mcp__beopmang__tools verify {"citation": "개인정보보호법 §28-8①1호"}
```

응답이 `exists: true`면 출력에 `[법망 ✓]` 태그, `exists: false`면 `[검증 실패]`.
```

### 패턴 2: 위임조문 체인 조회

```markdown
PIPA §33 (영향평가)와 시행령 §35 (의무 트리거)를 한 번에:

```
mcp__beopmang__law get {"name": "개인정보보호법 제33조", "depth": 2}
```

응답에 본법 + 시행령 + 시행규칙의 관련 조문 포함.
```

### 패턴 3: 판례 검색

```markdown
"개인정보 영향평가 의무 위반"에 대한 판례:

```
mcp__beopmang__case search {"query": "개인정보 영향평가 의무 위반", "court": "대법원"}
```

대법원 판례 우선, 인용 시 `[법망 — 대법원 YYYY-MM-DD 선고 YYYY다XXXX 판결]` 형식.
```

### 패턴 4: 종합 조회 (research-heavy 스킬에서)

```markdown
한 법령에 대한 종합 컨텍스트 (조문 + 판례 + 의안 + 인용 법령):

```
mcp__beopmang__tools overview {"law": "위치정보의 보호 및 이용 등에 관한 법률"}
```

위치정보법 전체 + 관련 판례·의안·인용된 다른 법령 한 번에 받음.
```

## 429 응답 (Rate Limit 초과) 처리

분당 100회 초과 시 HTTP 429. 단순 지수 백오프:

```
1. 429 응답 받음
2. 1초 대기 후 재시도
3. 다시 429면 2초 대기 후 재시도
4. 다시 429면 4초 대기 후 재시도
5. 최대 3회 재시도, 그래도 429면 사용자에게 알림:
   "법망 API rate limit 초과. 1분 후 재시도하거나 다른 도구로 진행."
```

스킬은 이 백오프 로직을 명시적으로 구현할 필요 없음 — Claude Code의 MCP 클라이언트가 표준
HTTP 재시도 로직 적용. 단, 지속적 429 발생 시 사용자에게 friendly한 메시지 출력.

## Rate Limit 정책 (비공식)

법망 about 페이지는 "분당 100회"만 명시, 단위는 미공개. 정황상 **IP/클라이언트 단위로 추정**:

1. 인증키 없는 무료 공공 API가 글로벌 100/min이면 5명만 동시 써도 마비 — 운영 불가
2. 법망 about 페이지가 "500 동시 스트레스 테스트", "4분에 20,000 요청 처리" capacity 자랑 — 글로벌 100/min 일 리 없음
3. MCP는 클라이언트가 직접 `https://api.beopmang.org/mcp` 호출 — 각 사용자 IP에서 직접 카운트되는 게 자연스러움

**결론:** 각 사용자가 자기 IP의 quota 사용. 개발자(플러그인 제작자)는 자기 작업 quota만, 배포 후 사용자에게는 무관.

**단, 정책 변경 가능성:** 법망이 향후 정책을 명문화하거나 변경할 수 있음. 운영 중 변경되면
README의 면책에 추가, 사용자에게 알림.

## 모범 사례

### Do
- 모든 법조 인용에 `verify` 호출 (특히 핀포인트 인용)
- `depth: 2` 활용해 위임조문 체인 1회 호출
- `semantic` 검색 활용 (의미 기반 검색이 강함)
- 검증된 인용에 `[법망 ✓]` 태그 명시
- 검증 실패는 `[검증 실패]` 또는 `[모델 지식 — 검증 필요]`로 정직하게 표시

### Don't
- 같은 조문을 매 turn마다 verify 호출 — 한 세션 내 캐싱 (Claude Code MCP 캐시 활용)
- 판례 본문 전체를 매번 fetch — 검색 결과 요약으로 충분한 경우 많음
- 행정 결정례 (PIPC·공정위 등)를 법망에서 찾으려 하기 — 법망 미커버, `docs/DATA_GAPS.md`

## 법망 미커버 영역

자세한 내용은 [`DATA_GAPS.md`](DATA_GAPS.md). 요약:

- 개인정보보호위원회 결정례
- 분쟁조정위원회 결정례
- 공정거래위원회 의결례
- 방통위 의결례
- 노동위원회 판정례
- 외국법 (GDPR·CCPA 등)

이런 경우 웹 검색·수동 첨부·외국법 변호사 자문으로 대체.

## 트러블슈팅

### 등록 실패

```
$ claude mcp add beopmang https://api.beopmang.org/mcp --transport http
ERROR: ...
```

확인:
- 인터넷 연결
- Claude Code 버전 (MCP HTTP transport 지원 버전)
- 방화벽·프록시 (회사 환경에서 외부 HTTPS 차단 가능성)

### 응답 없음

```
$ claude mcp call beopmang law search "개인정보보호법"
(no response or timeout)
```

확인:
- `claude mcp list`에 beopmang이 `✓ Connected`인가
- 법망 서비스 가용성 (https://api.beopmang.org 브라우저 접근)
- Rate limit (429 응답이 silently swallow되는지)

### 인용 검증 false positive·negative

법망 데이터는 매주 토요일 동기화. 그 사이 시행된 조문은 일시적으로 미반영 가능. 의심
시 법제처 (`https://www.law.go.kr`) 직접 확인.

## 참고

- 법망 메인: https://api.beopmang.org
- 법망 About: https://api.beopmang.org/about
- 법망 OpenAPI 명세: https://api.beopmang.org/openapi.json
- 법제처 법령정보센터 (1차 데이터): https://www.law.go.kr
- 국회 의안정보시스템 (1차 데이터): https://likms.assembly.go.kr/bill
