module LiquidFilter
  def liquify(input)
    Liquid::Template.parse(input).render(@context)
  end

  def hk(input)
    input.to_a[0][0]
  end

  def hv(input)
    input.to_a[0][1]
  end

  def descriptionize(input, length)
    s = input[0...length]
    s = input.size > length ? "#{s}..." : input
    s = s.gsub "\n", ' '
    s = s.gsub '"', '&quot;'
    s
  end

  def att_sanitize(input)
    s = input.gsub "\n", ' '
    s = s.gsub '"', '&quot;'
    s
  end

  def colorize(input, color, weight = 'normal')
    "<span class=\"fw-#{weight} fc-#{color}\">#{input}</span>"
  end
end

Liquid::Template.register_filter(LiquidFilter)
