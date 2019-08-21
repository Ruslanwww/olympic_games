require 'sqlite3'

db_path = "olympic_history.db"

seasons_list = { summer: 0, winter: 1 }
medals_list = { bronze: 1, silver: 2, gold: 3 }
medals = "1, 2, 3"
season = nil
noc_year = nil

ARGV[1..-1].each do |elem|
  if ["summer", "winter"].include? elem
    season = seasons_list[elem.to_sym]
  elsif ["bronze", "silver", "gold"].include? elem
    medals = medals_list[elem.to_sym]
  else
    noc_year = elem.upcase
  end
end

if ARGV[0] == "medals"
  if noc_year.nil?
  puts "Please, enter noc"
  elsif season.nil?
    puts "Please, enter valid season"
  else  
    begin
      db = SQLite3::Database.open "#{db_path}"

      res = db.execute "select g.year, count(r.id) from results r 
                    join athletes a on(r.athlete_id = a.id) 
                    join teams t on(a.team_id = t.id) 
                    join games g on(r.game_id = g.id) 
                  where t.noc_name = \"#{noc_year}\"
                    and r.medal in(#{medals})
                    and g.season = #{season} group by g.year;"
        
    rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e   
    ensure
        db.close if db
    end

    max = 0

    res.each{ |elem| max = elem.last if elem.last > max }

    res.each { |elem| puts "#{elem.first} " + "█" * ((elem.last.to_f / max) * 160).to_i + "\n\n"}
  end

elsif ARGV[0] == "top-teams"
  if season.nil?
    puts "Please, enter valid season"
  else  
    def db_year year
      if year.nil?
        ""
      else
        "year = #{year.to_i} AND"
      end
    end

    begin
      db = SQLite3::Database.open "#{db_path}"

      res = db.execute "select t.noc_name, count(r.id) from results r 
                    join athletes a on(r.athlete_id = a.id) 
                    join teams t on(a.team_id = t.id) 
                    join games g on(r.game_id = g.id) 
                  where #{db_year(noc_year)} r.medal in(#{medals})
                    and g.season = #{season} group by t.noc_name;"
        
    rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e   
    ensure
        db.close if db
    end

    max = 0
    sum = 0

    res.each do |elem| 
      sum += elem.last
      max = elem.last if elem.last > max
    end

    avg = sum.to_f / res.size

    res.each { |elem| puts "#{elem.first} " + "█" * ((elem.last.to_f / max) * 160).to_i + "\n\n" if elem.last > avg }
  end
end
