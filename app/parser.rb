require 'csv'

class Parser
  attr_reader :csv_path,
              :game_hash,
              :team_hash,
              :athlete_hash,
              :sport_hash,
              :event_hash,
              :result_hash_arr

  def initialize(csv_path)
    @csv_path = csv_path
    @game_hash = {}
    @team_hash = {}
    @athlete_hash = {}
    @sport_hash = {}
    @event_hash = {}
    @result_hash_arr = []
  end

  def parse_data
    CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
      game_year = row[:year].to_i

      game_season = row[:season].downcase == "summer" ? 0 : 1

      unless game_year == 1906 && game_season == 0
        team_parse(row)
        athlete_parse(row)
        sport_parse(row)
        event_parse(row)
        game_parse(row, game_year, game_season)
        result_parse(row, game_year, game_season)
      end
    end

    {
      game_hash: game_hash,
      team_hash: team_hash,
      result_hash_arr: result_hash_arr,
      athlete_hash: athlete_hash, 
      sport_hash: sport_hash, 
      event_hash: event_hash
    }
  end

  private
    def team_parse(data)
        team_noc = data[:noc]
        team_name = data[:team].split('-').first

        team_hash[team_noc] = { name: team_name, id: team_hash.size + 1 } if team_hash[team_noc].nil?
    end

    def athlete_parse(data)
      athlete_name = data[:name].gsub(/\(.+\)|".+"/, '')

      athlete_birth = data[:age] == "NA" ? "null" : Time.now.utc.year - data[:age].to_i

      if data[:sex] == "NA"
        athlete_sex = "null"
      else
        data[:sex] == "F" ? athlete_sex = 0 : athlete_sex = 1
      end

      athlete_params = []
      %i[weight height].each do |p|
        athlete_params << " #{p.to_s}: #{data[p]}" unless data[p] == "NA"
      end
      athlete_params = "{" + athlete_params.join(',') + " }"

      athlete_hash[data[:id]] = { 
                                  name: athlete_name,
                                  birth: athlete_birth,
                                  sex: athlete_sex,
                                  params: athlete_params,
                                  t_id: team_hash[data[:noc]][:id]
                                }
    end

    def sport_parse(data)
      sport_hash[data[:sport]] = { id: sport_hash.size + 1 } if sport_hash[data[:sport]].nil?
    end

    def event_parse(data)
      event_hash[data[:event]] = { id: event_hash.size + 1 } if event_hash[data[:event]].nil?
    end

    def game_parse(data, game_year, game_season)
      game_city = data[:city]

      if game_hash[[game_year, game_season]].nil?
        game_hash[[game_year, game_season]] = { city: [game_city], id: game_hash.size + 1 }
      else
        unless game_hash[[game_year, game_season]][:city].include? game_city
          game_hash[[game_year, game_season]][:city] << game_city
        end
      end
    end

    def result_parse(data, game_year, game_season)
      case data[:medal].downcase
        when "bronze"
          medal = 3
        when "silver"
          medal = 2
        when "gold"
          medal = 1
        else
          medal = 0
        end

        result_hash_arr << { 
                              a_id: data[:id],
                              g_id: game_hash[[game_year,game_season]][:id],
                              s_id: sport_hash[data[:sport]][:id], medal: medal,
                              e_id: event_hash[data[:event]][:id]
                            }
    end
end
