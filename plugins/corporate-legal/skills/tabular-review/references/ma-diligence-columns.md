# M&A 실사 — 표준 열 세트

매수측 대상 계약 표 검토의 기본 스키마. 딜에 따라 열을 추가하거나 제거. 이것은 출발점이지
체크리스트가 아니다 — 본계약의 진술보장 항목과 실사 요청목록이 실제로 중요한 것을 결정한다.

```yaml
schema:
  name: "M&A 실사 — 표준"
  columns:
    - id: counterparty
      label: "상대방"
      type: verbatim
      prompt: "대상 법인 이외의 계약 당사자 이름을 문서에 표기된 그대로 적어라."

    - id: agreement_type
      label: "계약 유형"
      type: classify
      options: [msa, 발주서, 라이선스_in, 라이선스_out, 임대차, 용역, 공급, 유통, nda, 합작, 대여, 보증, 근로, 기타]
      prompt: "어떤 종류의 계약인가?"

    - id: effective_date
      label: "효력발생일"
      type: date
      prompt: "계약이 언제 효력을 발생했나?"

    - id: term
      label: "기간"
      type: duration
      prompt: "초기 계약 기간은?"

    - id: auto_renewal
      label: "자동갱신"
      type: classify
      options: [없음, 연간, 고정기간, 무기한]
      prompt: "계약이 자동 갱신되나? 갱신 주기는?"

    - id: termination_for_convenience
      label: "임의해지"
      type: classify
      options: [없음, 양당사자, 대상법인만, 상대방만]
      prompt: "어느 당사자가 사유 없이 해지할 수 있나?"

    - id: termination_notice
      label: "해지 통지 기간"
      type: duration
      prompt: "해지에 필요한 통지 기간은?"

    - id: change_of_control
      label: "지배권 변경"
      type: classify
      options: [침묵, 사전동의_필요, 동의_불합리하게_거부_불가, 자동해지, 통지만, 상대방_해지권]
      prompt: "계약이 대상 법인의 지배권 변경(영업양도·합병·주식양수도 포함)을 다루나? 트리거 조건과 효과는? 한국 M&A에서 영업양도와 합병의 승계 효과가 다름에 유의."

    - id: assignment
      label: "양도제한"
      type: classify
      options: [침묵, 사전동의_필요, 동의_불합리하게_거부_불가, 자유양도, 계열사_양도_가능, 양도_불가]
      prompt: "대상 법인이 이 계약을 양도할 수 있나? 한국 영업양도·합병의 포괄승계 여부도 고려. 제한 조건은?"

    - id: exclusivity
      label: "독점·경업금지"
      type: classify
      options: [없음, 독점공급자, 독점고객, 경업금지, 임직원_비유인, 지역_제한, 최혜대우]
      prompt: "계약이 어느 당사자의 경쟁 또는 다른 거래처와의 계약을 제한하나?"

    - id: liability_cap
      label: "책임한도"
      type: currency
      prompt: "책임 상한이 있나? 금액 또는 배수는?"

    - id: indemnification
      label: "면책"
      type: classify
      options: [없음, 상호, 대상법인_면책제공, 상대방_면책제공, ip_only, 제3자_청구_only]
      prompt: "누가 누구에게 어떤 사항에 대해 면책을 제공하나?"

    - id: governing_law
      label: "준거법"
      type: verbatim
      prompt: "어느 국가·지역의 법이 적용되나?"

    - id: dispute_resolution
      label: "분쟁해결"
      type: classify
      options: [소송, 구속력있는_중재, 비구속적_중재, 조정선행, 침묵]
      prompt: "분쟁은 어떻게 해결하나? 소송·중재 어느 것인가? 중재면 기관·규칙은?"

    - id: confidentiality
      label: "비밀유지"
      type: classify
      options: [없음, 상호, 대상법인_의무, 상대방_의무, nda_별도_참조]
      prompt: "계약에 비밀유지 의무가 있나? 범위와 기간은?"

    - id: ip_ownership
      label: "IP 소유권"
      type: classify
      options: [침묵, 대상법인_소유, 상대방_소유, 공동소유, 용역_결과물_대상법인, 용역_결과물_상대방]
      prompt: "계약 이행 중 만들어지는 지식재산의 소유권은? 직무발명(발명진흥법) 관련 약정이 있나? [검토]"

    - id: data_rights
      label: "데이터·개인정보"
      type: classify
      options: [없음, 처리위탁_DPA, 공동처리, 데이터_이전_제한, 데이터_소유권_규정]
      prompt: "계약이 개인정보 처리위탁·공동처리·데이터 이전을 다루나? 개인정보보호법 준수 약정이 있나? [검토]"

    - id: minimum_commitment
      label: "최소 의무 물량·금액"
      type: currency
      prompt: "구매·사용·지급에 대한 최소 의무가 있나? 금액 또는 수량은?"

    - id: price_adjustment
      label: "가격 조정"
      type: classify
      options: [없음, 지수_연동, 협의_갱신, 일방적_변경권, 최혜대우_가격]
      prompt: "가격이 고정인가, 조정 가능한가? 조정 메커니즘은?"

    - id: expiry_date
      label: "만료일"
      type: date
      prompt: "현재 기간의 만료 또는 계약 종료 예정일은?"
```

---

## 딜 유형별 주요 추가 열

- **테크·IP 집약 대상:** 소스코드 에스크로, 오픈소스 제한(카피레프트 위험), 데이터 권리, 모델 학습 권리, API 접근, **직무발명 승계·보상 약정(발명진흥법)** — IP 대상은 직무발명 승계 여부 및 발명자 보상 지급 여부를 별도 열로 추가 권장 `[검토]`

- **헬스케어·생명과학:** 임상시험 의무, 식약처(MFDS) 인허가 관련 조항, 의약품 공급 의무·우선공급, 의료기기 인허가 승계 여부 `[검토]`

- **정부조달·공공기관:** 관급계약 특수조건(국가계약법·지방계약법), 하도급 제한, 정보보호 요구사항, 입찰참가자격 승계 가능 여부 `[검토]`

- **부동산:** 갱신 옵션, 임차료 인상(물가연동·협의), 관리비 분담, 임대차보호법 적용 여부, 대항력·우선변제권, 임대인 동의 조건 `[검토]`

- **규제 금융:** 금융위원회·금감원 인허가 승계·변경신고 의무, 금융규제법상 자본 요건, 겸업 제한·이해충돌 조항, 투자자 보호 의무 `[검토]`

---

## 빠른 첫 패스를 위한 주요 축소 열

전체 스키마가 너무 광범위하다면 첫 패스에서 이 5개로 시작:

1. `change_of_control` — 이 거래로 트리거되는 계약이 있나?
2. `assignment` — 매수인에게 이전 가능한가?
3. `termination_for_convenience` — 상대방이 거래를 이유로 이탈할 수 있나?
4. `expiry_date` — 종결 전후에 만료되는 계약이 있나?
5. `governing_law` — 준거법이 한국법이 아닌 계약이 있나?

이 5개가 즉각적인 딜 위험을 가장 빠르게 드러낸다. 나머지는 두 번째 패스로.

---

## 직무발명 주의

IP 집약 대상에서는 **발명진흥법상 직무발명 승계** 여부가 중요한 데이터포인트다. 핵심 IP가
대상 법인 소유인지, 발명자(창업자·직원)로부터 적법하게 승계됐는지, 보상이 지급됐는지를
별도 열 또는 `ip_ownership` 열의 노트로 캡처한다. 직무발명 승계·보상 관련 약정이 없거나
부족하면 `diligence-issue-extraction`으로 이슈 메모 작성 권장. `[검토]`

---

## 한국 준거법·분쟁해결 컨텍스트

`governing_law`와 `dispute_resolution`의 정규화 기준:

- 준거법이 대한민국법이 아닌 계약(미국 특정 주, 영국, 싱가포르 등)은 이상치로 플래그 — 외국 준거법 적용 시 분석에 외국 변호사 검토 필요 `[외국법 — 외국 변호사 검증 필요]`
- 분쟁해결이 `소송`이면 관할 법원(서울중앙지방법원 등) 확인. `구속력있는_중재`이면 중재 기관(대한상사중재원·ICC·SIAC 등)과 중재지 확인.
- 준거법과 분쟁해결 조항이 불일치하는 계약(한국법 준거 + 외국 중재)은 별도 플래그.
