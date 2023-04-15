#!/bin/bash
set -x
# Retrieve IP address for RL
IP=$(minikube ip)

# Trust the self-signed certificate of Keycloak
export KC_OPTS="-Djavax.net.ssl.trustStore=keycloak/config/cert/tls.p12 -Djavax.net.ssl.trustStorePassword=changeit"

# Login to the admin REST interface
keycloak-cli/keycloak/bin/kcadm.sh config credentials --server https://keycloak.${IP}.nip.io/ --realm master --user admin --password admin

# Update the admin user so it has an email address as required by the Grafana OIDC configuration
ID=$(keycloak-cli/keycloak/bin/kcadm.sh get users -q username=admin | jq '.[].id' -r)
keycloak-cli/keycloak/bin/kcadm.sh update users/$ID -s email=admin@example.com

# Replace grafana client
ID=$(keycloak-cli/keycloak/bin/kcadm.sh get clients -q clientId=grafana | jq '.[].id' -r)
if [ "$ID" != "" ]; then
  keycloak-cli/keycloak/bin/kcadm.sh delete clients/${ID}
fi
keycloak-cli/keycloak/bin/kcadm.sh create clients -f keycloak-grafana-client.json -i

# Enable realm roles at user info endpoint
JSON=$(keycloak-cli/keycloak/bin/kcadm.sh get client-scopes | jq '.[] | select( .name == "roles" )')
ID=$(jq '.id' -r <<< "$JSON")
ID2=$(jq '.protocolMappers[] | select ( .name == "realm roles" ) | .id' -r <<< "$JSON")
keycloak-cli/keycloak/bin/kcadm.sh update client-scopes/$ID/protocol-mappers/models/$ID2 -s config.\"userinfo.token.claim\"=true
