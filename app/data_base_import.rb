class DataBaseImport

  def initialize
    @game_arr = []
    @team_arr = []
    @athlete_arr = []
    @sport_arr = []
    @event_arr = []
    @results_arr = []
  end

  def import(results, db)
    serialized_data(results)
    clear_db(db)
    insert_data(db)
  end

  private
    def clear_db(db)
      db.execute "DELETE FROM results;"
      db.execute "DELETE FROM athletes;"
      db.execute "DELETE FROM games;"
      db.execute "DELETE FROM teams;"
      db.execute "DELETE FROM sports;"
      db.execute "DELETE FROM events;"
    end

    def serialized_data(results)
      prepare_games(results[:game_hash])
      prepare_teams(results[:team_hash])
      prepare_athletes(results[:athlete_hash])
      prepare_sport(results[:sport_hash])
      prepare_event(results[:event_hash])
      prepare_result(results[:result_hash_arr])
    end

    def insert_data(db)
      insert_games(db)
      insert_teams(db)
      insert_athletes(db)
      insert_sports(db)
      insert_events(db)
      insert_results(db)
    end

    def insert_games(db)
      @game_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO games(id, year, season, city) VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def insert_teams(db)
      @team_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO teams(id, name, noc_name) VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def insert_athletes(db)
      @athlete_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO athletes(id, full_name, year_of_birth, sex, params, team_id) 
                    VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def insert_sports(db)
      @sport_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO sports(id, name) VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def insert_events(db)
      @event_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO events(id, name) VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def insert_results(db)
      @results_arr.each_slice(10000) do |elem|
        values = db.values(elem.size, elem.first.size)
        db.execute "INSERT INTO results(athlete_id, game_id, sport_id, event_id, medal) 
                    VALUES #{values}", db.prepare_elements(elem)
      end
    end

    def prepare_games(game_hash)
      game_hash.each do |key, value| 
        @game_arr.push [value[:id], key[0], key[1], value[:city].join(',')]
      end
    end

    def prepare_teams(team_hash)
      team_hash.each do |key, value| 
        @team_arr.push [value[:id], value[:name], key]
      end
    end

    def prepare_athletes(athlete_hash)
      athlete_hash.each do |key, value| 
        @athlete_arr.push [key, value[:name], value[:birth], value[:sex], value[:params], value[:t_id]]
      end
    end

    def prepare_sport(sport_hash)
      sport_hash.each do |key, value| 
        @sport_arr.push [value[:id], key]
      end
    end

    def prepare_event(event_hash)
      event_hash.each do |key, value| 
        @event_arr.push [value[:id], key]
      end
    end

    def prepare_result(result_hash_arr)
      result_hash_arr.each do |hash_v| 
        @results_arr.push [hash_v[:a_id], hash_v[:g_id], hash_v[:s_id], hash_v[:e_id], hash_v[:medal]] 
      end
    end
end
