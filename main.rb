require 'rubygems'
require 'sinatra'
require 'slim'
require "rotten"
Rotten.api_key = 'vmfntfj7qgd3hybe6m5xq45b'
require 'sinatra/reloader' if development?
#require 'pry'

use Rack::Session::Pool
set :session_secret, 'master-key'

#Class For New Players
class Player
	attr_accessor :name, :computer, :difficulty, :guess, :round_score, :total_score
	def initialize 
		@computer = false
		@difficulty = 0
		@guess = 0
		@round_score = 0
		@total_score = 0
	end
end

helpers do
	#Use rotten gem to find movie title on rotten tomatoes
	def retrieve_movie(title)
		Rotten::Movie.search(title)[0]
	end

	#New game function.  Starts counting rounds and creates new players using session variables
	def new_game(players) 
		session.clear
		session[:round_count] = 0
		session[:player] = Array.new
		params[:numplayers].to_i.times do |x|
			session[:player][x] = Player.new
			session[:player][x].name = "Player#{x}"
		end
		#Add Computer Player
		if params[:computer_easy] == "yes"
			computerPlayer = Player.new
			computerPlayer.name = "Fake Teresa"
			computerPlayer.computer = true
			computerPlayer.difficulty = 0
			session[:player] << computerPlayer
		end
		if params[:computer_medium] == "yes"
			computerPlayer = Player.new
			computerPlayer.name = "Pete Corolla"
			computerPlayer.computer = true
			computerPlayer.difficulty = 1
			session[:player] << computerPlayer
		end
		if params[:computer_hard] == "yes"
			computerPlayer = Player.new
			computerPlayer.name = "Hairy Brian"
			computerPlayer.computer = true
			computerPlayer.difficulty = 2
			session[:player] << computerPlayer
		end
	end


	#Calculates each players score based on guess
	def player_score()
		params.each do |name, guess| #recieves guess from form on guess.slim
			session[:player].each do |z|
				if z.name ==  name
					z.guess = guess.to_i
					z.round_score = (z.guess - session[:movie][session[:round_count]].ratings['critics_score'].to_i).abs
					z.total_score += (z.guess - session[:movie][session[:round_count]].ratings['critics_score'].to_i).abs
				end
			end
		end
	end

	#New Method For Computer Player
	def computer_score(computer)
		@criticsScore = session[:movie][session[:round_count]].ratings['critics_score'].to_i
		#Scoring Logic
		case computer.difficulty
		when 0
			computer.guess = rand(1..100)
			computer.round_score = (computer.guess - @criticsScore).abs
			computer.total_score += (computer.guess - @criticsScore).abs
		when 1
			@lower = @criticsScore - 25
			@upper = @criticsScore + 25
			@lower = @lower < 0 ? 0 : @lower
			@upper = @upper > 100 ? 100 : @upper
			computer.guess = rand(@lower..@upper)
			computer.round_score = (computer.guess - @criticsScore).abs
			computer.total_score += (computer.guess - @criticsScore).abs
		when 2
			@lower = @criticsScore - 15
			@upper = @criticsScore + 15
			@lower = @lower < 0 ? 0 : @lower
			@upper = @upper > 100 ? 100 : @upper
			computer.guess = rand(@lower..@upper)
			computer.round_score = (computer.guess - @criticsScore).abs
			computer.total_score += (computer.guess - @criticsScore).abs
		end

	end

	#Sorts players by score
	def player_sort()
		session[:player].sort {|a, b| a.total_score <=> b.total_score }
	end

	#Check if there is a tie score
	def no_tie()
		@final_scores = []
		session[:player].each { |x| @final_scores << x.total_score }
		@final_scores.uniq == @final_scores
	end

	#Assign Color to progress bar on score page
	def bar_color(score)
		if score < 50
			"progress-bar-danger"
		elsif 50 <= score  && score < 100
			"progres-bar-warning"
		elsif 100 <= score && score < 150
			"progress-bar-info"
		else
			"progress-bar-success"
		end
	end

	#Retrieve moviess with Rotten API and store in session array
	def movie_titles(params)
		session[:movie] ||= Array.new
		params.each do |x, y|
			session[:movie] << retrieve_movie(y)
		end
	end

	#Assigns player names from form submission
	def assign_names()
		params.each { |number, name| session[:player][number.to_i].name = name }
	end

end

get '/' do
	slim :home
end

get '/players' do
	slim :players
end

post '/numplayers' do
	new_game(params[:numplayers].to_i)
	slim :names
end

post '/names' do
	slim :titles
end

post '/titles' do
	movie_titles(params)
	@movie = session[:movie][session[:round_count]]
	slim :guess
end

get '/guess' do
	@movie = session[:movie][session[:round_count]]
	slim :guess
end

post '/submit_guess' do
	@movie = session[:movie][session[:round_count]]
	slim :search
end

get '/score' do
	slim :score
end



