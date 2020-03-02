require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    attempt = params[:attempt].upcase
    grid = params[:grid].gsub(/[^A-Z]/, '').split('')
    url = 'https://wagon-dictionary.herokuapp.com/' + attempt
    array = open(url).read
    word_exist = JSON.parse(array)
    attempt_hash = {}
    grid_hash = {}
    attempt.split('').each do |key|
      attempt_hash[key.to_sym] ? attempt_hash[key.to_sym] += 1 : attempt_hash[key.to_sym] = 1
    end
    grid.each do |key|
      grid_hash[key.to_sym] ? grid_hash[key.to_sym] += 1 : grid_hash[key.to_sym] = 1
    end

    condition = attempt_hash.all? do |k, v|
      grid_hash[k] >= v if grid_hash[k].nil? == false
    end
    if !condition
      score_p = 0
      message = "Sorry, but #{attempt} cannot built out of #{grid.join(', ')}"

    elsif word_exist['found'] == false
      score_p = 0
      message = "Sorry, but #{attempt} does not seem to be a valid English word..."
    else
      score_p = attempt.split('').length
      message = "Congratulations ! #{attempt} is a valid English word!"
    end
    if session[:score].nil?
      session[:score] = score_p
    else
      score_p += session[:score]
    end
    @result = { score: score_p, message: message }
  end

  def generate_grid(grid_size)
    (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end
end
