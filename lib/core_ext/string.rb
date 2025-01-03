class String
  def highlight substring, colour_code, ignore_case: false
    gsub(Regexp.new(Regexp.escape(substring), ignore_case)) do |match|
      "\e[#{colour_code}m#{match}\e[0m"
    end
  end

end
