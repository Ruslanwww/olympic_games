require 'csv'
require 'sqlite3'

s_time = Time.now

db_path = "olympic_history.db"
csv_path = "athlete_events.csv"

game_hash = {}
team_hash = {}
athlete_hash = {}
sport_hash = {}
event_hash = {}
result_hash_arr = []

CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|

  #TEAM PARSE
  team_noc = row[:noc]
  team_name = row[:team].split('-').first

  team_hash[team_noc] = { name: team_name, id: team_hash.size + 1 } if team_hash[team_noc].nil?

  #ATHLETE PARSE
  athlete_name = row[:name].gsub(/\(.+\)|".+"/, '')
  row[:age] == "NA" ? athlete_birth = "null" : athlete_birth = Time.now.utc.year - row[:age].to_i
  if row[:sex] == "NA"
    athlete_sex = "null"
  else
    row[:sex] == "F" ? athlete_sex = 0 : athlete_sex = 1
  end

  if row[:weight] == "NA" && row[:height] == "NA"
    athlete_params = "{}"
  elsif row[:weight] == "NA"
    athlete_params = "{ height: #{row[:height]} }"
  elsif row[:height] == "NA"
    athlete_params = "{ weight: #{row[:weight]} }"
  else
    athlete_params = "{ height: #{row[:height]} weight: #{row[:weight]} }"
  end

  athlete_hash[row[:id]] = { name: athlete_name, 
                             birth: athlete_birth,
                             sex: athlete_sex,
                             params: athlete_params, 
                             t_id: team_hash[team_noc][:id] }
  #SPORT PARSE
  sport_hash[row[:sport]] = { id: sport_hash.size + 1 } if sport_hash[row[:sport]].nil?

  #EVENT PARSE
  event_hash[row[:event]] = { id: event_hash.size + 1 } if event_hash[row[:event]].nil?

  #GAME PARSE
  game_year = row[:year].to_i
  game_season = row[:season].downcase == "summer" ? 0 : 1

  unless game_year == 1906 && game_season == 0
    game_city = row[:city]

    if game_hash[[game_year, game_season]].nil?
      game_hash[[game_year, game_season]] = { city: [game_city], id: game_hash.size + 1 }
    else
      game_hash[[game_year, game_season]][:city] << game_city unless game_hash[[game_year, game_season]][:city].include? game_city
    end

    #RESULT PARSE
    case row[:medal].downcase
    when "bronze"
      medal = 3
    when "silver"
      medal = 2
    when "gold"
      medal = 1
    else
      medal = 0
    end

    result_hash_arr << { a_id: row[:id], 
                         g_id: game_hash[[game_year, game_season]][:id],
                         s_id: sport_hash[row[:sport]][:id],
                         e_id: event_hash[row[:event]][:id], 
                         medal: medal 
                       }
  end
end
game_arr = []
game_hash.each { |key, value| game_arr.push [value[:id], key[0], key[1], value[:city].join(',')] }

team_arr = []
team_hash.each { |key, value| team_arr.push [value[:id], value[:name], key] }

athlete_arr = []
athlete_hash.each { |key, value| athlete_arr.push [key, value[:name], value[:birth], value[:sex], 
                                                   value[:params], value[:t_id]] 
                  }

sport_arr = []
sport_hash.each { |key, value| sport_arr.push [value[:id], key] }

event_arr = []
event_hash.each { |key, value| event_arr.push [value[:id], key] }

results_arr = []
result_hash_arr.each { |hash_v| results_arr.push [hash_v[:a_id], hash_v[:g_id], hash_v[:s_id], 
                                                  hash_v[:e_id], hash_v[:medal]] 
                      }

begin
    db = SQLite3::Database.open "#{db_path}"

    db.execute "DELETE FROM games WHERE 1 = 1;"
    db.execute "DELETE FROM teams WHERE 1 = 1;"
    db.execute "DELETE FROM athletes WHERE 1 = 1;"
    db.execute "DELETE FROM sports WHERE 1 = 1;"
    db.execute "DELETE FROM events WHERE 1 = 1;"
    db.execute "DELETE FROM results WHERE 1 = 1;"

    game_arr.each_slice(10000) do |elem|
      db.execute "INSERT INTO games(id, year, season, city) VALUES #{(["(?,?,?,?)"] * elem.size).join(',')}", elem
    end

    team_arr.each_slice(10000) do |elem|
      db.execute "INSERT INTO teams(id, name, noc_name) VALUES #{(["(?,?,?)"] * elem.size).join(',')}", elem
    end

    athlete_arr.each_slice(10000) do |elem|
      db.execute "INSERT INTO athletes(id, full_name, year_of_birth, sex, params, team_id) 
                  VALUES #{(["(?,?,?,?,?,?)"] * elem.size).join(',')}", elem
    end

    sport_arr.each_slice(10000) do |elem|
      db.execute "INSERT INTO sports(id, name) VALUES #{(["(?,?)"] * elem.size).join(',')}", elem
    end

    event_arr.each_slice(10000) do |elem|
      db.execute "INSERT INTO events(id, name) VALUES #{(["(?,?)"] * elem.size).join(',')}", elem
    end

    results_arr.each_slice(10000) do |elem|
    db.execute "INSERT INTO results(athlete_id, game_id, sport_id, event_id, medal) 
                VALUES #{(["(?,?,?,?,?)"] * elem.size).join(',')}", elem
    end
    
rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e   
ensure
    db.close if db
end

p Time.now - s_time
