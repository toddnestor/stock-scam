#!/usr/bin/env ruby

require_relative 'helpers'

class Coin
  attr_reader :flips

  def initialize
    @flips = []
  end

  def flip!
    @flips << %w[heads tails].sample
  end

  def last_flip
    flips.last
  end
end

class Flipper
  attr_accessor :flips
  attr_reader :coins

  def initialize(coins)
    @coins = coins
    @flips = 0
  end

  def flip!
    coins.each(&:flip!)
    self.flips += 1
  end

  def results
    heads = 0
    tails = 0
    coins.each { |coin| coin.last_flip == 'heads' ? heads += 1 : tails += 1 }

    puts "#{Colorize.green('You have ')}#{Colorize.red(heads)}#{Colorize.green(' heads and ')}#{Colorize.red(tails)}#{Colorize.green(' tails.')}"
    puts "All the coins with heads have flipped heads #{Colorize.red(flips)} times"
  end

  def discard_tails
    coins.delete_if { |coin| coin.last_flip == 'tails' }
  end
end

prompt("Welcome to the coin flip simulator! #{Colorize.green('(press Enter to continue)')}")
number = prompt(Colorize.light_blue('Please enter a number of coins to start with:')).to_i
goal = prompt(Colorize.light_blue('Please enter a number of heads in a row to aim for (leave blank to flip until no coins remain):')).to_i

coins = number.times.map { Coin.new }
flipper = Flipper.new(coins)

until flipper.coins.length <= 1 || (goal && goal > 0 && flipper.flips >= goal)
  flipper.flip!
  flipper.results
  flipper.discard_tails
  prompt 'Press enter to continue'
end

coin = flipper.coins.first
puts "The remaining coin flipped #{Colorize.red(coin.flips.count)} heads in a row!" unless coin.nil?

prompt("Thanks for playing! #{Colorize.green('(press Enter to exit)')}")
