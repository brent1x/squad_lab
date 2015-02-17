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

get '/squads/:squad_id/students/new' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  erb :newstudent
end

get '/squads/:squad_id/students' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  students = []
  @conn.exec("SELECT * FROM students WHERE squad_id = $1", [squad_id]) do |result|
    result.each do |student|
      students << student
    end
  end
  @students = students
  erb :showstu
end

get '/squads/:squad_id/students/:id' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  id = params[:id].to_i
  student = @conn.exec("SELECT * FROM students WHERE id = $1", [id])
  @student = student[0]
  erb :showstuinvid
end

get '/squads/:squad_id/students/:id/edit' do
  squad_id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE squad_id = $1", [squad_id])
  @squad = squad[0]
  id = params[:id].to_i
  student = @conn.exec("SELECT * FROM students WHERE id = $1", [id])
  @student = student[0]
  erb :editstu
end

########################
######### POSTS ########
########################

post '/squads' do
  @conn.exec("INSERT INTO squads (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])
  redirect '/squads'
end

post '/squads/:squad_id/students' do
  squad_id = params[:squad_id].to_i
  @conn.exec("INSERT INTO students (name, position, age, squad_id) VALUES ($1, $2, $3, $4)", [params[:name], params[:position], params[:age], squad_id])
  redirect '/squads/' << params[:squad_id]
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

put '/squads/:squad_id/students/:id' do
  squad_id = params[:squad_id].to_i
  id = params[:id].to_i
  @conn.exec("UPDATE students SET name = $1 WHERE squad_id = $2 AND id = $3", [params[:name], squad_id, id])
  @conn.exec("UPDATE students SET position = $1 WHERE squad_id = $2 AND id = $3", [params[:position], squad_id, id])
  @conn.exec("UPDATE students SET age = $1 WHERE squad_id = $2 AND id = $3", [params[:age], squad_id, id])
  redirect '/squads/' << params[:squad_id] << '/students'
end

#######################
####### DELETES #######
#######################

delete '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec('DELETE FROM students WHERE squad_id = $1', [squad_id])
  @conn.exec("DELETE FROM squads WHERE squad_id = $1", [squad_id])
  redirect '/squads'
end

delete '/squads/:squad_id/students/:id' do
  squad_id = params[:squad_id].to_i
  id = params[:id].to_i
  @conn.exec("DELETE FROM students WHERE id = $1 AND squad_id = $2", [id, squad_id])
  redirect '/squads/' << params[:squad_id] << '/students'
end