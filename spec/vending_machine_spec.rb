require 'spec_helper'
require_relative '../vending_machine'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }

  it "お金を投入できる" do
    expect(vending_machine.insert_coin(500)).to eq(500)
  end

  it '投入は複数回できる' do
    expect(vending_machine.insert_coin(10)).to eq(10)
    expect(vending_machine.insert_coin(100)).to eq(100)
    expect(vending_machine.insert_coin(1000)).to eq(1000)

    expect(vending_machine.total_amount).to eq(1110)
  end

  it '払い戻し操作を行うと、投入金額の総計を釣り銭として出力する' do
    vending_machine.insert_coin(50)
    expect(vending_machine.refund).to eq 50
  end
end
