#!/usr/bin/env ruby

require 'faker'
require_relative 'helpers'

USED_SYMBOLS = Set.new

class Stock
  attr_reader :symbol, :direction

  def initialize
    @symbol = random_symbol
    @direction = %w[up down].sample
  end

  def to_s
    "#{@symbol} went #{direction}"
  end

  private

  def random_symbol
    symbol = Faker::Finance.ticker
    USED_SYMBOLS.include?(symbol) ? random_symbol : symbol
  end
end

class Message
  attr_reader :stock, :direction

  def initialize(stock, direction)
    @stock = stock
    @direction = direction
    print Colorize.green('.')
  end

  def to_s
    "Watch out! #{Colorize.light_blue(stock.symbol)} is going #{Colorize.green(direction)}!"
  end
end

class Recipient
  attr_reader :name, :received_messages
  attr_accessor :continue_sending

  def initialize
    @name = Faker::Name.first_name
    @received_messages = []
    @continue_sending = true
    print Colorize.green('.')
  end

  def receive_message(message)
    self.received_messages << message
  end
end

class Scam
  attr_reader :recipients, :stocks, :steps, :results, :verbose
  def initialize(number_of_recipients, steps, verbose = true)
    @recipients = number_of_recipients.times.map { Recipient.new }
    @stocks = []
    @steps = steps
    @results = []
    @verbose = verbose

    puts Colorize.light_blue('Running steps   ')
    steps.times { next_step! }
    puts
    notify_results! if verbose
  end

  def notify_results!
    puts "After #{steps} steps, #{remaining_recipients.length} recipients remain."
    puts "The following messages were sent:"

    count = recipients.count
    @stocks.each_with_index do |stock, index|
      received_correct = results[index]
      correct = stock.direction
      puts "We started with #{Colorize.red(count)} recipients.  We sent them all messages about #{Colorize.light_blue(stock.symbol)} going up or down."
      puts "We told #{Colorize.red(received_correct)} of them the stock was going #{Colorize.green(correct)}.  These messages were correct so we kept sending them messages after this."
      puts "We told #{Colorize.red(count - received_correct)} of them the stock was going #{Colorize.green(correct == 'up' ? 'down' : 'up')}.  This was wrong so we stopped sending them messages."
      puts
      puts
      count = received_correct
    end
  end

  def remaining_recipients
    recipients.select(&:continue_sending)
  end

  def next_step!
    stock = Stock.new
    stocks << stock
    remaining_recipients.each_with_index do |recipient, i|
      message = Message.new(stock, %w[up down][i.even? ? 0 : 1])
      recipient.receive_message(message)
      recipient.continue_sending = false if stock.direction != message.direction
    end

    self.results << remaining_recipients.count
    print Colorize.green('.')
  end
end

prompt("Welcome to the stock scam! #{Colorize.green('(press Enter to continue)')}")

verbose = prompt("Do you want the scam revealed or not? #{Colorize.green('(y/n)')}").downcase == 'y'

number = prompt(Colorize.light_blue('Please enter a number of recipients to start with:')).to_i
steps = prompt(Colorize.light_blue('Please enter a number of steps to run:')).to_i

scam = Scam.new(number, steps, verbose)
sample_recipient = scam.remaining_recipients.sample

if sample_recipient
  puts "Here is a sample recipient: #{Colorize.red(sample_recipient.name)}"
  puts

  puts "From this recipient's perspective here is what happened:"
  puts
  sample_recipient.received_messages.each do |message|
    puts "#{Colorize.red(sample_recipient.name)} received a message:"
    puts message
    puts "Then #{Colorize.red(sample_recipient.name)} watched as #{Colorize.light_blue(message.stock.symbol)} really went #{Colorize.green(message.stock.direction)}."
    puts
  end

  if verbose
    puts "After receiving #{Colorize.green(sample_recipient.received_messages.count)} messages, it appeared to #{Colorize.red(sample_recipient.name)} that the stock broker was a genius who had never been wrong!  #{Colorize.red(sample_recipient.name)} was convinced to invest all their money with the broker and then lost it all."
  end
else
  puts 'We ran the scam for too many steps, no recipients remain'
end

puts

unless verbose
  show_results = prompt("Do you want to reveal the scam? #{Colorize.green('(y/n)')}").downcase == 'y'
  if show_results
    scam.notify_results!
    puts
    if sample_recipient
      puts "After receiving #{Colorize.green(sample_recipient.received_messages.count)} messages, it appeared to #{Colorize.red(sample_recipient.name)} that the stock broker was a genius who had never been wrong!  #{Colorize.red(sample_recipient.name)} was convinced to invest all their money with the broker and then lost it all."
      puts
    end
  end
end

prompt("Thanks for playing! #{Colorize.green('(press Enter to exit)')} \n\n#{Colorize.light_blue(Faker::Movies::StarWars.wookiee_sentence)}")
