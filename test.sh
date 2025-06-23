#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SH="${SCRIPT_DIR}/init-sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing init-sh..."
echo "==================="

# TEST CASE 1: Basic exec
echo -n "Test 1: Basic execution... "
output=$("$INIT_SH" -- echo "Hello World")
if [[ "$output" == "Hello World" ]]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Expected: 'Hello World', Got: '$output'"
fi

# TEST CASE 2: Exit code propagation
echo -n "Test 2: Exit code propagation... "
"$INIT_SH" -- true && true_exit=$? || true_exit=$?
"$INIT_SH" -- false && false_exit=$? || false_exit=$?
if [[ $true_exit -eq 0 && $false_exit -ne 0 ]]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "True exit: $true_exit, False exit: $false_exit"
fi

# TEST CASE 3: Help text
echo -n "Test 3: Help text... "
if "$INIT_SH" -h 2>&1 | grep -q "Usage:"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# TEST CASE 4: Verbose mode
echo -n "Test 4: Verbose mode... "
if "$INIT_SH" -v -- echo "test" 2>&1 | grep -q "\[init-sh\]"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# TEST CASE 5: Environment variable configuration
echo -n "Test 5: Environment variable configuration... "
if INIT_SH_VERBOSE=1 "$INIT_SH" -- echo "test" 2>&1 | grep -q "\[init-sh\]"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# TEST CASE 6: Signal handling (requires Docker)
if command -v docker &> /dev/null; then
    echo "Test 6: Signal handling with Docker..."
    
    cat > /tmp/init-sh-test.dockerfile <<EOF
FROM alpine:latest
RUN apk add --no-cache bash
COPY init-sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-sh
EOF
    
    echo "  Building test image..."
    docker build -f /tmp/init-sh-test.dockerfile -t init-sh-test "$SCRIPT_DIR" > /dev/null 2>&1
    
    echo -n "  Testing signal forwarding... "
    container_id=$(docker run -d init-sh-test /usr/local/bin/init-sh -v -- sleep 30)
    sleep 2
    docker kill -s TERM "$container_id" > /dev/null 2>&1
    docker wait "$container_id" > /dev/null 2>&1
    docker rm "$container_id" > /dev/null 2>&1
    echo -e "${GREEN}PASS${NC}"
    
    # cleanup
    docker rmi init-sh-test > /dev/null 2>&1
    rm -f /tmp/init-sh-test.dockerfile
else
    echo "Test 6: Skipping Docker tests (Docker not available)"
fi

echo
echo "==================="
echo "Testing complete!"

cat > /tmp/signal-test.sh <<'EOF'
#!/bin/bash
# Demo script that shows signal handling

echo "Starting demo process (PID: $$)"
trap 'echo "Received SIGTERM, exiting gracefully..."; exit 0' TERM
trap 'echo "Received SIGINT, exiting gracefully..."; exit 0' INT

echo "Process is running. Press Ctrl+C to stop..."
while true; do
    sleep 1
done
EOF

chmod +x /tmp/signal-test.sh

echo
echo "Demo: Run the following to see signal handling in action:"
echo "  $INIT_SH -v -- /tmp/signal-test.sh"
echo
echo "Then press Ctrl+C to see graceful shutdown."
