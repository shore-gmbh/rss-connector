require 'spec_helper'

describe RSS::Rule, type: :model do
  let(:fake_time) { Time.zone.now.utc.iso8601 }
  subject { described_class.new }

  context 'mass assignment' do
    context '#initialize' do
      let(:attrs) { { id: 'foo' } }
      subject { described_class.new(attrs) }

      it { expect(subject.id).to eql('foo') }
    end

    context '#attributes=' do
      let(:attrs) { { id: 'foo' } }
      before { subject.attributes = attrs }

      it { expect(subject.id).to eql('foo') }
    end

    context '#attributes' do
      let(:attrs) { { id: 'foo' } }
      before { subject.attributes = attrs }

      it 'returns a hashwith attributes' do
        expect(subject.attributes).to eq(
          id: 'foo',
          recurrence: {}
        )
      end
    end
  end

  context 'defaults' do
    subject { described_class.new }

    it { expect(subject.id).not_to eql(nil) }
    it { expect(subject.recurrence).to eql({}) }
  end

  context 'recurrence=' do
    subject { described_class.new }

    it 'assigns the given hash' do
      subject.recurrence = { starts_at: fake_time }
      expect(subject.recurrence).to eq(starts_at: fake_time)
    end

    it 'ignores non whitelisted attributes' do
      subject.recurrence = { starts_at: fake_time, bar: 'baz' }
      expect(subject.recurrence).to eq(starts_at: fake_time)
    end

    it 'raisies error when given non-hash' do
      expect do
        subject.recurrence = []
      end.to raise_error(RuntimeError)
    end
  end

  context 'as_json' do
    it 'serializes properly' do
      subject.id = 'foo'
      subject.recurrence = { starts_at: fake_time, count: 1 }
      expect(subject.as_json).to eq(
        'id' => 'foo',
        'recurrence' => {
          'count' => 1,
          'starts_at' => fake_time
        }
      )
    end
  end

  context '#one_off?' do
    let(:count)     { 1 }
    let(:starts_at) { Time.new(2015, 11, 25) }
    let(:ends_at)   { Time.new(2015, 11, 26) }
    let(:attrs)     { { count: count, starts_at: starts_at, ends_at: ends_at } }
    subject { described_class.new(attrs).one_off? }

    context 'with count = 1' do
      it { expect(subject).to be_truthy }
    end

    context 'with count != 1' do
      let(:count) { 3 }
      it { expect(subject).to be_falsey }
    end

    context 'with starts_at == ends_at' do
      let(:count)   { 2 }
      let(:ends_at) { starts_at }
      it { expect(subject).to be_truthy }
    end
  end

  context '#load' do
    let(:rule1) do
      {
        id: '83225d3b-9e63-48ae-9c68-cfcbd902529f',
        time_zone: 'Europe/Berlin',
        duration: 3600,
        recurrence: {
          frequency: 'weekly',
          interval: 37,
          count: nil,
          starts_at: '2015-06-20T10:30:00Z',
          ends_at: '2015-12-31T22:59:59Z'
        }
      }
    end
    let(:rule2) do
      {
        id: 'f5683120-ee33-40e8-ac1e-240b3eeec45b',
        time_zone: 'Etc/UTC',
        duration: 3600,
        recurrence: {
          frequency: 'daily',
          interval: 1,
          count: 10,
          starts_at: '2016-03-01T23:00:00Z',
          ends_at: nil
        }
      }
    end
    let(:rules_hashes) do
      [rule1, rule2]
    end

    it 'loads rules properly' do
      rules = described_class.load(rules_hashes.to_json)

      expect(rules.size).to eq(2)
      expect(rules[0].as_json).to eq(
        rules_hashes[0].slice(:id, :duration, :recurrence).as_json
      )
      expect(rules[1].as_json).to eq(
        rules_hashes[1].slice(:id, :duration, :recurrence).as_json
      )
    end
  end
end
