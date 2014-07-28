require './lib/turnstile'

describe Turnstile do

  context "new object" do
    let(:turnstile) { Turnstile.new }
    it { expect(turnstile.coins_to_pass).to eq 10 }
    it { expect(turnstile.coins).to eq 0 }
    it { expect(turnstile.total_coins).to eq 0 }
    it { expect(turnstile).to be_locked }
  end

  describe "::initialize" do
    subject { Turnstile.new(100).coins_to_pass }
    it { is_expected.to eq 100 }
  end

  describe "putting coins" do

    context "when less than coins to pass" do
      let(:turnstile) { Turnstile.new.put(5) }
      it { expect(turnstile.coins).to eq 5 }
      it { expect(turnstile.total_coins).to eq 0 }
      it { expect(turnstile).to be_locked }
    end

    context "when equal to coins to pass" do
      let(:turnstile) { Turnstile.new.put(10) }
      it { expect(turnstile.coins).to eq 10 }
      it { expect(turnstile.total_coins).to eq 0 }
      it { expect(turnstile).to be_unlocked }
    end

    context "when equal to coins to pass split" do
      let(:turnstile) { Turnstile.new.put(5).put(5) }
      it { expect(turnstile.coins).to eq 10 }
      it { expect(turnstile.total_coins).to eq 0 }
      it { expect(turnstile).to be_unlocked }
    end

    context "when more than coins to pass" do
      let(:turnstile) { Turnstile.new.put(250) }
      it { expect(turnstile.coins).to eq 250 }
      it { expect(turnstile.total_coins).to eq 0 }
      it { expect(turnstile).to be_unlocked }
    end

    context "incorrect values" do
      let(:turnstile) { Turnstile.new }
      it { expect{turnstile.put(-5)}.to raise_error ArgumentError }
      it { expect{turnstile.put(0)}.to raise_error ArgumentError }
      it { expect{turnstile.put("asdf")}.to raise_error ArgumentError }
      it { expect{turnstile.put(nil)}.to raise_error ArgumentError }
    end
  end

  describe "passing" do

    context "when coins equal to coins to pass" do
      let(:turnstile) { Turnstile.new.put(10) }
      before { turnstile.pass }
      it { expect(turnstile).to be_locked }
      it { expect(turnstile.coins).to eq 0 }
      it { expect(turnstile.total_coins).to eq 10 }
    end

    context "when coins more than coins to pass" do
      let(:turnstile) { Turnstile.new.put(25) }
      context "once" do
        before { turnstile.pass }
        it { expect(turnstile).to be_unlocked }
        it { expect(turnstile.coins).to eq 15 }
        it { expect(turnstile.total_coins).to eq 10 }
      end
      context "twice" do
        before { 2.times{ turnstile.pass } }
        it { expect(turnstile).to be_locked }
        it { expect(turnstile.coins).to eq 5 }
        it { expect(turnstile.total_coins).to eq 20 }
      end
    end

    context "unlocked" do
      let(:turnstile) { Turnstile.new.put(10) }
      it { expect{turnstile.pass}.not_to raise_error }
    end
    context "locked" do
      let(:turnstile) { Turnstile.new }
      it { expect{turnstile.pass}.to raise_error AASM::InvalidTransition }
    end
  end

  describe "cancelling" do
    context "when no coins" do
      let(:turnstile) { Turnstile.new }
      it { expect(turnstile).to be_locked }
      it { expect(turnstile).not_to be_may_cancel }
    end
    context "when coins equal to coins to pass" do
      let(:turnstile) { Turnstile.new.put(10) }
      before { turnstile.cancel }
      it { expect(turnstile.coins).to eq 0 }
      it { expect(turnstile).to be_locked }
    end
    context "when coins more than coins to pass" do
      let(:turnstile) { Turnstile.new.put(25) }
      before { turnstile.cancel }
      it { expect(turnstile.coins).to eq 15 }
      it { expect(turnstile).to be_unlocked }
    end
  end
end
