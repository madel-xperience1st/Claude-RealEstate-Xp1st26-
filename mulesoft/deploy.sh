#!/bin/bash
# ============================================
# PropHub MuleSoft API - Quick Deploy Script
# ============================================
# USE THIS when GitHub Actions isn't set up yet
# or for quick local deployments.
#
# PREREQUISITES:
#   - Java 17 recommended (JDK 21 works with --add-opens flags)
#   - Maven 3.8+ installed
#   - MuleSoft Enterprise credentials in ~/.m2/settings.xml
#
# USAGE:
#   ./deploy.sh                    # Deploy with prompts
#   ./deploy.sh --env dev          # Deploy to dev
#   ./deploy.sh --local            # Run locally only
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/prophub-api"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  PropHub MuleSoft API Deployment${NC}"
echo -e "${BLUE}============================================${NC}"

# Parse arguments
ENV="dev"
LOCAL_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"
            shift 2
            ;;
        --local)
            LOCAL_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v java &> /dev/null; then
    echo -e "${RED}Java not found. Install JDK 17+${NC}"
    exit 1
fi

if ! command -v mvn &> /dev/null; then
    echo -e "${RED}Maven not found. Install Maven 3.8+${NC}"
    exit 1
fi

JAVA_VER=$(java -version 2>&1 | head -1)
echo -e "${GREEN}Java: $JAVA_VER${NC}"
echo -e "${GREEN}Maven: $(mvn -version 2>&1 | head -1)${NC}"

# Mule 4 requires JDK 8, 11, or 17. Add --add-opens flags for JDK 17+
JAVA_MAJOR=$(java -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/')
if [ "$JAVA_MAJOR" -ge 17 ] 2>/dev/null; then
    echo -e "${YELLOW}JDK $JAVA_MAJOR detected — adding module access flags for Mule compatibility${NC}"
    export MAVEN_OPTS="$MAVEN_OPTS \
        --add-opens java.base/java.lang=ALL-UNNAMED \
        --add-opens java.base/java.lang.invoke=ALL-UNNAMED \
        --add-opens java.base/java.lang.reflect=ALL-UNNAMED \
        --add-opens java.base/java.io=ALL-UNNAMED \
        --add-opens java.base/java.net=ALL-UNNAMED \
        --add-opens java.base/java.nio=ALL-UNNAMED \
        --add-opens java.base/java.util=ALL-UNNAMED \
        --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
        --add-opens java.base/sun.nio.ch=ALL-UNNAMED \
        --add-opens java.base/sun.nio.cs=ALL-UNNAMED \
        --add-opens java.base/sun.security.ssl=ALL-UNNAMED \
        --add-opens java.base/sun.security.util=ALL-UNNAMED \
        --add-opens java.base/sun.security.x509=ALL-UNNAMED \
        --add-opens java.management/javax.management=ALL-UNNAMED \
        --add-opens java.base/java.math=ALL-UNNAMED"
fi

# Check MuleSoft Enterprise credentials (required for Salesforce connector)
if [ -z "$ANYPOINT_USERNAME" ] || [ -z "$ANYPOINT_PASSWORD" ]; then
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}  MuleSoft Enterprise credentials required!${NC}"
    echo -e "${RED}============================================${NC}"
    echo -e "${YELLOW}The Salesforce connector and other enterprise${NC}"
    echo -e "${YELLOW}modules require Anypoint Platform credentials.${NC}"
    echo -e ""
    echo -e "${BLUE}Set these environment variables:${NC}"
    echo -e "  export ANYPOINT_USERNAME=your-anypoint-email"
    echo -e "  export ANYPOINT_PASSWORD=your-anypoint-password"
    echo -e ""
    echo -e "${BLUE}Or add them to mulesoft/.env:${NC}"
    echo -e "  ANYPOINT_USERNAME=your-anypoint-email"
    echo -e "  ANYPOINT_PASSWORD=your-anypoint-password"
    echo -e ""
    echo -e "${YELLOW}Sign up at: https://anypoint.mulesoft.com${NC}"
    exit 1
fi
echo -e "${GREEN}Anypoint credentials: configured${NC}"

# Load environment variables
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}Loading .env file...${NC}"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo -e "${YELLOW}No .env file found.${NC}"
    echo -e "${YELLOW}Create one from .env.template for credentials.${NC}"

    # Prompt for required values if not set
    if [ -z "$SF_CONSUMER_KEY" ]; then
        echo -e "\n${BLUE}Enter your Salesforce Connected App credentials:${NC}"
        read -p "SF Consumer Key: " SF_CONSUMER_KEY
        read -p "SF Username (integration user): " SF_USERNAME
        read -p "SF Keystore Path [keystore/salesforce-keystore.jks]: " SF_KEYSTORE_PATH
        SF_KEYSTORE_PATH="${SF_KEYSTORE_PATH:-keystore/salesforce-keystore.jks}"
        read -sp "SF Keystore Password: " SF_KEYSTORE_PASSWORD
        echo
        read -p "SF Demo User Email: " SF_DEMO_USER_EMAIL
        export SF_CONSUMER_KEY SF_USERNAME SF_KEYSTORE_PATH SF_KEYSTORE_PASSWORD SF_DEMO_USER_EMAIL
    fi
fi

cd "$PROJECT_DIR"

# Build
echo -e "\n${YELLOW}Building project...${NC}"
mvn clean package -DskipTests \
    -Dmule.env="$ENV"

echo -e "${GREEN}Build successful!${NC}"

if [ "$LOCAL_ONLY" = true ]; then
    # Run locally
    echo -e "\n${YELLOW}Starting local Mule runtime...${NC}"
    echo -e "${BLUE}API will be available at: http://localhost:8081/api/v1${NC}"
    echo -e "${BLUE}Health check: http://localhost:8081/health${NC}"
    echo -e "${BLUE}API Console: http://localhost:8081/console${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

    mvn mule:run \
        -Dmule.env="$ENV" \
        -DSF_CONSUMER_KEY="$SF_CONSUMER_KEY" \
        -DSF_USERNAME="$SF_USERNAME" \
        -DSF_KEYSTORE_PATH="$SF_KEYSTORE_PATH" \
        -DSF_KEYSTORE_PASSWORD="$SF_KEYSTORE_PASSWORD" \
        -DSF_DEMO_USER_EMAIL="$SF_DEMO_USER_EMAIL" \
        -DJWT_SECRET="${JWT_SECRET:-prophub-dev-secret-change-me}"
else
    # Deploy to CloudHub
    echo -e "\n${YELLOW}Deploying to CloudHub...${NC}"

    if [ -z "$ANYPOINT_USERNAME" ]; then
        read -p "Anypoint Username: " ANYPOINT_USERNAME
        read -sp "Anypoint Password: " ANYPOINT_PASSWORD
        echo
        export ANYPOINT_USERNAME ANYPOINT_PASSWORD
    fi

    APP_NAME="${CLOUDHUB_APP_NAME:-prophub-api}"
    CLOUDHUB_ENV="${CLOUDHUB_ENVIRONMENT:-Sandbox}"
    CLOUDHUB_REGION="${CLOUDHUB_REGION:-us-east-2}"

    mvn clean deploy -DmuleDeploy \
        -Danypoint.username="$ANYPOINT_USERNAME" \
        -Danypoint.password="$ANYPOINT_PASSWORD" \
        -Dcloudhub.app.name="$APP_NAME" \
        -Dcloudhub.environment="$CLOUDHUB_ENV" \
        -Dcloudhub.region="$CLOUDHUB_REGION" \
        -Dmule.env="$ENV" \
        -DSF_CONSUMER_KEY="$SF_CONSUMER_KEY" \
        -DSF_USERNAME="$SF_USERNAME" \
        -DSF_KEYSTORE_PATH="$SF_KEYSTORE_PATH" \
        -DSF_KEYSTORE_PASSWORD="$SF_KEYSTORE_PASSWORD" \
        -DSF_DEMO_USER_EMAIL="$SF_DEMO_USER_EMAIL" \
        -DJWT_SECRET="${JWT_SECRET:-prophub-dev-secret-change-me}" \
        -DskipTests

    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}  Deployment successful!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo -e "${BLUE}App URL: https://${APP_NAME}.${CLOUDHUB_REGION}.cloudhub.io/api/v1${NC}"
    echo -e "${BLUE}Health:  https://${APP_NAME}.${CLOUDHUB_REGION}.cloudhub.io/health${NC}"
    echo -e "${BLUE}Console: https://${APP_NAME}.${CLOUDHUB_REGION}.cloudhub.io/console${NC}"
fi
