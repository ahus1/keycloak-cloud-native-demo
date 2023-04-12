IP=$(minikube ip)
export KC_OPTS="-Djavax.net.ssl.trustStore=keycloak/config/cert/tls.p12 -Djavax.net.ssl.trustStorePassword=changeit"
keycloak-cli/keycloak/bin/kcadm.sh config credentials --server https://keycloak.${IP}.nip.io/ --realm master --user admin --password admin