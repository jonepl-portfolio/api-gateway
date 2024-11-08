#!/usr/bin/env bats

setup_file() {
  # Check if test api gateway is running
  for _ in {1..10}; do
    if curl -s "localhost:8080" >/dev/null; then
      return 0
    fi
    sleep 2
  done
  
  echo "api-gateway-test is not built and started"
  exit 1
}

@test "Container runs successfully" {
  response=$(curl -s -o /dev/null -w "%{http_code}" "localhost:8080")

  [ "$response" -eq 301 ]
}

@test "nginx config has no template variables" {
  config_content=$(docker exec api-gateway-test cat /etc/nginx/nginx.conf)

  # Check for any placeholders like ${VARIABLE}
  if echo "$config_content" | grep -q '\${'; then
    echo "Template variable found in nginx config"
    false  # Fails the test if any placeholders are found
  else
    true   # Passes the test if no placeholders are found
  fi
}