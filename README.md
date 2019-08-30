# olympic_games

DataBase Import:
    ruby import.rb

Request Examples:
    ruby app.rb medals summer ukr 
    ruby app.rb medals silver UKR summer

    ruby app.rb top-teams summer 2004 silver
    ruby app.rb top-teams silver winter
    ruby app.rb top-teams winter

If use PostgreSQL:
    createdb olympic_history.db

    psql olympic_history.db

        CREATE TABLE IF NOT EXISTS "games" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          year  INTEGER NOT NULL,
          season  INTEGER NOT NULL,
          city  TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS "teams" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          name  TEXT NOT NULL,
          noc_name  TEXT NOT NULL UNIQUE
        );
        CREATE TABLE IF NOT EXISTS "sports" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          name  TEXT NOT NULL UNIQUE
        );
        CREATE TABLE IF NOT EXISTS "events" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          name  TEXT NOT NULL UNIQUE
        );
        CREATE TABLE IF NOT EXISTS "athletes" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          full_name TEXT NOT NULL,
          year_of_birth INTEGER,
          sex INTEGER,
          params  TEXT NOT NULL,
          team_id INTEGER NOT NULL REFERENCES teams (id)
        );
        CREATE TABLE IF NOT EXISTS "results" (
          id  SERIAL NOT NULL PRIMARY KEY UNIQUE,
          athlete_id  INTEGER NOT NULL REFERENCES athletes (id),
          game_id INTEGER NOT NULL REFERENCES games (id),
          sport_id  INTEGER NOT NULL REFERENCES sports (id),
          event_id  INTEGER NOT NULL REFERENCES events (id),
          medal INTEGER NOT NULL
        );
