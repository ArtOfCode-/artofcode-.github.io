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
end

Liquid::Template.register_filter(LiquidFilter)
