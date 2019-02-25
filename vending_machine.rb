class VendingMachine
  attr_reader :total

  def initialize
    @total = 0
  end

  def insert_coin(amount)
    @total += amount
    amount
  end

  def refund
    @total
  end
end
