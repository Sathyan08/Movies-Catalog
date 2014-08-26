require 'sinatra'

require 'sinatra/reloader'

require 'pg'

require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end



get '/movies' do

  # connection = db_connection
    db_connection do |conn|
      @movies = conn.exec('SELECT * FROM movies ORDER BY title')
    end

  erb :'movies/index'

end

# get '/movies?page=:number' do
#   @page_number = params[:number]
#   skip_number = 20 * @page_number.to_i

#   db_connection do |conn|
#     @movies = conn.exec('SELECT * FROM movies ORDER BY title LIMIT 20  OFFSET $1', [skip_number])
#   end

#   erb :'movies/index'
# end

get '/movies/:id' do

  id = params[:id]

  db_connection do |conn|
    @movie = conn.exec_params('SELECT * FROM movies WHERE id = $1', [id])
  end

  db_connection do |conn|
    @studio = conn.exec_params('SELECT * FROM studios WHERE id = $1', [@movie[0]["studio_id"]])
  end

  db_connection do |conn|
    @genre = conn.exec_params('SELECT * FROM genres WHERE id = $1', [@movie[0]["genre_id"]])
  end

  db_connection do |conn|
    @actors = conn.exec_params('SELECT * FROM actors JOIN cast_members ON cast_members.actor_id = actors.id WHERE cast_members.movie_id = $1', [@movie[0]["id"]])
  end



  erb :'movies/show'
end


get'/actors' do
  db_connection do |conn|
    @actors= conn.exec('SELECT * FROM actors ORDER BY name')
  end

  erb :'actors/index'

end


get '/actors/:id' do

  id = params[:id]

  db_connection do |conn|
    @actor = conn.exec_params('SELECT * FROM actors WHERE id = $1', [id])
  end

  db_connection do |conn|
    @movies = conn.exec_params('SELECT * FROM movies JOIN cast_members ON cast_members.movie_id = movies.id WHERE cast_members.actor_id = $1', [id])
  end

  erb :'actors/show'
end


