class DataBaseExecute

  def initialize(chart_size)
    @@seasons_list = { summer: 0, winter: 1 }
    @@medals_list = { bronze: 1, silver: 2, gold: 3 }
    @medals = "1, 2, 3"
    @season = nil
    @noc_year = nil
    @chart_size = chart_size
  end
  
  def params_read(params)
    params.each do |elem|
      if ["summer", "winter"].include? elem
        @season = @@seasons_list[elem.to_sym]
      elsif ["bronze", "silver", "gold"].include? elem
        @medals = @@medals_list[elem.to_sym]
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
        data = db.execute "SELECT g.year, COUNT(r.id) FROM results r 
                      JOIN athletes a ON(r.athlete_id = a.id) 
                      JOIN teams t ON(a.team_id = t.id) 
                      JOIN games g ON(r.game_id = g.id) 
                    WHERE t.noc_name = \'#{@noc_year}\'
                      AND r.medal IN(#{@medals})
                      AND g.season = #{@season} GROUP BY g.year;"

        print_data(db.get_data(data), true)
      end
    end

    def read_teams(db)
      if @season.nil?
        puts "Please, enter valid season"
      else  
        year = @noc_year.nil? ? "" : "year = #{@noc_year.to_i} AND"

        data = db.execute "SELECT t.noc_name, COUNT(r.id) FROM results r 
                      JOIN athletes a ON(r.athlete_id = a.id) 
                      JOIN teams t ON(a.team_id = t.id) 
                      JOIN games g ON(r.game_id = g.id) 
                    WHERE #{year} r.medal IN(#{@medals})
                      AND g.season = #{@season} GROUP BY t.noc_name;"

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
