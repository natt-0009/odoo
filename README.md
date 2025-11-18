# 🚀 Odoo Development Environment

Complete Docker-based Odoo 18.0 development environment with **auto-reload** functionality using Odoo Community Backports (OCB).

---

## ✨ Features

- ✅ **Odoo 18.0** (OCB - Odoo Community Backports)
- ✅ **Auto-reload** with watchdog (edit code → save → reload automatically!)
- ✅ **PostgreSQL 15** database
- ✅ **pgAdmin 4** for database management
- ✅ **Development mode** enabled (QWeb debugging, assets debugging)
- ✅ **Hot-reload** for Python, XML, JavaScript changes
- ✅ **Pre-configured** for OCA modules (Helpdesk, Timesheet, etc.)
- ✅ **Volume mounts** for easy development

---

## 📋 Prerequisites

- Docker & Docker Compose
- Git
- 8GB+ RAM recommended
- 20GB+ free disk space

---

## 🚀 Quick Start

### 1. Clone or Navigate to Project

```bash
cd /path/to/odoo
```

### 2. Start Odoo (First Time)

**On Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

**On Windows (PowerShell):**
```powershell
docker-compose build
docker-compose up -d
```

**Using Make:**
```bash
make start
```

First run will:
- Build Docker images (5-10 minutes)
- Install dependencies including **watchdog** for auto-reload
- Start all services
- Display access URLs

### 3. Access Odoo

```
Odoo:    http://localhost:8089
pgAdmin: http://localhost:5050
```

### 4. Create Database

1. Open Odoo URL
2. Fill in:
   - Master Password: `Adasoft@2025`
   - Database Name: `adasoft` (or your choice)
   - Email: `admin`
   - Password: `admin`
3. Click "Create database"

---

## 🔄 Auto-Reload Feature

### How It Works

The environment includes **watchdog** module for automatic code reloading:

```
Edit file → Save → Odoo reloads automatically! 🎉
```

### What Auto-Reloads

✅ **Python files** (.py)
✅ **XML files** (views, data)
✅ **JavaScript files** (.js)
✅ **CSS files** (.css)
✅ **QWeb templates**

### What Requires Manual Restart

❌ `__manifest__.py` changes
❌ New dependencies
❌ `odoo.conf` changes
❌ Database schema changes (need module upgrade)

### Testing Auto-Reload

```bash
# Terminal 1: Watch logs
docker-compose logs -f web

# Terminal 2: Edit a file
nano addons/helpdesk/helpdesk_mgmt/models/helpdesk_ticket.py
# Make a change and save

# Terminal 1: You'll see "Reloading..."
```

---

## 📁 Project Structure

```
odoo/
├── addons/                    # Your custom modules
│   ├── helpdesk/             # OCA Helpdesk (22 modules)
│   └── timesheet/            # OCA Timesheet (22 modules)
├── config/
│   └── odoo.conf             # Odoo configuration
├── logs/                      # Odoo logs
├── docker-compose.yml         # Docker services
├── Dockerfile                 # Odoo image (with watchdog)
├── .env                       # Environment variables
├── start.sh                   # Start script
├── Makefile                   # Convenience commands
└── README.md                  # This file
```

---

## 🛠️ Common Commands

### Using Start Script

```bash
./start.sh              # Start everything
```

### Using Docker Compose

```bash
docker-compose up -d      # Start services
docker-compose down       # Stop services
docker-compose restart    # Restart services
docker-compose logs -f    # View logs
docker-compose ps         # Show status
```

### Using Makefile

```bash
make help                 # Show all commands
make start                # Start Odoo
make logs                 # View logs
make logs-web            # View Odoo logs only
make shell                # Access Odoo shell
make db-shell            # Access PostgreSQL shell
make restart              # Restart services
make clean                # Clean everything (deletes data!)
make rebuild              # Rebuild from scratch
```

### Module Management

```bash
# Install module
make install DB=adasoft MODULE=helpdesk_mgmt

# Update module
make update DB=adasoft MODULE=helpdesk_mgmt

# Initialize new database
make init-db DB=newdb

# Manual install
docker-compose exec web odoo-bin \
  --config=/etc/odoo/odoo.conf \
  -d adasoft \
  -i helpdesk_mgmt \
  --stop-after-init
docker-compose restart web
```

---

## 📦 Available Modules

### OCA Helpdesk (22 modules)

Located in `addons/helpdesk/`:

- `helpdesk_mgmt` - Base helpdesk
- `helpdesk_mgmt_project` - Project integration
- `helpdesk_mgmt_timesheet` - Timesheet integration
- `helpdesk_mgmt_sla` - SLA management
- `helpdesk_mgmt_rating` - Customer ratings
- `helpdesk_type` - Ticket types
- `helpdesk_motive` - Ticket motives
- ...and 15 more!

### OCA Timesheet (22 modules)

Located in `addons/timesheet/`:

- `hr_timesheet_sheet` - Timesheet sheets
- `hr_timesheet_task_required` - Require task
- `crm_timesheet` - CRM integration
- `sale_timesheet_budget` - Budget tracking
- ...and 18 more!

### Install via UI

1. Go to **Apps**
2. Click **⋮ → Update Apps List**
3. Search for module
4. Click **Install**

---

## 🔧 Configuration

### Environment Variables (.env)

```bash
ODOO_VERSION=18.0
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
POSTGRES_DB=adasoft
HOST_PORT=8089
ADMIN_PASSWORD=Adasoft@2025
```

### Odoo Configuration (config/odoo.conf)

```ini
# Auto-reload is enabled
dev_mode = all

# Addons paths include subdirectories
addons_path = /opt/odoo/addons,/mnt/extra-addons,/mnt/extra-addons/helpdesk,/mnt/extra-addons/timesheet

# Development settings
workers = 0
log_level = info
```

### Ports

- `8089` - Odoo web interface
- `8072` - Longpolling (internal)
- `5050` - pgAdmin
- `5432` - PostgreSQL (internal only)

---

## 🧪 Development Workflow

### 1. Edit Code

```bash
# Edit any Python file
nano addons/helpdesk/helpdesk_mgmt/models/helpdesk_ticket.py

# Add new method
def my_method(self):
    return "Hello!"

# Save → Auto-reload! No restart needed!
```

### 2. Edit Views

```bash
# Edit XML view
nano addons/helpdesk/helpdesk_mgmt/views/helpdesk_ticket_views.xml

# Add field
<field name="my_field"/>

# Save → Auto-reload → Refresh browser
```

### 3. Watch Logs

```bash
# Always keep logs open while developing
docker-compose logs -f web

# You'll see:
# "Reloading registry because files have changed"
```

### 4. When to Restart

```bash
# After changing __manifest__.py
docker-compose restart web

# After database structure changes
docker-compose exec web odoo-bin -u module_name -d adasoft --config=/etc/odoo/odoo.conf --stop-after-init
docker-compose restart web
```

---

## 🐛 Troubleshooting

### Auto-reload not working?

```bash
# Check if watchdog is installed
docker-compose exec web pip list | grep watchdog

# Should see: watchdog x.x.x

# If not installed, rebuild:
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Can't see modules?

```bash
# 1. Check addons path
docker-compose exec web cat /etc/odoo/odoo.conf | grep addons_path

# 2. Check if modules exist
docker-compose exec web ls /mnt/extra-addons/helpdesk/

# 3. Update Apps List in Odoo UI
# Apps → ⋮ → Update Apps List
```

### Permission errors?

```bash
# Fix permissions (Linux)
sudo chown -R $USER:$USER addons/
chmod -R 755 addons/

# Restart
docker-compose restart web
```

### Port already in use?

```bash
# Check what's using port 8089
lsof -i :8089
# or
netstat -ano | findstr :8089

# Kill the process or change port in .env
HOST_PORT=8090
```

### Database connection error?

```bash
# Check if database is running
docker-compose ps db

# Check logs
docker-compose logs db

# Restart database
docker-compose restart db
```

---

## 📚 Resources

- **Odoo Documentation:** https://www.odoo.com/documentation/18.0/
- **OCB Repository:** https://github.com/OCA/OCB
- **OCA Helpdesk:** https://github.com/OCA/helpdesk
- **OCA Timesheet:** https://github.com/OCA/timesheet
- **Odoo Development:** https://www.odoo.com/documentation/18.0/developer.html

---

## 🔐 Default Credentials

### Master Password
```
Password: Adasoft@2025
```

### pgAdmin
```
Email:    admin@admin.com
Password: Adasoft@2025
```

### Odoo (after database creation)
```
Database: adasoft
Email:    admin
Password: admin
```

⚠️ **Change these in production!**

---

## 💡 Tips

- ✅ Keep `docker-compose logs -f web` running while developing
- ✅ Use auto-reload for Python/XML changes
- ✅ Restart after `__manifest__.py` changes
- ✅ Upgrade modules after database schema changes
- ✅ Use pgAdmin for database inspection
- ✅ Check logs when things go wrong

---

## 🚫 What NOT to Do

- ❌ Don't use `--dev=all` in production
- ❌ Don't forget to upgrade after schema changes
- ❌ Don't edit core Odoo files
- ❌ Don't commit sensitive data to Git
- ❌ Don't ignore error messages in logs

---

## 📞 Support

Create an issue or check the logs:

```bash
docker-compose logs --tail=100 web
```

---

**Happy Coding! 🚀**

Made with ❤️ for Odoo Developers
