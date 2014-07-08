require 'sinatra'
require 'slim'
require 'sinatra/reloader' if development?
require "rotten"
Rotten.api_key = 'vmfntfj7qgd3hybe6m5xq45b'

@@player1_score = 0
@@player2_score = 0

helpers do
	def player_score(number)
			@@player1_round_score = (@@movie1.ratings['critics_score'].to_i - @guess1.to_i).abs
			@@player1_score += @@player1_round_score
			@@player2_round_score = (@@movie1.ratings['critics_score'].to_i - @guess2.to_i).abs
			@@player2_score += @@player2_round_score
	end
end

get '/' do
	slim :home
end

post '/' do
	@@movie1 = Rotten::Movie.search(params[:title1])[0]
	slim :guess
end


post '/search' do
	@guess1 = params[:player1]
	@guess2 = params[:player2]
	player_score(1)
	slim :search
end