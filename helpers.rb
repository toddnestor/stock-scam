# Class for coloring strings in command line output
class Colorize
  def self.color(string, color_code)
    "\e[#{color_code}m#{string}\e[0m"
  end

  def self.red(string)
    color(string, 31)
  end

  def self.green(string)
    color(string, 32)
  end

  def self.yellow(string)
    color(string, 33)
  end

  def self.blue(string)
    color(string, 34)
  end

  def self.pink(string)
    color(string, 35)
  end

  def self.light_blue(string)
    color(string, 36)
  end
end

def prompt(message)
  puts "=> #{message}"
  gets.chomp
end
