# 규제 소스 카탈로그 (한국)

reg-feed-watcher의 출발 카탈로그. 콜드스타트 인터뷰가 어느 소스를 watch할지 구성하고, 이 카탈로그가
옵션을 제공한다.

**⚠️ URL 미검증 표기.** 아래 URL·경로 상당수는 **실제 접속으로 확인 전 모델 지식**이다. 확인 안 한
것은 Notes에 `(verify)`로 표기했다. reg-feed-watcher가 실제 점검하기 전까지 `(verify)` 소스는
`[검증 필요]`로 취급하고, 확인 후 태그를 제거·확정한다. **URL을 지어내 확정 서술하지 않는다.**

**카탈로그 읽는 법:**
- **Format** — 피드가 반환하는 것: MCP(국가법령정보 커넥터, 구조화·최선), JSON/RSS(반구조화), HTML
  페이지(스크래핑·변경 감지 필요), 이메일(메일링 구독).
- **Auth** — None(공개), Key(무료 등록 키), Paid(구독).
- **Notes** — gotcha(RSS 유무·데이터 갭·검색 경로·`(verify)`).

⚠️ 표시 소스는 데이터 갭·RSS 부재·직접 검증 필요가 있으니 구성 전 확인.

---

## 1. 법령·입법 (1차)

공포 법령·입법예고·계류 의안·관보. **이 플러그인의 핵심 소스층.** 국가법령정보 MCP는 공포 법령을
커버하지만 입법예고·계류 의안은 커버하지 않는다 — 직접 검색으로 우회한다(아래 데이터 갭).

| Source | Feed URL | Format | Covers | Auth | Notes |
|---|---|---|---|---|---|
| 국가법령정보 MCP (`korean-law`) | `https://mcp.gomdori.app/law` | MCP | **공포** 법률·시행령·시행규칙, 판례·헌재결정, 행정규칙(부분), 위원회 의결(부분) | Key(OC) | **공포 법령은 이걸 우선.** `search_law`→`get_law_text`(현행/시행예정), `legal_research {"task":"amendment_track"}`. OC 인증키 필요(환경변수 `LAW_OC`). 상세: `docs/LAW_MCP_INTEGRATION.md`. |
| 관보 (대한민국 전자관보) | `https://gwanbo.go.kr` | HTML | 법령 공포문·고시·공고 원문 | None | **공포 확인의 1차 소스**(공포일 ≠ 시행일 — 부칙 대조). ⚠️ 공개 RSS 미확인 `(verify)`. 국가법령정보와 교차확인. |
| 법제처 국민참여입법센터 | `https://opinion.lawmaking.go.kr` | HTML | **입법예고·행정예고** 공고문, 의견제출 | None | **커넥터 범위 밖 — 직접 WebFetch.** 인용에 `[법제처]`. 의견제출 마감은 공고문의 실제 날짜(법정 하한: 입법예고 40일·행정예고 20일 `[검증 필요]`). ⚠️ 공개 RSS 미확인 `(verify)`. |
| 국회 의안정보시스템 | `https://likms.assembly.go.kr/bill` | HTML | **국회 계류 법률안**·심사경과(접수→위원회→체계자구→본회의→공포) | None | **⚠️ 데이터 갭 — 커넥터에 `/bill` 등가 도구 없음(`docs/DATA_GAPS.md` §1-B).** 직접 검색, 인용에 `[국회 의안시스템 — 직접 검증 필요]`. **계류 법안은 아직 법 아님 — 절대 material 아님, watch 고정.** 공포(관보) 확인 후에만 승격. |
| 국회입법예고 | `https://pal.assembly.go.kr` | HTML | 위원회 회부 법률안 입법예고·의견 | None | 국회법 §82-2 국회입법예고(10일 이상 `[검증 필요]`). ⚠️ 공개 RSS 미확인 `(verify)`. `[국회 의안시스템 — 직접 검증 필요]`. |
| 법제처 법령정보센터 | `https://www.law.go.kr` | HTML | 공포 법령·행정규칙·자치법규 원문(웹) | None | 국가법령정보 MCP의 웹 프런트. MCP 미응답 시 직접 확인용. `[법제처]`. |
| 법제처 행정규칙정보시스템 | `https://www.law.go.kr/admRulLsInfoP.do` `(verify)` | HTML | 고시·훈령·예규 | None | 국가법령정보 행정규칙 데이터가 부분·지연일 때 직접 확인. ⚠️ 경로 미검증 `(verify)`, RSS 미확인. |
| 자치법규정보시스템 (ELIS) | `https://www.elis.go.kr` | HTML | 지자체 조례·규칙 | None | 자치법규 watch 시. `ordinance_radar` MCP 도구로도 부분 검색. ⚠️ RSS 미확인 `(verify)`. |
| 규제정보포털 | `https://www.better.go.kr` | HTML | 규제영향분석·규제개혁위원회 심사·규제 존재여부 | None | 규제개혁위 심사 대상 예고안·규제영향분석서. ⚠️ 공개 RSS 미확인 `(verify)`. |

---

## 2. 중앙부처·위원회 (1차)

분야별 소관 부처·규제 위원회의 보도자료·행정예고·고시·의결 페이지. **RSS 유무는 소스마다 다르다** —
없으면 페이지 변경 감지·메일링으로 우회(⚠️ No public RSS 관행 유지). 규제기관 의결은 국가법령정보
`search_decisions`로 부분 커버되나 최신·전문은 기관 사이트가 우위 → `[규제 당국 결정 — 직접 검증 필요]`.

| Source | Feed URL | Format | Covers | Auth | Notes |
|---|---|---|---|---|---|
| 개인정보보호위원회 (PIPC) | `https://www.pipc.go.kr` | HTML | 개인정보보호법 고시·행정예고, 과징금·시정조치 의결, 보도자료 | None | 결정사항·자료실. 의결례는 `search_decisions {"domain":"개인정보위"}` 부분 → 최신·전문은 사이트. ⚠️ 공개 RSS 미확인 `(verify)`. `[규제 당국 결정 — 직접 검증 필요]`. |
| 금융위원회 (FSC) | `https://www.fsc.go.kr` | HTML | 자본시장법·전자금융거래법·신용정보법 하위규정, 감독규정 개정예고, 보도자료 | None | 정책·보도자료·입법예고 페이지. ⚠️ 공개 RSS 미확인 `(verify)`. |
| 금융감독원 (FSS) | `https://www.fss.or.kr` | HTML | 감독·검사, 시행세칙, 금융 관련 결정·제재 | None | 금융위와 교차. ⚠️ 공개 RSS 미확인 `(verify)`. `[규제 당국 결정 — 직접 검증 필요]`. |
| 공정거래위원회 (KFTC) | `https://www.ftc.go.kr` | HTML | 공정거래법·표시광고법·전자상거래법·하도급법·약관규제법 고시·의결례, 보도자료 | None | 의결·심결은 `search_decisions {"domain":"공정위"}` 부분 → 최신 전문은 사이트. ⚠️ 공개 RSS 미확인 `(verify)`. `[규제 당국 결정 — 직접 검증 필요]`. |
| 식품의약품안전처 (MFDS) | `https://www.mfds.go.kr` | HTML | 식품·의약품·의료기기·화장품 고시·행정예고, 보도자료 | None | 고시·행정예고가 잦음 → 행정예고 20일 `[검증 필요]` 마감 추적. ⚠️ 공개 RSS 미확인 `(verify)`. |
| 방송통신위원회 (KCC) | `https://www.kcc.go.kr` | HTML | 정보통신망법·전기통신사업법 하위규정, 의결·고시 | None | 의결사항. `search_decisions` 도메인 밖 가능 → 사이트 우선. ⚠️ 공개 RSS 미확인 `(verify)`. `[규제 당국 결정 — 직접 검증 필요]`. |
| 과학기술정보통신부 (MSIT) | `https://www.msit.go.kr` | HTML | 정보통신·AI·데이터 관련 고시·행정예고, 보도자료 | None | AI 기본법·데이터 규율 watch 시. ⚠️ 공개 RSS 미확인 `(verify)`. |
| 고용노동부 (MOEL) | `https://www.moel.go.kr` | HTML | 근로기준법·산업안전보건법 하위규정, 고시·행정예고 | None | 최저임금·고시 잦음. ⚠️ 공개 RSS 미확인 `(verify)`. |
| 국세청 (NTS) | `https://www.nts.go.kr` | HTML | 국세 고시·예규·해석, 보도자료 | None | 세법 하위규정·예규 watch 시. 조세심판은 `search_decisions {"domain":"조세심판"}` 부분. ⚠️ 공개 RSS 미확인 `(verify)`. |
| 소관 부처 일반 (국토부·환경부·산업부 등) | 각 부처 `www.<부처>.go.kr` `(verify)` | HTML | 개별법 소관 부처의 고시·행정예고·보도자료 | None | 인터뷰에서 우리 사업에 적용되는 개별법의 소관 부처를 지정. RSS 유무는 부처별 상이 — 없으면 페이지 변경 감지·메일링. ⚠️ URL·RSS 미검증 `(verify)`. |

---

## 3. 분야별 규제기관·심판기관 (1차·2차 혼재)

분야에 따라 추가로 볼 규제·분쟁·심판 기관. 결정·판정은 대부분 커넥터 부분 커버 → 기관 사이트 우위.

| Source | Feed URL | Format | Covers | Auth | Notes |
|---|---|---|---|---|---|
| 개인정보 분쟁조정위원회 | `https://www.kopico.go.kr` `(verify)` | HTML | 개인정보 분쟁조정 결정 | None | KISA 운영. `search_decisions` 도메인 밖 → 사이트·paste. ⚠️ URL·RSS 미검증 `(verify)`. |
| 노동위원회 (중앙·지방) | `https://www.nlrc.go.kr` | HTML | 부당해고·차별 시정 판정 | None | `search_decisions {"domain":"노동위"}` 부분 → 전문은 사건검색. ⚠️ 공개 RSS 미확인 `(verify)`. `[규제 당국 결정 — 직접 검증 필요]`. |
| 국민권익위원회 | `https://www.acrc.go.kr` `(verify)` | HTML | 행정심판재결·고충·부패방지 | None | `search_decisions {"domain":"권익위"}`·`{"domain":"행정심판"}` 부분. ⚠️ URL·RSS 미검증 `(verify)`. |
| 중앙행정심판위원회 (온라인행정심판) | `https://www.simpan.go.kr` `(verify)` | HTML | 행정심판 재결례 | None | 항고소송 전 임의·필요적 전치. `search_decisions {"domain":"행정심판"}` 부분. ⚠️ URL·RSS 미검증 `(verify)`. |
| 특허청 (KIPO) / KIPRIS | `https://www.kipo.go.kr` · `https://www.kipris.or.kr` `(verify)` | HTML | 특허·상표·디자인 고시·심판, 등록·출원 | None | 등록원부·심결은 커넥터 미커버(`docs/DATA_GAPS.md` §1-A). ip 분야 watch 시. ⚠️ RSS 미확인 `(verify)`. `[KIPRIS — 직접 검증 필요]`. |
| 헌법재판소 | `https://www.ccourt.go.kr` `(verify)` | HTML | 위헌·헌법불합치 결정(재입법 유발) | None | 위헌 결정은 규제 재입법·시행일 연기 신호. `search_decisions {"domain":"헌재"}`·MCP 커버. ⚠️ 사이트 RSS 미확인 `(verify)`. |

---

## 4. Secondary / 애그리게이터 (2차 — 권위 아님)

**이 소스의 콘텐츠는 lead지 authority가 아니다.** "PIPC가 X를 발표했다"는 2차 소스는: PIPC 사이트·
관보에서 X를 찾은 뒤 그것에 의존한다는 뜻이다. 이 피드에서 온 항목은 소스명 태그에 더해
`[검증 필요]`(2차 소스)를 붙인다. **그 자체 강도로 "항상 material"로 분류하지 않는다** — 1차 소스가
확인될 때까지 tier를 한 단계 내린다(demotion rule).

| Source | Feed URL | Format | Covers | Auth | Notes |
|---|---|---|---|---|---|
| 법률신문 | `https://www.lawtimes.co.kr` | HTML | 규제·입법·판례 뉴스, 논평 | None(일부 유료) | 국내 최다 커버. 1차 소스로 추적 필수. ⚠️ 공개 RSS 미확인 `(verify)`. `[검증 필요]`(2차). |
| 로펌 뉴스레터 (김앤장·태평양·광장·세종·율촌 등) | 각 로펌 사이트·이메일 `(verify)` | Email / HTML | 규제 동향 client alert, 실무 해석 | None(구독) | 무엇이·어디를 볼지 알려주는 데 유용하나 해석이다. 대부분 공개 RSS 없음 → 이메일 구독. `[검증 필요]`(2차) + 1차 추적. |
| 규제 트래커·법률 애그리게이터 (Lexology·JD Supra 등) | `https://www.lexology.com` · `https://www.jdsupra.com` `(verify)` | RSS(계정)/HTML | 로펌 alert 집계(한국 포함) | Account(무료) | 토픽·관할 필터 가능. 노이즈 많음. `[검증 필요]`(2차). ⚠️ 한국 커버리지 제한적 — 국내 1차 소스 우선. |

---

## 5. 피드가 없는 소스 (웹 변경 감지·이메일 필요)

일부 중요 소스는 공개 RSS를 제공하지 않거나 검색 인터페이스만 있다. 모니터링에는 (a) 웹 페이지 변경
감지(현재 미내장), (b) 이메일 메일링 구독, (c) reg-feed-watcher Tier 3 수동 입력(공고문 paste)이 필요.

| Source | URL | Notes |
|---|---|---|
| 국회 의안정보시스템 | `https://likms.assembly.go.kr/bill` | ⚠️ 데이터 갭 — 커넥터 범위 밖. 직접 검색, `[국회 의안시스템 — 직접 검증 필요]`, watch 고정. |
| 국민참여입법센터 | `https://opinion.lawmaking.go.kr` | ⚠️ 공개 RSS 미확인 `(verify)`. 입법예고·행정예고 직접 WebFetch, `[법제처]`. |
| PIPC·금융위·공정위·식약처·방통위 등 | 각 기관 사이트(§2) | 대부분 ⚠️ 공개 RSS 미확인 → 페이지 변경 감지·메일링·수동 입력. |
| 관보 | `https://gwanbo.go.kr` | ⚠️ 공개 RSS 미확인 `(verify)`. 공포 확인은 국가법령정보와 교차. |
| 로펌 뉴스레터 | 각 로펌 사이트 | 이메일 구독이 주 채널. `[검증 필요]`(2차). |

---

## 6. 추천 스타터 팩

**개인정보·데이터 in-house 팀:**
국가법령정보 MCP(공포 법령), 관보, 국민참여입법센터(입법예고·행정예고), 의안정보시스템(계류 의안 watch),
PIPC(고시·의결), 과기정통부·방통위(정보통신망법). 2차: 법률신문 + 로펌 뉴스레터 1-2개.

**금융·자본시장 in-house 팀:**
국가법령정보 MCP, 관보, 국민참여입법센터, 의안정보시스템, 금융위·금감원(감독규정 개정예고·제재),
공정위(표시광고·전자상거래 교차). 2차: 법률신문.

**소비자·유통·제조 규제 팀:**
국가법령정보 MCP, 관보, 국민참여입법센터, 의안정보시스템, 공정위(전자상거래법·하도급법·약관), 식약처
(식품·화장품 고시), 소관 부처(산업부·환경부 등). 2차: 법률신문 + Lexology(수출 관련 외국 규제 시).

---

## 소스 추가하기

이 카탈로그에 없는 소스를 추가하려면:
1. 피드 URL을 찾는다(`/rss`, `/feed`, 페이지 소스의 `<link rel="alternate" type="application/rss+xml">`).
   **없으면 없다고 기록** — 지어내지 않는다.
2. 브라우저·`curl`로 XML/JSON 반환을 검증한다. **검증 전에는 `(verify)` 표기.**
3. 사용자의 regulatory-legal CLAUDE.md `## 소스·피드 구성`에 추가: 소스명, URL, format, 커버 범위,
   해당 카테고리(법령·입법 / 중앙부처·위원회 / 분야별 / secondary).
4. 피드가 없으면 위 `## 5. 피드가 없는 소스`에 넣고 결정한다: 수동 입력, 이메일, 변경 감지.
