class VendingMachine
  ACCEPTABLE_CURRENCIES = [10, 50, 100, 500, 1000]
  Drink = Struct.new(:name, :price, :amount) do
    def stock?
      amount >= 1
    end
  end
  attr_reader :total_amount, :drink, :sales

  def initialize
    @total_amount = 0
    @drink = Drink.new('コーラ', 120, 5)
    @sales = 0
  end

  def insert_coin(amount)
    @total_amount += amount if ACCEPTABLE_CURRENCIES.include? amount
    amount
  end

  def refund
    @total_amount
  end

  def buyable?
    return false unless @drink.stock?
    drink.price <= total_amount
  end

  def buy
    return unless buyable?
    @drink.amount -= 1
    @sales += @drink.price
    @total_amount -= @drink.price
  end

end
