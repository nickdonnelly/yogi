require "colorize"

module Yogi
  def self.print_commit(commit)
    if commit[1].starts_with? "add"
      return "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.green}"
    elsif commit[1].starts_with? "edit"
      return "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.blue}"
    else
      return "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.red}"
    end
  end
end
