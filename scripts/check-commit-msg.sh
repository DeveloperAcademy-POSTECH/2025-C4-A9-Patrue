#!/usr/bin/env bash

# ✅ set 명령어: 리눅스 및 유닉스 쉘에서 환경 설정 및 변수 관리에 사용하는 명령어
# -e: 에러시 즉시 스크립트 종료.
# -u: 정의되지 않은 변수 사용 시 에러.
set -eu


# script 에서 사용할 변수 설정
COMMIT_MSG_FILE=$1                                # 커밋 메시지 파일 (훅에서 최초 인자로 전달)
COMMIT_MSG=$(tr -d '\r' < "$COMMIT_MSG_FILE")     # 윈도우 CR 제거한 커밋 메시지 전체
TITLE=$(printf '%s\n' "$COMMIT_MSG" | head -n 1)  # 제목 추출

# ✅ 예외 커밋 (머지 커밋·README 수정 등)
if grep -Eq "^(Merge pull request|README\.md 업데이트)" <<<"$TITLE"; then
  exit 0
fi

# ✅ 제목 정규식 (Type: → 공백 → 설명)
TITLE_REGEX='^[A-Z][a-zA-Z]+:\s+.+'  
if ! grep -Eq "$TITLE_REGEX" <<<"$TITLE"; then
  cat <<EOF
❌ 제목 형식 오류
👉 제목은 'Type: 설명' 형식이어야 합니다.
   예시) 'Feature: 혼잡도 Swfit Chart 구현', 'Fix: Isa의 개그'
EOF
  exit 1
fi

# ✅ 제목에서 타입을 포함한 설명의 길이를 42자 이하로 강제
TITLE_LEN=$(printf '%s' "$TITLE" | wc -m)
if [ "$TITLE_LEN" -gt 42 ]; then
  echo "❌ 제목 길이 오류"
  echo "👉 커밋 제목의 길이가 현재 ${TITLE_LEN}자입니다."
  echo "👉 커밋 제목이 42자를 초과하지 않도록 수정해주세요."
  exit 1
fi
