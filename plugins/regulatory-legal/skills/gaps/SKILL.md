---
name: gaps
description: >
  열린 갭 트래커 — 무엇이 플래그되었고 아직 종결되지 않았는지. 사용자가 "열린 갭이
  뭐야", "갭 트래커", "시정 상태"를 묻거나, 추적 중인 갭을 종결(--close GAP-ID) 또는
  위험수용(--accept GAP-ID)하려 할 때 사용.
argument-hint: "[선택: --close GAP-ID | --accept GAP-ID]"
---

# /gaps

1. 갭 트래커를 `~/.claude/plugins/config/claude-for-legal-kr/regulatory-legal/gap-tracker.yaml`에서 읽는다.
2. `--close`면: 갭을 해소 메모와 함께 종결로 표시.
3. `--accept`면: 위험수용 근거와 승인자를 기록, 상태 → risk-accepted.
4. 그 외에는: 열린 갭을 age·재료성 순으로 보고.

> 트래커 스키마 상세, 상태 보고 포맷, owner 알림 로직(건별 발송 확인, 예외 없음), 리마인더 주기, 종결·위험수용 모드, consequential-action gate는 **gap-surfacer** reference 스킬에 있다 — substantive 작업 전 로드한다.
