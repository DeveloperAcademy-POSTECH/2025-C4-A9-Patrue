#!/bin/bash

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# ✅ 예외 브랜치
# GitHub 를 통해 (자동적으로) 관리하는 브랜치
if echo "$BRANCH_NAME" | grep -qE "^(main|develop|release|dependabot/.*)$"; then
  exit 0
fi

# ✅ 사용 가능한 브랜치 prefix 목록
# 필요에 따라 원하는 prefix 수정 가능
PREFIX_REGEX="^(feature|fix|refactor|chore|docs)/[a-z0-9._-]+$"

if ! echo "$BRANCH_NAME" | grep -Eq "$PREFIX_REGEX"; then
  echo "❌ 브랜치명 형식 오류: '$BRANCH_NAME'"
  echo "❌ 현대 브랜치명으로 커밋할 수 없습니다. 올바른 브랜치명 형식을 사용해주세요."
  echo ""
  echo "👉 올바른 브랜치명 형식: prefix/설명"
  echo "✅ 사용가능 prefix: feature|fix|chore|refactor|docs"
  echo "✅ 예시: feature/congestion-chart-ui, fix/keyboard-crash, docs/update-readme"
  echo ""
  exit 1
fi

exit 0
