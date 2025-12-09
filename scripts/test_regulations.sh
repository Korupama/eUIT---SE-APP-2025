#!/bin/bash
# Test script to seed regulations and verify they're loaded

set -e

echo "🚀 Starting regulations seeding test..."
echo ""

# Test 1: Seed regulations
echo "📥 Calling seed-regulations endpoint..."
RESPONSE=$(curl -s -X POST http://localhost:5128/api/admin/seed-regulations)
echo "Response: $RESPONSE"
echo ""

# Test 2: Get regulations
echo "📄 Calling GET /api/public/regulations..."
RESPONSE=$(curl -s -X GET http://localhost:5128/api/public/regulations)
echo "Response (first 500 chars):"
echo "$RESPONSE" | head -c 500
echo ""
echo ""

# Test 3: Try downloading a specific regulation
echo "📥 Listing first PDF file in StaticContent/documents..."
FIRST_PDF=$(ls -1 /Users/home/Documents/GitHub/eUIT---SE-APP-2025/src/backend/StaticContent/documents/*.pdf 2>/dev/null | head -1)
if [ -n "$FIRST_PDF" ]; then
    PDF_NAME=$(basename "$FIRST_PDF")
    echo "Found: $PDF_NAME"
    echo "Trying to download: http://localhost:5128/files/$PDF_NAME"
    curl -s -I http://localhost:5128/files/"$PDF_NAME" | head -5
fi

echo ""
echo "✅ Test completed!"
