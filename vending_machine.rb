class VendingMachine
  ACCEPTABLE_CURRENCIES = [10, 50, 100, 500, 1000]
  Drink = Struct.new(:name, :price, :amount) do
    def stock?
      amount >= 1
    end

    def pop
      self.amount -= 1
    end

    def buyable?(current_amount)
      stock? && price <= current_amount
    end
  end
  attr_reader :total_amount, :drinks, :sales

  def initialize
    @total_amount = 0
    cola = Drink.new('コーラ', 120, 5)
    water = Drink.new('水', 100, 5)
    redbull = Drink.new('レッドブル', 200, 5)
    @drinks = [cola,water,redbull]
    @sales = 0
  end

  def drink
    @drinks[0]
  end

  def insert_coin(amount)
    @total_amount += amount if ACCEPTABLE_CURRENCIES.include? amount
    amount
  end

  def refund
    @total_amount
  end

  def buyable?
    @drinks[0].buyable?(@total_amount)
  end

  def buy
    return unless buyable?
    @drinks[0].pop
    @sales += @drinks[0].price
    @total_amount -= @drinks[0].price
  end

  def buyables
    @drinks.select do |drink|
      drink.buyable?(@total_amount)
    end.map(&:name)
  end
end
