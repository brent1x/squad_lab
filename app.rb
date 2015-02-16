require 'pry'
require 'sinatra'
require 'better_errors'
require 'pg'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'Brent')

before do
  @conn = settings.conn
end

#######################
######### GETS ########
#######################

get '/' do
  redirect '/squads'
end 

get '/squads' do
  squads = []
  @conn.exec("SELECT * FROM squads ORDER BY squad_id ASC") do |result|
    result.each do |squad|
      squads << squad
    end
  end
  @squads = squads
  erb :index
end

get '/squads/new' do
  erb :newsquad
end

get '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  erb :show
end

get '/squads/:squad_id/edit' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  erb :edit
end

get '/squads/:squad_id/students' do
  erb :showstu
end

get '/squads/:squad_id/students/:student_id' do

end

get '/squads/:squad_id/students/new' do

end

get '/squads/:squad_id/students/:student_id/edit' do

end

########################
######### POSTS ########
########################

post '/squads' do
  @conn.exec("INSERT INTO squads (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])
  redirect '/squads'
end

post '/squads/:squad_id/students' do

end

#######################
######### PUTS ########
#######################

put '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec("UPDATE squads SET name = $1 WHERE squad_id = $2", [params[:name], squad_id])
  @conn.exec("UPDATE squads SET mascot = $1 WHERE squad_id = $2", [params[:mascot], squad_id])
  redirect '/squads'
end

put '/squads/:squad_id/students' do

end

#######################
####### DELETES #######
#######################

delete '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec("DELETE FROM squads WHERE squad_id = $1", [squad_id])
  redirect '/squads'
end

delete '/squads/:squad_id/students/:student_id' do

end






















