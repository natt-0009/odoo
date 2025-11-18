# ⚡ Quick Start Guide

## 🚀 For Linux Server (Recommended)

### 1. SSH to Server

```bash
ssh adasoft@172.16.100.30
```

### 2. Navigate to Project

```bash
cd /home/adasoft/odoo
```

### 3. Start Odoo

```bash
# Give execute permission
chmod +x start.sh

# Start everything
./start.sh
```

**Wait:** 5-10 minutes for first run (building images)

### 4. Access Odoo

```
http://172.16.100.30:8089
```

### 5. Create Database

- Master Password: `Adasoft@2025`
- Database Name: `adasoft`
- Email: `admin`
- Password: `admin`

---

## 💻 For Windows Development

### 1. Open PowerShell

```powershell
cd c:\Projects\odoo
```

### 2. Start Services

```powershell
docker-compose build
docker-compose up -d
```

### 3. Access Odoo

```
http://localhost:8089
```

---

## 🔄 Auto-Reload Testing

### Test That It Works:

**Terminal 1:**
```bash
docker-compose logs -f web
```

**Terminal 2:**
```bash
# Edit any Python file
echo "# test" >> addons/helpdesk/helpdesk_mgmt/models/helpdesk_ticket.py
```

**Terminal 1:** You should see "Reloading..."

✅ **Auto-reload is working!**

---

## 📦 Install Modules

### Method 1: Via UI

1. Go to **Apps**
2. Click **⋮ → Update Apps List**
3. Search "helpdesk"
4. Click **Install** on `helpdesk_mgmt`

### Method 2: Via Command

```bash
make install DB=adasoft MODULE=helpdesk_mgmt
```

### Method 3: Via Docker Exec

```bash
docker-compose exec web odoo-bin \
  --config=/etc/odoo/odoo.conf \
  -d adasoft \
  -i helpdesk_mgmt \
  --stop-after-init

docker-compose restart web
```

---

## 🛠️ Common Commands

```bash
# View logs
docker-compose logs -f web

# Restart
docker-compose restart

# Stop
docker-compose down

# Shell access
docker-compose exec web bash

# Database shell
docker-compose exec db psql -U odoo

# Module management
make install DB=adasoft MODULE=helpdesk_mgmt
make update DB=adasoft MODULE=helpdesk_mgmt
```

---

## 🐛 Quick Fixes

### Service won't start?

```bash
docker-compose down
docker-compose up -d
docker-compose logs web
```

### Port conflict?

Edit `.env`:
```bash
HOST_PORT=8090
```

### Auto-reload not working?

```bash
docker-compose exec web pip list | grep watchdog
```

Should show `watchdog`. If not:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Can't see modules?

1. **Update Apps List** in Odoo UI
2. Check path: `docker-compose logs web | grep addons`

---

## 📋 Full Documentation

See `README.md` for complete documentation.

---

**That's it! Start developing! 🎉**
