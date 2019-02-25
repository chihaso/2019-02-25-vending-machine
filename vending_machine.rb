class VendingMachine
  ACCEPTABLE_CURRENCIES = [10, 50, 100, 500, 1000]
  Drink = Struct.new(:name, :price, :amount)
  attr_reader :total_amount, :drink

  def initialize
    @total_amount = 0
    @drink = Drink.new('コーラ', 120, 5)
  end

  def insert_coin(amount)
    @total_amount += amount if ACCEPTABLE_CURRENCIES.include? amount
    amount
  end

  def refund
    @total_amount
  end
end
