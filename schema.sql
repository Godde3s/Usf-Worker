-- Yousef Proxy Engine - D1 SQLite Schema
-- Comprehensive database structure for users, clean IPs, and system settings

-- Users table: Stores proxy user profiles and bandwidth tracking
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  uuid TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  profile_name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  expiry_at INTEGER NOT NULL,
  used_bytes INTEGER DEFAULT 0,
  allowed_bytes INTEGER NOT NULL,
  status TEXT DEFAULT 'active' CHECK(status IN ('active', 'suspended', 'expired')),
  country TEXT DEFAULT 'US',
  protocol TEXT DEFAULT 'vless' CHECK(protocol IN ('vless', 'trojan')),
  custom_sni TEXT,
  notes TEXT
);

-- Clean IPs table: Stores proxy endpoints and CDN domains
CREATE TABLE IF NOT EXISTS clean_ips (
  id TEXT PRIMARY KEY,
  ip_domain TEXT UNIQUE NOT NULL,
  source TEXT DEFAULT 'manual' CHECK(source IN ('manual', 'auto_scraped', 'nova')),
  country TEXT,
  status TEXT DEFAULT 'active' CHECK(status IN ('active', 'inactive', 'testing')),
  last_checked_at INTEGER,
  health_score REAL DEFAULT 100.0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- System settings table: Configuration and admin credentials
CREATE TABLE IF NOT EXISTS system_settings (
  id TEXT PRIMARY KEY,
  setting_key TEXT UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  data_type TEXT DEFAULT 'string' CHECK(data_type IN ('string', 'integer', 'boolean', 'json')),
  updated_at INTEGER NOT NULL
);

-- Connection logs table: Audit trail for connections
CREATE TABLE IF NOT EXISTS connection_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  connected_at INTEGER NOT NULL,
  disconnected_at INTEGER,
  bytes_transferred INTEGER DEFAULT 0,
  endpoint_used TEXT,
  status TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_uuid ON users(uuid);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_expiry ON users(expiry_at);
CREATE INDEX IF NOT EXISTS idx_clean_ips_domain ON clean_ips(ip_domain);
CREATE INDEX IF NOT EXISTS idx_clean_ips_status ON clean_ips(status);
CREATE INDEX IF NOT EXISTS idx_connection_logs_user_id ON connection_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_connection_logs_connected_at ON connection_logs(connected_at);

-- Initialize default system settings
INSERT OR IGNORE INTO system_settings (id, setting_key, setting_value, data_type, updated_at)
VALUES 
  ('set_admin_pass', 'admin_password', 'yousef_default_admin_2024', 'string', 0),
  ('set_language', 'default_language', 'en', 'string', 0),
  ('set_api_path', 'api_base_path', '/api', 'string', 0),
  ('set_max_users', 'max_concurrent_users', '1000', 'integer', 0),
  ('set_auto_scrape', 'enable_auto_scraper', 'true', 'boolean', 0),
  ('set_scrape_interval', 'scraper_interval_hours', '6', 'integer', 0);
