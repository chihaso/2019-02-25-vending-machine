require 'spec_helper'
require_relative '../vending_machine'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }

  it "500円を投入できる" do
    expect(vending_machine.insert_coin(500)).to eq(500)
   end
end
