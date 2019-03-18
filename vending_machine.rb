class VendingMachine
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
  attr_reader :drinks, :sales

  def initialize
    cola = Drink.new('コーラ', 120, 5)
    water = Drink.new('水', 100, 5)
    redbull = Drink.new('レッドブル', 200, 5)
    @drinks = [cola,water,redbull]
    @change_stock = ChangeStock.new
    @sales = 0
  end

  def insert_coin(amount)
    @change_stock.insert(amount)
    amount
  end

  def total_amount
    @change_stock.total_deposit
  end

  def refund
    @change_stock.refund
  end

  def buyable?(drink_name)
    find_drink_by_name(drink_name)&.buyable?(@change_stock.total_deposit)
  end

  def buy(drink_name)
    return unless buyable?(drink_name)
    drink = find_drink_by_name(drink_name)
    drink.pop
    @sales += drink.price
    @change_stock.pull_deposit(drink.price)
  end

  def buyables
    @drinks.select do |drink|
      drink.buyable?(@change_stock.total_deposit)
    end.map(&:name)
  end

  def change_stock
    @change_stock.summary
  end

  def find_drink_by_name(name)
    @drinks.find { |drink| drink.name == name }
  end
end

class ChangeStock
  ACCEPTABLE_CURRENCIES = [10, 50, 100, 500, 1000]

  def initialize
    @deposit = 0
    @changes = ACCEPTABLE_CURRENCIES.each_with_object([]) do |currency, array|
      10.times { array << currency }
    end
  end

  def summary
    @changes.group_by(&:itself).transform_values(&:size)
  end

  def insert(currency)
    if ACCEPTABLE_CURRENCIES.include? currency
      @deposit += currency
      @changes << currency
    end
  end

  def refund
    refund_changes = []
    sorted_changes = @changes.sort.reverse
    tmp_deposit = @deposit
    loop do
      change = sorted_changes.shift
      break if change.nil?
      if tmp_deposit >= change
        refund_changes << change
        tmp_deposit -= change
      end
      break if tmp_deposit.zero?
    end
    if tmp_deposit.zero?
      @deposit = 0
      @changes -= refund_changes
      refund_changes
    else
      raise('refund error')
    end
  end

  def total_deposit
    @deposit
  end

  def pull_deposit(price)
    @deposit -= price
  end
end
