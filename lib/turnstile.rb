require 'aasm'

class Turnstile

  include AASM

  aasm do
    state :locked, initial: true
    state :unlocked

    event :unlock do
      transitions from: :locked, to: :unlocked, guard: :enough_coins?
    end

    event :cancel do
      after do
        @coins-=@coins_to_pass
        unlock if may_unlock?
      end
      transitions from: :unlocked, to: :locked
    end
    event :pass do
      before do
        transfer_coins
      end
      after do
        unlock if may_unlock?
      end
      transitions from: :unlocked, to: :locked
    end
  end

  attr_reader :coins_to_pass, :coins, :total_coins

  def initialize(coins_to_pass = 10)
    @coins_to_pass = coins_to_pass
    @total_coins=0
    @coins=0
  end

  def put(coins)
    raise ArgumentError if coins.to_i<=0
    self.tap{ add_coins(coins) }
  end

  private

  def add_coins(coins)
    @coins += coins
    unlock if may_unlock?
  end

  def enough_coins?
    @coins >= @coins_to_pass
  end

  def transfer_coins
    @coins -= @coins_to_pass
    @total_coins += @coins_to_pass
  end
end
