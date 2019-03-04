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
      expect(vending_machine.refund).to eq 50
    end

    it '払い戻し操作では現在の投入金額からジュース購入金額を引いた釣り銭を出力する' do
      vending_machine.insert_coin(100)
      vending_machine.insert_coin(100)
      vending_machine.buy('コーラ')
      expect(vending_machine.refund).to eq 80
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
      expect(vending_machine.drink.amount).to eq 5
      # 買えない
      vending_machine.insert_coin(10)
      vending_machine.insert_coin(10)
      vending_machine.buy('コーラ')
      expect(vending_machine.drink.amount).to eq 5

      # 買える
      vending_machine.insert_coin(100)

      vending_machine.buy('コーラ')
      expect(vending_machine.drink.amount).to eq 4
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
      expect { vending_machine.buy('コーラ') }.to_not change { vending_machine.drink.amount }
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

  it '初期状態で、コーラ（値段:120円、名前”コーラ”）を5本格納している' do
    expect(vending_machine.drinks[0].name).to eq('コーラ')
    expect(vending_machine.drinks[0].price).to eq(120)
    expect(vending_machine.drinks[0].amount).to eq(5)
  end

  it '初期状態で、水（値段:100円、名前”水”）を5本格納している' do
    expect(vending_machine.drinks[1].name).to eq('水')
    expect(vending_machine.drinks[1].price).to eq(100)
    expect(vending_machine.drinks[1].amount).to eq(5)
  end

  it '初期状態で、レッドブル（値段:200円、名前”レッドブル”）を5本格納している' do
    expect(vending_machine.drinks[2].name).to eq('レッドブル')
    expect(vending_machine.drinks[2].price).to eq(200)
    expect(vending_machine.drinks[2].amount).to eq(5)
  end
end
