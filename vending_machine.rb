class VendingMachine
  attr_reader :total_amount

  def initialize
    @total_amount = 0
  end

  def insert_coin(amount)
    @total_amount += amount
    amount
  end

  def refund
    @total_amount
  end
end
