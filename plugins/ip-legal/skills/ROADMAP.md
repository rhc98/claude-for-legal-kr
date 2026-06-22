# ip-legal 스킬 포팅 로드맵

**현재 상태: Phase A 완료(스캐폴드), B~E 진행 중.** 상류 11스킬 + KR 신규 2스킬(employee-invention·
trade-secret-protection) + ip-renewal-watcher 에이전트. 남은 것은 Phase F(E2E 런타임 검증 — 법망 복구 후).
기준 템플릿은 `../../corporate-legal/skills/`·`../../commercial-legal/skills/`, 상류 원본은
`anthropics/claude-for-legal/ip-legal/skills/`.

상류는 **미국 IP(USPTO·DMCA·Lanham Act·특허 §101/102/103·DTSA/UTSA)**가 전제다. IP는 속지주의 —
권리는 등록·발생한 관할에서만 효력. 한국은 **특허청(KIPO) 단일 등록 + 국제출원(PCT·마드리드·헤이그)**
체계이고, 출원·심판은 **변리사**, 침해소송·계약·형사는 **변호사** 영역으로 이원화된다. 1:1 매핑이 안 되는
지점은 단정 말고 `[검토]` 플래그.

## 포팅 매핑

| 상류 스킬 | KR 포팅 | Phase | 핵심 재맥락화 |
|---|---|---|---|
| cold-start-interview | 1:1 + KR | B | "IP footprint" → 권리 영역 mix·등록 footprint·집행 입장·직무발명/영업비밀 체계 |
| customize | 1:1 | B | CLAUDE.md 부분 수정 (타 포팅과 동일) |
| matter-workspace | 1:1 | B | commercial/corporate 패턴 재사용. "매터" = 한 권리/분쟁/거래/클리어런스 건 |
| clearance | 재작성 | C | 상표 등록가능성 — **KIPRIS 검색**(법망 미커버), 상표법 §34 부등록사유 + 부정경쟁방지법 §2 혼동 overlay |
| fto-triage | 재작성 | C | 자유실시(FTO) — 특허법 §29 차단특허, 청구항 대비, **특허청/KIPRIS 데이터 갭** |
| invention-intake | 재작성 | C | 특허성 스크리닝 — 신규성·진보성(§29)·특허받을 수 있는 자(§33), 한국 출원전략(국내우선권·PCT) |
| infringement-triage | 재작성 | C | 특허·상표·디자인 침해 — §126 침해금지·§128 손배 추정·과실추정·침해죄, 대응 라우팅 |
| cease-desist | 재작성 | D | **경고장/내용증명** 실무, 부당경고 역공 위험, 승인 매트릭스 |
| takedown | **재작성(최대)** | D | DMCA → **저작권법 §103 복제·전송 중단요청**·OSP 책임제한(§102)·정보통신망법, 반론·재게시 |
| ip-clause-review | 재작성 | D | 계약 IP 조항 — 권리귀속·실시허락·보증·면책. **직무발명 귀속**(발명진흥법) 연계 |
| oss-review | 재작성 | D | OSS 라이선스 컴플라이언스 — copyleft 전염성·고지의무, 한국 배포 관행, 저작권법 |
| **employee-invention** (KR 신규) | 신규 | D | 발명진흥법 §10·§15 **직무발명** 권리승계·예약승계·**정당한 보상** 산정. 상류 미커버, 한국 IP 핵심 |
| **trade-secret-protection** (KR 신규) | 신규 | D | 부정경쟁방지법 영업비밀 — 비밀관리성 요건·**KIPI 원본증명**·침해 대응. 상류 별도 스킬 아님 → KR 신설 |
| portfolio | 재작성 | E | 등록·갱신 기한 트래커 — **연차등록료·상표 10년 갱신·디자인 존속기간**, portfolio.yaml |
| ip-renewal-watcher (agent) | 재맥락화 | E | 특허청 기한 모니터(연차료·갱신) — corporate dataroom-watcher 패턴 |

## KR 신규 스킬 요약

타 플러그인(privacy `cross-border-transfer`, corporate `merger-control-filing` 등)처럼 한국 IP 실무 고유
영역을 신규 추가:

1. **employee-invention** (직무발명) — 발명진흥법 §10·§15. 권리승계·예약승계·정당한 보상 산정. 한국 기업
   IP의 핵심, US엔 동등 제도 없음. **최우선 신규 스킬.**
2. **trade-secret-protection** (영업비밀) — 부정경쟁방지법, KIPI 영업비밀 원본증명, 비밀관리성 요건.

## 법망 데이터 갭 (ip 특유 — `docs/DATA_GAPS.md` 보강)

- **특허청 KIPRIS**(상표·특허·디자인 등록/출원 원부) — 법망 미커버 → `[KIPRIS — 직접 검증 필요]`.
  clearance·fto·portfolio의 핵심 갭.
- **특허심판원(IPTAB) 심결** — 법망 미커버 → `[심판원 심결 — 직접 검증 필요]`
- **특허청 수수료·존속기간·갱신기한 고시** → `[특허청 고시 — 직접 검증 필요]`
- **KIPI 영업비밀 원본증명 / 한국저작권위원회 등록·조정 / 문체부 OSP 고시** → 각 직접 검증 태그
- ✓ 잘 커버: 특허법·실용신안법·상표법·디자인보호법·저작권법·부정경쟁방지법·발명진흥법 + 특허법원/대법원 판례

## 권장 실행 순서

**A(스캐폴드: plugin.json·.mcp.json 법망·CLAUDE.md IP 실무 프로파일·hooks·README·references/ip-currency-watch·
marketplace 등록) ✅ →
B(인프라: cold-start-interview·customize·matter-workspace — corporate/commercial 재사용) →
C(권리화·평가 핵심: clearance·fto-triage·invention-intake·infringement-triage) →
D(집행·계약: cease-desist·takedown·ip-clause-review·oss-review + 신규 employee-invention·trade-secret-protection) →
E(포트폴리오: portfolio + ip-renewal-watcher 에이전트) →
F(E2E 검증 — 법망 복구 후: 상표 clearance + 특허 침해 시나리오 1건, 전 인용 verify. 갭 픽스)**
