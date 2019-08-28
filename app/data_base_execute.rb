class DataBaseExecute
  SEASONS_LIST = { summer: 0, winter: 1 }.freeze
  MEDALS_LIST = { bronze: 1, silver: 2, gold: 3 }.freeze

  def initialize(chart_size)
    @chart_size = chart_size
  end
  
  def params_read(params)
    @medals = [1, 2, 3]
    params.each do |elem|
      if %w[summer winter].include? elem
        @season = SEASONS_LIST[elem.to_sym]
      elsif %w[bronze silver gold].include? elem
        @medals = [MEDALS_LIST[elem.to_sym]]
      else
        @noc_year = elem.upcase
      end
    end
  end

  def read_chart_name(chart_name, db)
    if chart_name == "medals"
      read_medals(db)
    elsif chart_name == "top-teams"
      read_teams(db)
    else
      puts "Please enter a valid request"
    end
  end

  private
    def read_medals(db)
      if @noc_year.nil?
        puts "Please, enter noc"
      elsif @season.nil?
        puts "Please, enter valid season"
      else
        query_params = db.prepare_elements([@medals, @season, @noc_year])
        data = db.execute "SELECT g.year, COUNT(r.id) FROM results r 
                      JOIN athletes a ON(r.athlete_id = a.id) 
                      JOIN teams t ON(a.team_id = t.id) 
                      JOIN games g ON(r.game_id = g.id) 
                    WHERE r.medal IN #{db.values(1, @medals.size)}
                      AND g.season = #{db.get_param(@medals.size + 1)} 
                      AND t.noc_name = #{db.get_param(@medals.size + 2)} 
                    GROUP BY g.year", query_params

        print_data(db.get_data(data))
      end
    end

    def read_teams(db)
      if @season.nil?
        puts "Please, enter valid season"
      else  
        params_arr = [@medals, @season]
        year = @noc_year.nil? ? "" : " AND year = #{db.get_param(@medals.size + 2)}"
        params_arr << @noc_year.to_i unless @noc_year.nil?

        query_params = db.prepare_elements(params_arr)

        data = db.execute "SELECT t.noc_name, COUNT(r.id) FROM results r 
                      JOIN athletes a ON(r.athlete_id = a.id) 
                      JOIN teams t ON(a.team_id = t.id) 
                      JOIN games g ON(r.game_id = g.id) 
                    WHERE r.medal IN #{db.values(1, @medals.size)}
                      AND g.season = #{db.get_param(@medals.size + 1)}
                      #{year} 
                    GROUP BY t.noc_name", query_params

        print_data(db.get_data(data), true)
      end
    end

    def print_data(data, average = false)
      max = 0
      sum = 0

      data.each do |elem| 
        sum += elem.last.to_i
        max = elem.last.to_i if elem.last.to_i > max
      end

      avg = sum.to_f / data.size

      data.each do |elem| 
        if average == false || elem.last.to_i > avg 
          puts "#{elem.first}" + "█" * ((elem.last.to_f / max) * @chart_size) + "\n\n"
        end
      end
    end  
end
