require 'rubygems'
require 'sinatra'
require 'slim'
require 'sinatra/reloader' if development?
require "rotten"
Rotten.api_key = 'vmfntfj7qgd3hybe6m5xq45b'

=begin
use Rack::Session::Pool

get '/count' do
  session[:count] ||= 0
  session[:count] +=1
  "Count: #{session[:count]}"
end

get '/reset' do
  session.clear
  "Count reset to 0."
end

=end

#Class For New Players
class Player
	attr_accessor :name, :guess, :round_score, :total_score

	def initialize 
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

	#New game function.  Makes set number of player classes in @@player array.
	def new_game(players) 
		@@player = []
		players.times do |x|
			@@player[x] = Player.new
			@@player[x].name = "Player#{x}"
		end
	end

	#Reset player scores and round counter
	def reset_game()
		@@player.each do |x|
			x.total_score = 0
		end
		@@i = 0 
	end

	#Calculates each players score based guess
	def player_score()
		params.each do |x, y|
			@@player.each do |z|
				if z.name == x 
					z.guess = y.to_i
					z.round_score = (y.to_i - @@movie[@@i].ratings['critics_score'].to_i).abs
					z.total_score += (y.to_i - @@movie[@@i].ratings['critics_score'].to_i).abs
				end
			end
		end
	end

	#Sorts players by score
	def player_sort()
		@@player.sort {|a, b| a.total_score <=> b.total_score }
	end

	#Check if there is a tie score
	def tie()
		@final_scores = []
		@@player.each { |x| @final_scores << x.total_score }
		@final_scores.uniq == @final_scores
	end

	#Assign Color to progress bar on score page
	def bar_color(score)
		if score < 100
			"progress-bar-danger"
		elsif 100 <= score  && score < 200
			"progres-bar-warning"
		elsif 200 <= score && score < 350
			"progress-bar-info"
		else
			"progress-bar-success"
		end
	end


end

#Round counting variable
@@i = 0

get '/' do
	slim :home
end

get '/players' do
	slim :players
end

post '/numplayers' do
	slim :names
end

post '/names' do
	slim :titles
end

post '/titles' do
	@@movie = Array.new
	params.each do |x, y|
		@@movie << retrieve_movie(y)
	end
	slim :guess
end

get '/guess' do
	slim :guess
end

post '/submit_guess' do
	slim :search
end

get '/score' do
	slim :score
end

get '/reset' do
	reset_game()
	redirect to('/')
end

