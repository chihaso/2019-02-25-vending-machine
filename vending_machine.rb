class VendingMachine
  attr_reader :total_amount

  def initialize
    @total_amount = 0
  end

  def insert_coin(amount)
    if amount > 5 && amount < 5000 then
      @total_amount += amount
    end
    amount
  end

  def refund
    @total_amount
  end
end
