# Excel 출력 사양

## Claude in Excel / Office 에이전트가 사용 가능한 경우

Office 에이전트를 통해 Excel에서 직접 워크북을 빌드한다. 서식 보존, 검토자가 익숙한 도구에서
바로 작업 가능, 셀 설명 패턴을 네이티브로 지원하므로 선호 경로다.

## 사용 불가능한 경우 — openpyxl 사용

`python3 -c "import openpyxl"`으로 확인. 미설치이면 설치 제안 (`pip3 install openpyxl`) 또는 CSV로 대체.

## 워크북 구조

**시트 1: `Review`** (메인 그리드)
- 1행: 산출물 헤더 (병합 셀, 실무 CLAUDE.md `## 산출물`의 헤더)
- 2행: 열 레이블
- 3행~: 문서 1건당 1행
- A열: 문서명 / 경로
- B열~: 스키마 열 순서대로, 열 1개씩
- 모든 데이터 열 뒤에 숨긴 `_source` 열: `[인용] | [위치]`
- 데이터 열 셀의 설명(comment) = 인용과 위치 (숨겨도 hover 시 표시)
- 상태별 셀 색상: 색 없음 = `answered`, `#FFF2CC` (연노랑) = `unclear` 또는 `needs_review`, `#EFEFEF` (연회색) = `not_present`
- 데이터 + `_source` 그룹 뒤에 `Verified` 열: 기본 공백. 검토자가 채움. 드롭다운 검증: `✓`, `✗`, `?`.

**시트 2: `Flags`**
- `unclear` 또는 `needs_review`인 셀마다 1행
- 열: 문서, 열명, 상태, 값(있으면), 인용, 위치, 비고
- 검증 작업 대기열. 열 기준으로 정렬해 검토자가 유사 판단을 묶어 처리.

**시트 3: `_schema`**
- `.review-schema.yaml`의 열 정의, 열마다 1행: id, label, type, options, prompt
- 파일을 자기 설명적으로 만든다. 6개월 후 파일을 여는 파트너도 무엇을 물었는지 볼 수 있다.

**시트 4: `_summary`**
- 문서 수, 열 수, 실행 날짜
- 열별 answered / not_present / unclear / needs_review 카운트
- 정규화 패스가 플래그한 열 목록
- 검증 알림 텍스트

## 하지 말 것

- 색상 코딩 없이 plain text만 쓰지 않는다 — 상태 색상이 검토자가 플래그를 한눈에 찾게 해준다.
- `_source` 열을 생략하지 않는다 — 원문 인용은 스프레드시트의 핵심이다.
- `Verified` 열을 미리 채우지 않는다 — 검토자가 채운다.
- 셀 설명과 `_source` 열을 양쪽 다 쓴다 — 하나가 숨겨지거나 삭제돼도 인용이 살아있다.

## 수식 주입 방어

Excel·Sheets·CSV 출력에 셀을 쓰기 전, 수식 주입을 무력화한다. 상대방 출처 텍스트(계약 인용,
당사자명, 등기 데이터, CLM 추출값)는 공격자 통제 입력이다. `=`, `+`, `-`, `@`, 탭(`\t`), 캐리지리턴(`\r`)으로
시작하는 셀은 수식 또는 행 구조 파괴로 해석된다.

- **단일 따옴표 접두:** `'=SUM(A1:A10)` → `=SUM(A1:A10)` (텍스트로 표시, 실행 안 됨)
- **문서 텍스트, 도구 결과, 사용자 붙여넣기에서 온 모든 셀에 적용.** 직접 작성한 열 헤더와 계산된 값은 안전.
- **CSV: 삽입된 쉼표, 큰따옴표, 줄바꿈도 이스케이프** (RFC 4180 인용 방식).
- 이것은 선택이 아니다. 사용자가 Excel에서 여는 스프레드시트가 매크로를 실행하거나 DDE로 데이터를 유출하면 공급망 공격이 된다.

**이 세션 외부에서 온 모든 값 — 상대방 텍스트, VDR 추출 문자열, 외부 제공값 — 은 이스케이프 대상이다.**
열 헤더처럼 직접 제어하는 값과 스킬이 계산한 값은 안전하다.

## openpyxl 예시 스니펫

```python
from openpyxl import Workbook
from openpyxl.styles import PatternFill, Font
from openpyxl.utils import get_column_letter

YELLOW = PatternFill(start_color="FFF2CC", end_color="FFF2CC", fill_type="solid")
GRAY   = PatternFill(start_color="EFEFEF", end_color="EFEFEF", fill_type="solid")

def escape_cell(value: str) -> str:
    """수식 주입 방어: 위험 문자로 시작하는 값에 단일 따옴표 접두"""
    if isinstance(value, str) and value and value[0] in "=+-@\t\r":
        return "'" + value
    return value

def state_fill(state: str):
    if state in ("unclear", "needs_review"):
        return YELLOW
    if state == "not_present":
        return GRAY
    return None

wb = Workbook()
ws_review = wb.active
ws_review.title = "Review"
ws_flags  = wb.create_sheet("Flags")
ws_schema = wb.create_sheet("_schema")
ws_summary = wb.create_sheet("_summary")

# 1행: 산출물 헤더
ws_review.merge_cells("A1:Z1")
ws_review["A1"] = "대외비 · 변호사·의뢰인 비밀유지 대상 — 변호사의 법률자문 목적으로 작성됨 (변호사법 §26)"
ws_review["A1"].font = Font(bold=True)

# 2행: 열 레이블 (스키마 순서)
# ... 이하 열·행 작성 로직
```
