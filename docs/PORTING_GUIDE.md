# 포팅 가이드: claude-for-legal의 다른 플러그인을 한국화하기

> 이 가이드는 `privacy-legal` MVP 한국화 과정에서 추출한 패턴. 다른 9개 플러그인
> (commercial / corporate / employment / regulatory / ai-governance / ip / litigation /
> law-student / legal-clinic)을 같은 패턴으로 한국화할 때 따르세요.

플러그인 하나 풀세트 포팅에 약 2-3주(풀타임 1명 기준) 예상. 변호사·법무 실무자의 사실
검증을 거치면 더 오래 걸리지만 그게 가치 있는 작업.

---

## 8단계 포팅 체크리스트

각 플러그인에 대해 순서대로 진행. 1-3은 mechanical, 4-7은 substantive (법체계 지식
필요), 8은 verification.

### 1. 플러그인 디렉토리 부트스트랩

원본 `claude-for-legal/<plugin-name>/`을 `claude-for-legal-kr/plugins/<plugin-name>/`로 카피.
다음 파일 KR 용으로 갱신:

- `.claude-plugin/plugin.json`: `description` 한국어, `keywords`에 한국법 용어 추가
- `.mcp.json`: 서구 커넥터 제거, **법망 MCP 추가** (모든 플러그인 공통):
  ```json
  "beopmang": {
    "type": "http",
    "url": "https://api.beopmang.org/mcp",
    "title": "법망 (Beopmang)",
    "description": "한국 법령·판례·헌재결정·행정규칙·자치법규·의안·조약·해석례..."
  }
  ```
- `hooks/hooks.json`: 변경 거의 없음, 그대로 카피

### 2. CLAUDE.md 템플릿 한국화 (가장 큰 작업)

원본 `CLAUDE.md`는 placeholder 가진 템플릿 (40K 내외). 다음 순서로 작업:

1. **구조 유지**: 섹션 헤더 순서·계층 그대로 유지. 다른 스킬들이 이 구조에 의존.
2. **첫 단락 (configuration location 코멘트) 번역**: 경로는 마켓플레이스 이름을 따름
   (`~/.claude/plugins/config/<marketplace-name>/<plugin>/CLAUDE.md` — 본 레포 기준
   `~/.claude/plugins/config/claude-for-legal-kr/<plugin>/CLAUDE.md`), 안내문만 한국어로.
   포팅 시 본인 fork의 marketplace.json `name`을 따라 일관되게 갱신.
3. **각 섹션 한국화 — 단순 번역이 아닌 KR 재맥락화:**
   - "Who we are": controller/processor → 개인정보처리자/수탁자, 또는 플러그인별 한국 등가
   - "Regulatory footprint": 적용 한국법 카테고리로 (PIPA·신용정보법·근로기준법 등)
   - "Playbook": 한국 실무 관행 반영 (예: 위·수탁계약은 PIPA §26, 직위 협상은 한국 노사 관행)
   - "Escalation matrix": 한국 규제 당국 (PIPC·KISA·공정위·노동위·금감원 등)
   - "Outputs / work-product header": **한국법에 attorney work product 독트린 없음 명시**
     `~/.claude/plugins/cache/claude-for-legal-kr/plugins/privacy-legal/CLAUDE.md`의
     해당 섹션을 참고 — 변호사법 §26 비밀유지 + 한국 보호 한계 명시 필수.
4. **공유 가드레일 섹션 (가장 긴 부분) 한국 재맥락화:**
   - "No silent supplement" — KR 적용
   - "Currency trigger" — 한국법 변경 빈도 (PIPA 2023.9.15. 대개정 등)
   - "Verify user-stated legal facts" — `mcp__beopmang__verify` 활용
   - "Source attribution tags" — `[법망]`, `[법제처]`, `[국회 의안시스템]`, `[PIPC]`, `[KISA]`,
     `[settled — 마지막 확인 YYYY-MM-DD]`
   - "Jurisdiction recognition" — **한국이 디폴트**, 외국법 (GDPR·CCPA·일본 APPI 등) 들어오면
     인식하고 외국 변호사 자문 권고

### 3. 각 SKILL.md 한국화

원본 `skills/<skill-name>/SKILL.md` 각각에 대해:

1. **Frontmatter**: `description`을 한국어로 + 한국 트리거 phrase 추가
   ```yaml
   description: >
     ... 사용자가 "[한국어 트리거]", "[다른 한국어 트리거]"라고 할 때 사용.
   ```

2. **본문 한국어화** — 단순 번역 아닌 한국 법체계 재맥락화:
   - 미국·EU 법조 인용 → 한국법 인용 (법망 호출 코드 스니펫 포함)
   - 미국·EU 규제 당국 → 한국 규제 당국
   - 영문 약어 → 한국 약어 (DPA → 위·수탁계약, DSAR → 정보주체 권리행사 등)

3. **법망 통합 강제 패턴**:
   조문 인용하는 모든 위치에 다음 패턴 삽입:
   ```
   mcp__beopmang__law get "[법령명] 제[조]조"
   mcp__beopmang__tools verify {"citation": "..."}
   ```

4. **인용 검증 강제**:
   모든 외부 인용에 출처 태그 의무. `[모델 지식 — 검증 필요]`가 디폴트, 법망에서
   가져왔으면 `[법망]`.

5. **외국법 overlay 처리**: 미국·EU·일본 등 외국법 적용 가능 시나리오마다 "외국법 변호사
   자문 필요" 플래그.

### 4. 새 KR 전용 스킬 추가

원본 플러그인이 다루지 않는 한국 법체계 특수 사항은 신규 스킬로 추가. 예시:

- **privacy-legal**: `pipa-spi-handling` (민감정보·고유식별정보·주민번호), `cross-border-transfer` (§28-8)
- **commercial-legal** (예시): `subcontract-payment-protection` (하도급법 §13 등), `consumer-protection-overlay` (방문판매법·할부거래법)
- **employment-legal** (예시): `labor-committee-procedure` (노동위 부당해고 구제), `industrial-accident` (산재보상보험법)
- **corporate-legal** (예시): `fair-trade-overlay` (공정거래법 기업결합 신고), `kosdaq-ipo-checklist` (코스닥 상장)
- **ip-legal** (예시): `kipo-trademark-clearance` (특허청 상표 검색), `oss-license-korea` (한국 OSS 라이선스 관행)

### 5. agents·hooks 한국화 (있으면)

- `agents/*.md` (있으면): cron schedule, trigger phrase, 한국어 메시지
- `hooks/hooks.json`: 일반적으로 변경 거의 없음

### 6. references/ 한국화

- `references/currency-watch.md`: 한국법 변경 watch list (PIPA 대개정·새 시행령·PIPC 결정례 추세 등)
- `references/company-profile-template.md`: 첫 플러그인 포팅 시만 작성 (공유 회사 프로필 템플릿)
- 다른 reference 파일 (예: `references/dashboard-template.md`): 한국어 또는 그대로

### 7. README.md 한국화

`<plugin>/README.md`를 한국어로 재작성. 사용 예시는 한국 시나리오 (예: privacy-legal은
"국내 SaaS의 미국 AWS 사용" 시나리오).

### 8. End-to-End 검증

법망 등록 → 플러그인 설치 → cold-start-interview 실행 → 핵심 스킬 1-2개에서 실제
한국 법무 시나리오 실행 → 모든 조문 인용 verify 통과 확인.

---

## 법망 MCP 통합 패턴 (모든 플러그인 공통)

자세한 내용은 [`BEOPMANG_INTEGRATION.md`](BEOPMANG_INTEGRATION.md) 참조.

표준 호출 패턴:

### 패턴 1: 조문 검색

```
mcp__beopmang__law search "[검색어]"
```

여러 결과 반환, 사용자가 어느 것인지 선택 필요.

### 패턴 2: 조문 가져오기 (위임조문 체인 포함)

```
mcp__beopmang__law get {"name": "개인정보보호법 제28조의8", "depth": 2}
```

`depth: 2`로 호출하면 본법 + 시행령 + 시행규칙 1회 요청으로 받음.

### 패턴 3: 판례 검색

```
mcp__beopmang__case search "PIPA 영향평가 의무"
```

### 패턴 4: 인용 검증 (환각방지)

```
mcp__beopmang__tools verify {"citation": "개인정보보호법 §28-8①1호"}
```

응답: `{"exists": true, "current_text": "...", "last_updated": "..."}` 또는 `{"exists": false}`.

스킬은 인용 검증 후에만 출력에 표시. 미검증·실패 인용은 `[unverified]` 또는 `[검증 실패]` 표시.

---

## CLAUDE.md 리라이트 템플릿

가장 큰 작업이라 별도 가이드. privacy-legal의 CLAUDE.md를 패턴으로 사용:

### 섹션 매핑

| 원본 섹션 (영문) | KR 섹션 (한글) | 변경 필요? |
|---|---|---|
| Configuration location header | 설정 파일 위치 헤더 | 안내문만 번역, 경로 그대로 |
| Who we are | 우리는 누구인가 | controller/processor 등 용어 KR화 |
| Who's using this | 누가 이 플러그인을 사용하나 | 역할 카테고리 KR 법무 환경에 맞춤 |
| Available integrations | 연결 가능한 통합 | **법망 MCP 추가**, 다른 통합 KR화 |
| [Playbook section] | [플레이북 섹션] | 한국 법체계 + 한국 실무 관행으로 재작성 |
| Privacy policy commitments | 개인정보처리방침 약속 (privacy 플러그인) / 다른 플러그인은 해당 commitments | 한국 법령상 게재 의무 강화 |
| [Process section] | [처리 절차] | 한국 법령 응답 기한·면제 사유 등 |
| Escalation | 에스컬레이션 | 한국 규제 당국으로 |
| Seed documents | 시드 문서 | 그대로, 사용자가 한국 문서 업로드 |
| Outputs | 산출물 | **work-product 헤더에 한국 비밀유지 한계 명시** |
| Decision posture | 결정 자세 | 그대로 (원칙 동일) |
| Shared guardrails | 공유 가드레일 | 한국 재맥락화 + 한국 인용 패턴 |
| Scaffolding not blinders | 셔터지 차안경 아님 | 그대로 |
| Ad-hoc questions | ad-hoc 질문 | 한국어화 |
| Proportionality | 비례성 | 그대로 |
| Jurisdiction recognition | 관할 인식 | **한국이 디폴트** + 외국법 처리 |
| Retrieved-content trust | 가져온 콘텐츠 신뢰 | 그대로 |
| Handling retrieved results | 가져온 결과 처리 | 출처 태그를 KR로 (`[법망]` 등) |
| Large input / output | 큰 입력·출력 | 한국 도구 (i-CONNECT 등) 언급 |
| Currency watch | 현행성 워치 | KR currency-watch.md 참조 |
| Matter workspaces | 매터 워크스페이스 | 한국 법무법인 실무에 맞춤 |

### 한국 법체계 특수 — 모든 플러그인이 다뤄야 할 것

**Work-product 헤더와 한국 비밀유지**

원본의 다음 문구는 한국에서 그대로 쓰면 위험:
```
PRIVILEGED & CONFIDENTIAL — ATTORNEY WORK PRODUCT — PREPARED AT THE DIRECTION OF COUNSEL
```

KR에서는:
- 미국식 attorney work product 독트린 (FRCP 26(b)(3)) **없음**
- 변호사·의뢰인 비밀유지 (변호사법 §26)는 좁게 해석
- 사내·인하우스 변호사 작성물의 보호는 사안별 다툼
- **표지가 보호를 만들지 않는다**

KR 대체:
```
대외비 · 변호사·의뢰인 비밀유지 대상 — 변호사의 법률자문 목적으로 작성됨 (변호사법 §26)
※ 이 표지는 비밀유지 의지의 표시이며, 그 자체로 공개거부의 법적 근거가 되지 않는다.
   PIPC·검찰·법원의 자료제출 요구 시 적용 가능한 면제 사유는 사안마다 별도 판단을 요한다.
```

privacy-legal CLAUDE.md의 `## 산출물` 섹션을 정확한 표현 패턴으로 사용.

---

## 인용 검증 강제 패턴 (모든 SKILL.md에 들어가야)

각 SKILL.md의 적절한 위치에:

```markdown
> **침묵 보완 금지.** 법망 검색이 빈 결과면 보고 후 멈춤. 옵션 제시:
> (1) 쿼리 확장, (2) 다른 도구, (3) 웹 검색(`[웹 검색 — 검증 필요]` 태그), (4) 미검증 플래그 후 멈춤.
>
> **출처 attribution 태그:**
> - `[법망]` — 법망 MCP 결과
> - `[법제처]` — 법령정보센터 직접
> - `[국회 의안시스템]` — 의안 검색 결과
> - `[PIPC]` / `[KISA]` / 기타 규제 당국 사이트
> - `[settled — 마지막 확인 YYYY-MM-DD]` — 안정적 법조 인용 + 확인 날짜
> - `[검증 필요]` — 검증해야 할 모델 지식 인용
> - `[검증 필요-핀포인트]` — 핀포인트 인용 (가장 fabrication-prone)
> - `[사용자 제공]` — 사용자가 paste·link
```

---

## 데이터 갭 처리

법망이 커버하지 않는 영역:

- 개인정보보호위원회 결정례
- 분쟁조정위원회 결정례
- 공정거래위원회 의결례
- 방통위 의결례
- 노동위원회 판정례
- 금융감독원 분쟁조정 사례

해당 행정 결정례를 인용해야 하는 플러그인 (commercial-legal의 공정위 의결례, employment-legal의
노동위 판정례 등)은:
1. CLAUDE.md에 데이터 갭 명시
2. 사용자에게 수동 첨부 부탁 (URL·PDF·텍스트 paste)
3. 모든 인용에 `[규제 당국 결정 — 직접 검증 필요]` 태그
4. `docs/DATA_GAPS.md` 참조

자세한 내용은 [`DATA_GAPS.md`](DATA_GAPS.md) 참조.

---

## 플러그인별 핵심 한국법 매핑

각 플러그인을 한국화할 때 어느 한국법이 핵심인지 1페이지 매핑:

### commercial-legal-kr

| 영역 | 핵심 한국법 |
|---|---|
| 계약 일반 | 민법, 상법 |
| 약관 | 약관규제법 |
| 표준계약서 | 공정거래위원회 표준약관 |
| 하도급 | 하도급법 (수탁자 보호) |
| B2B 거래 일반 | 상법 + 공정거래법 (불공정 거래) |
| 소비자 보호 (B2C) | 전자상거래법, 할부거래법, 방문판매법, 소비자보호법 |
| 광고 | 표시광고법 |
| 위·수탁계약 (개인정보) | PIPA §26 (privacy-legal과 연계) |

### corporate-legal-kr

| 영역 | 핵심 한국법 |
|---|---|
| 회사 일반 | 상법 |
| 이사·이사회·주주총회 | 상법 |
| 자본조달 | 자본시장법 |
| 상장 | KRX·코스닥 상장규정 |
| 기업결합 신고 | 공정거래법 |
| 회계·감사 | 외감법 (외부감사법) |
| 외국인투자 | 외국인투자촉진법 |

### employment-legal-kr

| 영역 | 핵심 한국법 |
|---|---|
| 근로계약 | 근로기준법 |
| 임금 | 근로기준법 + 최저임금법 |
| 해고 | 근로기준법 §23 + 노동위 부당해고 구제 |
| 차별금지 | 남녀고용평등법, 장애인고용촉진법, 연령차별금지법 등 |
| 산재 | 산업재해보상보험법, 산업안전보건법 |
| 휴가·휴직 | 근로기준법, 남녀고용평등법 (육아휴직 등) |
| 노조 | 노조법 (노동조합 및 노동관계조정법) |

### ip-legal-kr

| 영역 | 핵심 한국법 |
|---|---|
| 특허·실용신안 | 특허법, 실용신안법 |
| 상표 | 상표법 + 특허청 KIPO |
| 디자인 | 디자인보호법 |
| 저작권 | 저작권법, 컴퓨터프로그램보호법 (구) |
| 영업비밀 | 부정경쟁방지법 |
| 오픈소스 | OSS 라이선스 (KOSS 등 한국 활용 관행) |

### regulatory-legal-kr

| 영역 | 핵심 |
|---|---|
| 입법 모니터링 | 국회 의안정보시스템 (법망에서 검색 가능), 법제처 입법예고 |
| 행정규칙 | 법망 행정규칙 데이터 |
| 분야별 | 산업별 (금융위, 식약처, 공정위 등) |

### ai-governance-legal-kr

| 영역 | 핵심 |
|---|---|
| AI 일반 | **AI 기본법** (2026.1.22. 시행) |
| AI + 개인정보 | PIPA §37-2 (자동화 결정) |
| AI 저작권 | 저작권법 + 학습 데이터 |
| EU AI Act | (외국법 — 한국 회사 영향 시) |

### litigation-legal-kr

| 영역 | 핵심 |
|---|---|
| 민사소송 | 민사소송법 |
| 형사 | 형사소송법 |
| 행정소송 | 행정소송법 |
| 가사 | 가사소송법 |
| 중재 | 중재법 (대한상사중재원 등) |
| 판례 검색 | 법망 case search |
| 외국 판결 집행 | 민사집행법 + 외국재판 승인 |

### law-student-kr

| 영역 | 핵심 |
|---|---|
| 로스쿨 (법학전문대학원) 시스템 | 변호사시험법, 로스쿨 교육과정 |
| 사법연수원 (구) | 폐지·유지 검토 사안 |
| 한국 변호사시험 (변시) | 변호사시험법 |

### legal-clinic-kr

| 영역 | 핵심 |
|---|---|
| 로스쿨 실무교육 | 법학전문대학원 설치·운영에 관한 법률 |
| 법률구조 | 법률구조법, 대한법률구조공단 |
| 공익변호사 | 공익법무관제도, 사단법인 형태 |

---

## 시작하기

1. 이 가이드 다 읽기
2. `privacy-legal` 풀세트 살펴보기 (`plugins/privacy-legal/`)
3. 포팅할 플러그인 결정
4. 원본 카피 + KR 디렉토리로 이름 변경
5. 8단계 체크리스트 따라 진행
6. 한국 변호사·법무 실무자에게 사실 검증 부탁 (가장 중요)
7. PR

질문·이슈는 GitHub Issues에.
