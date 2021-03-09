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
    s = s.gsub '"', '\"'
    s
  end

  def att_sanitize(input)
    s = input.gsub "\n", ' '
    s = s.gsub '"', '\"'
    s
  end
end

Liquid::Template.register_filter(LiquidFilter)
