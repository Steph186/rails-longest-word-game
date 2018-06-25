require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times do
      @letters << ('a'..'z').to_a.sample
    end
  end

  def score
    @response = params["response"]
    @letters = params["letters"]
    results = run_game(@response, @letters)
    @score_message = results[:message]
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    letters = []
    grid_size.times { letters << ('a'..'z').to_a.sample(1) }
    return letters.flatten
  end

  def get_word(attempt)
    word = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    word["found"]
  end

  def word_in_grid(answer, grid)
    letters_in_answer = answer.uniq.map { |letter| answer.count(letter) }
    letters_in_grid = answer.uniq.map { |letter| grid.count(letter) }
    val = true
    letters_in_answer.each_with_index do |number, index|
      number > letters_in_grid[index] ? val = false : ""
    end
    return val
  end

  def score_message(is_a_word, is_in_grid, time = 0, response, result, letters)
    result[:score] = 0
    if !is_a_word
      result[:message] = "Sorry, but #{response} does not seem to be a valid English word..."
    elsif !is_in_grid
      result[:message] = "Sorry, but #{response} can't be built out of #{letters}"
    else
      result[:score] = response.length * 10  #+ [60 - time].max
      result[:message] = "Congratulations! #{response} is a valid English word!"
    end
    return result
  end

  def run_game(attempt, grid, start_time = 0, end_time = 0)
    # TODO: runs the game and return detailed hash of result
    result = {}
    # my_time = end_time - start_time
    # result[:time] = my_time
    letters = attempt.downcase.split('')
    is_in_grid = word_in_grid(letters, grid)
    is_a_word = get_word(attempt)
    score_message(is_a_word, is_in_grid, attempt, result, grid)
  end
end
