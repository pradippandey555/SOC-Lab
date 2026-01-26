#!/bin/bash

# HYBRID SETUP: Native Splunk (Host) + Docker Targets
# We need the User to provide the NEW Token from the Native Splunk.

echo "Enter your NEW Splunk HEC Token:"
read TOKEN

if [ -z "$TOKEN" ]; then
    echo "Error: Token cannot be empty."
    exit 1
fi

echo "🛑 Cleaning up old containers..."
docker-compose down 2>/dev/null

echo "📝 Creating Hybrid Docker Configuration..."
# Note: We do NOT define a 'splunk' service here because it is running natively!
# We point splunk-url to 172.17.0.1 (The Docker Host IP) so containers can reach the Native Splunk.

cat <<EOF > docker-compose.yml
version: '3'

services:
  # --- ATTACKER ---
  kali:
    image: kalilinux/kali-rolling
    container_name: kali
    tty: true
    networks:
      - soc_net
    logging:
      driver: splunk
      options:
        splunk-token: "$TOKEN"
        splunk-url: "http://172.17.0.1:8088"
        splunk-insecureskipverify: "true"
        splunk-verify-connection: "false"
        tag: "kali"

  # --- TARGETS ---
  metasploitable:
    image: tleemcjr/metasploitable2
    container_name: metasploitable
    tty: true
    networks:
      - soc_net
    logging:
      driver: splunk
      options:
        splunk-token: "$TOKEN"
        splunk-url: "http://172.17.0.1:8088"
        splunk-insecureskipverify: "true"
        splunk-verify-connection: "false"
        tag: "metasploitable"

  juiceshop:
    image: bkimminich/juice-shop
    container_name: juiceshop
    ports:
      - "3000:3000"
    networks:
      - soc_net
    logging:
      driver: splunk
      options:
        splunk-token: "$TOKEN"
        splunk-url: "http://172.17.0.1:8088"
        splunk-insecureskipverify: "true"
        splunk-verify-connection: "false"
        tag: "juiceshop"

  dvwa:
    image: vulnerables/web-dvwa
    container_name: dvwa
    ports:
      - "80:80"
    networks:
      - soc_net
    logging:
      driver: splunk
      options:
        splunk-token: "$TOKEN"
        splunk-url: "http://172.17.0.1:8088"
        splunk-insecureskipverify: "true"
        splunk-verify-connection: "false"
        tag: "dvwa"

networks:
  soc_net:
    driver: bridge
EOF

echo "🚀 Starting Targets..."
docker-compose up -d

echo "✅ Targets Deployed."
echo "---------------------------------------------------"
echo "IMPORTANT: Make sure you Enabled HEC in Splunk Native!"
echo "Global Settings -> Enable SSL (Unchecked) -> HTTP Port 8088"
echo "---------------------------------------------------"
