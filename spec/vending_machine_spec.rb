require 'spec_helper'
require_relative '../vending_machine'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }

  describe '#insert_coin' do
    it "お金を投入できる" do
      expect(vending_machine.insert_coin(500)).to eq(500)
    end
  end

  describe '#total_amount' do
    it '投入は複数回できる' do
      expect(vending_machine.insert_coin(10)).to eq(10)
      expect(vending_machine.insert_coin(100)).to eq(100)
      expect(vending_machine.insert_coin(1000)).to eq(1000)

      expect(vending_machine.total_amount).to eq(1110)
    end

    it "想定外のもの（硬貨：１円玉、５円玉。お札：千円札以外のお札）が投入された場合は、投入金額に加算せず、それをそのまま釣り銭としてユーザに出力する" do
      expect(vending_machine.insert_coin(1)).to eq(1)
      expect(vending_machine.insert_coin(5)).to eq(5)
      expect(vending_machine.insert_coin(2000)).to eq(2000)
      expect(vending_machine.insert_coin(5000)).to eq(5000)
      expect(vending_machine.insert_coin(10000)).to eq(10000)
      expect(vending_machine.total_amount).to eq(0)
    end
  end

  describe '#refund' do
    it '払い戻し操作を行うと、投入金額の総計を釣り銭として出力する' do
      vending_machine.insert_coin(50)
      expect(vending_machine.refund).to eq [50]
    end

    it '払い戻し操作では現在の投入金額からジュース購入金額を引いた釣り銭を出力する' do
      vending_machine.insert_coin(100)
      vending_machine.insert_coin(100)
      vending_machine.buy('コーラ')
      expect(vending_machine.refund).to eq [50, 10, 10, 10]
      expect(vending_machine.refund).to eq []
    end
  end

  describe '#buyable?' do
    it '投入金額の点で、コーラが購入できるかどうかを取得できる。' do
      expect(vending_machine.buyable?('コーラ')).to eq false
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(100)
      expect(vending_machine.buyable?('コーラ')).to eq true
    end

    it '在庫の点で、コーラが購入できるかどうかを取得できる。' do
      5.times do
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(100)
        vending_machine.buy('コーラ')
      end

      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(100)
      expect(vending_machine.buyable?('コーラ')).to eq false
    end
  end

  describe '#buy' do
    it 'ジュース値段以上で、購入操作を行うと、ジュースの在庫が減る' do
      expect(vending_machine.find_drink_by_name('コーラ').amount).to eq 5
      # 買えない
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.buy('コーラ')
      expect(vending_machine.find_drink_by_name('コーラ').amount).to eq 5

      # 買える
      vending_machine.insert_coin(100)

      vending_machine.buy('コーラ')
      expect(vending_machine.find_drink_by_name('コーラ').amount).to eq 4
    end

    it '購入操作を行うと、売上金額が増える' do
      expect(vending_machine.sales).to eq 0
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(100)

      vending_machine.buy('コーラ')
      expect(vending_machine.sales).to eq 120
    end

    it '投入金額が足りない場合もしくは在庫がない場合、購入操作を行っても何もしない。' do
      5.times do
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(100)
        vending_machine.buy('コーラ')
      end

      expect { vending_machine.buy('コーラ') }.to_not change { vending_machine.sales }
      expect { vending_machine.buy('コーラ') }.to_not change { vending_machine.find_drink_by_name('コーラ').amount }
    end

    it 'ジュース値段以上の投入金額が投入されている条件下で購入操作を行うと、釣り銭（投入金額とジュース値段の差分）を出力する。' do
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(100)
      expect(vending_machine.buy('コーラ')).to eq(10)
      expect(vending_machine.refund).to eq [10]
    end
  end

  describe '#buyables' do
    it '投入金額、在庫の点で購入可能なドリンクのリストを取得できる。最初' do
      expect(vending_machine.buyables).to eq []
    end

    it '投入金額、在庫の点で購入可能なドリンクのリストを取得できる。150円入れる' do
      vending_machine.insert_coin(100)
      vending_machine.insert_coin(50)
      expect(vending_machine.buyables).to eq ['コーラ', '水']
    end

    it '投入金額、在庫の点で購入可能なドリンクのリストを取得できる。何回か買って150円入れる' do
      5.times do
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(10)
        vending_machine.insert_coin(100)
        vending_machine.buy('コーラ')
      end

      vending_machine.insert_coin(100)
      vending_machine.insert_coin(50)
      vending_machine.buy('コーラ')
      expect(vending_machine.buyables).to eq ['水']
    end
  end

  describe '.new' do
    it do
      cola =  vending_machine.find_drink_by_name('コーラ')
      expect(cola.name).to eq('コーラ')
      expect(cola.price).to eq(120)
      expect(cola.amount).to eq(5)

      water =  vending_machine.find_drink_by_name('水')
      expect(water.name).to eq('水')
      expect(water.price).to eq(100)
      expect(water.amount).to eq(5)

      redbull =  vending_machine.find_drink_by_name('レッドブル')
      expect(redbull.name).to eq('レッドブル')
      expect(redbull.price).to eq(200)
      expect(redbull.amount).to eq(5)
    end

    it '釣り銭ストックとして、有効な各お札と硬貨10枚ずつ保持する。' do
      stock = vending_machine.change_stock
      expect(stock).to eq({ 10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 10 })
    end
  end
end
