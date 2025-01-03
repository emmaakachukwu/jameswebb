class String
  def highlight substring, colour_code
    gsub(/#{Regexp.escape(substring)}/) do |match|
      "\e[#{colour_code}m#{match}\e[0m"
    end
  end

end
