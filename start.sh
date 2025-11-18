#!/bin/bash
# Odoo Development Environment - Start Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Detect docker-compose
if command -v docker-compose &> /dev/null; then
    DC="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DC="docker compose"
else
    echo -e "${RED}Error: docker-compose not found${NC}"
    exit 1
fi

echo "=========================================="
echo "Odoo Development Environment"
echo "=========================================="
echo ""

# Check if first run
if [ ! -f ".initialized" ]; then
    echo -e "${CYAN}First run detected - Building images...${NC}"
    echo "This will take 5-10 minutes..."
    echo ""
    
    $DC build
    
    if [ $? -eq 0 ]; then
        touch .initialized
        echo -e "${GREEN}✓ Build complete${NC}"
    else
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi
    echo ""
fi

# Start services
echo -e "${CYAN}Starting services...${NC}"
$DC up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to start services${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Services started${NC}"
echo ""

# Wait for services
echo -e "${CYAN}Waiting for services to be ready...${NC}"
sleep 5

# Check if services are running
if ! $DC ps | grep -q "odoo_web.*Up"; then
    echo -e "${RED}✗ Odoo container failed to start${NC}"
    echo "Check logs: docker-compose logs web"
    exit 1
fi

echo -e "${GREEN}✓ All services are running${NC}"
echo ""

# Get server info
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="localhost"
fi

# Use actual server IP if we detect it's not localhost
if [ "$SERVER_IP" != "localhost" ] && [ ! -z "$SERVER_IP" ]; then
    ODOO_URL="http://${SERVER_IP}:${HOST_PORT}"
    PGADMIN_URL="http://${SERVER_IP}:5050"
else
    ODOO_URL="http://localhost:${HOST_PORT}"
    PGADMIN_URL="http://localhost:5050"
fi

# Display info
echo "=========================================="
echo -e "${GREEN}✓✓✓ Odoo is Ready! ✓✓✓${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo -e "  Odoo:    ${CYAN}${ODOO_URL}${NC}"
echo -e "  pgAdmin: ${CYAN}${PGADMIN_URL}${NC}"
echo ""
echo -e "${BLUE}Default Credentials:${NC}"
echo "  Master Password: ${ADMIN_PASSWORD}"
echo "  pgAdmin Email:   admin@admin.com"
echo "  pgAdmin Pass:    ${ADMIN_PASSWORD}"
echo ""
echo "  After creating database:"
echo "  Database: ${POSTGRES_DB}"
echo "  Email:    admin"
echo "  Password: admin"
echo ""
echo "=========================================="
echo -e "${BLUE}Features Enabled:${NC}"
echo "=========================================="
echo ""
echo "  ✓ Auto-reload (watchdog)"
echo "  ✓ Dev mode enabled"
echo "  ✓ QWeb debugging"
echo "  ✓ Assets debugging"
echo ""
echo -e "${YELLOW}Edit files in addons/ → Save → Auto reload!${NC}"
echo ""
echo "=========================================="
echo -e "${BLUE}Useful Commands:${NC}"
echo "=========================================="
echo ""
echo "  View logs:        docker-compose logs -f web"
echo "  Restart:          docker-compose restart"
echo "  Stop:             docker-compose down"
echo "  Shell:            docker-compose exec web bash"
echo "  Database shell:   docker-compose exec db psql -U odoo"
echo ""
echo "  Install module:   docker-compose exec web odoo-bin -d ${POSTGRES_DB} -i MODULE_NAME --config=/etc/odoo/odoo.conf --stop-after-init"
echo "  Update module:    docker-compose exec web odoo-bin -d ${POSTGRES_DB} -u MODULE_NAME --config=/etc/odoo/odoo.conf --stop-after-init"
echo ""
echo "=========================================="
echo -e "${BLUE}Next Steps:${NC}"
echo "=========================================="
echo ""
echo "1. Open Odoo: ${ODOO_URL}"
echo "2. Create your first database"
echo "3. Start developing!"
echo ""
echo "=========================================="
