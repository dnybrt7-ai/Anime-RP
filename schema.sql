-- اسکیمای دیتابیس بازی رول انیمه‌ای

CREATE TABLE IF NOT EXISTS games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chat_id INTEGER NOT NULL,
  creator_id INTEGER NOT NULL,
  creator_name TEXT NOT NULL,
  status TEXT NOT NULL, -- waiting | collecting | judging | finished | cancelled | expired
  message_id INTEGER,
  character TEXT,
  situation TEXT,
  created_at INTEGER NOT NULL,
  started_at INTEGER,
  deadline_at INTEGER
);

CREATE INDEX IF NOT EXISTS idx_games_chat_status ON games(chat_id, status);

CREATE TABLE IF NOT EXISTS game_players (
  game_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  joined_at INTEGER NOT NULL,
  click_count INTEGER NOT NULL DEFAULT 1,
  eliminated INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (game_id, user_id)
);

CREATE TABLE IF NOT EXISTS answers (
  game_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  raw_text TEXT NOT NULL,
  submitted_at INTEGER NOT NULL,
  PRIMARY KEY (game_id, user_id)
);

CREATE TABLE IF NOT EXISTS scores (
  chat_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  total_score INTEGER NOT NULL DEFAULT 0,
  games_played INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (chat_id, user_id)
);

CREATE TABLE IF NOT EXISTS cooldowns (
  chat_id INTEGER PRIMARY KEY,
  next_available_at INTEGER NOT NULL
);
