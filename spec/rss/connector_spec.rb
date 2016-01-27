require 'spec_helper'

describe RSS::Connector do
  let(:oid)     { 'shore' }
  let(:scope)   { 'appointment' }
  let(:fake_id) { SecureRandom.uuid }

  subject { described_class.new(oid, scope) }

  def mock_created(body = '{}')
    double('Resource Created', code: 201, body: body)
  end

  def mock_success(body = '{}')
    double('Successful Response', code: 200, body: body)
  end

  def mock_server_error
    double('Internal Server Error', code: 500)
  end

  def mock_not_found
    double('Not Found', code: 404)
  end

  describe '#get_series' do
    it 'sends a GET request to /v1/:oid/:scope/series/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success('{"series":{}}'))

      expect(subject.get_series(fake_id)).to eq({})
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_series(fake_id)).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_series(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_series' do
    it 'sends a POST request to /v1/:oid/:scope/series' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/series", options)
        .and_return(mock_created('{}'))

      expect(subject.create_series).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: {
          rules: [
            hash_including(recurrence: hash_including(starts_at: t.utc.iso8601))
          ]
        }
      )

      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/series", options)
        .and_return(mock_created('{}'))

      subject.create_series(rules: [recurrence: { starts_at: t }])
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: {
          rules: [
            hash_including(recurrence: hash_including(ends_at: t.utc.iso8601))
          ]
        }
      )

      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/series", options)
        .and_return(mock_created('{}'))

      subject.create_series(rules: [recurrence: { ends_at: t }])
    end

    it 'raises an error if the RSS responds with code != 201' do
      expect(described_class).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_series
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_or_update_series' do
    it 'sends the rule id' do
      rule = RSS::Rule.new(starts_at: 1.week.from_now, count: 1)
      options = hash_including(
        query: hash_including(
          rules: [hash_including(id: rule.id)]
        )
      )

      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      expect(
        subject.create_or_update_series(
          fake_id, rules: [rule].as_json
        )
      ).to eq({})
    end

    it 'sends a PUT request to /v1/:oid/:scope/series/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.create_or_update_series(fake_id)).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(
          rules: [hash_including(recurrence: { starts_at: t.utc.iso8601 })
        ]
        )
      )

      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      subject.create_or_update_series(
        fake_id, rules: [recurrence: { starts_at: t }]
      )
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(
          rules: [hash_including(recurrence: { ends_at: t.utc.iso8601 })]
        )
      )

      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      subject.create_or_update_series(
        fake_id, rules: [recurrence: { ends_at: t }]
      )
    end

    it 'raises an error if the RSS responds with code != 200 and != 201' do
      expect(described_class).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_or_update_series(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#update_series' do
    it 'sends a PATCH request to /v1/:oid/:scope/series/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.update_series(fake_id)).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: {
          rules: [
            hash_including(recurrence: hash_including(starts_at: t.utc.iso8601))
          ]
        },
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      subject.update_series(
        fake_id, rules: [recurrence: { starts_at: t }]
      )
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: {
          rules: [
            hash_including(recurrence: hash_including(ends_at: t.utc.iso8601))
          ]
        }
      )

      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      subject.update_series(
        fake_id, rules: [recurrence: { ends_at: t }]
      )
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:patch)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.update_series(fake_id)).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:patch)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_series(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#delete_series' do
    it 'sends a DELETE request to /v1/:oid/:scope/series/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:delete)
        .with("/v1/#{oid}/#{scope}/series/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.delete_series(fake_id)).to eq({})
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:delete)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.delete_series(fake_id)).to be_nil
    end
  end

  describe '#get_rule' do
    it 'sends a GET request to /v1/:oid/:scope/rules/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.get_rule(fake_id)).to eq({})
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_rule(fake_id)).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_rule(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_rule' do
    it 'sends a POST request to /v1/:oid/:scope/rules' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/rules", options)
        .and_return(double('response', code: 201, body: '{}'))

      expect(subject.create_rule).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(
          recurrence: hash_including(starts_at: t.utc.iso8601)
        )
      )

      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/rules", options)
        .and_return(double('response', code: 201, body: '{}'))

      subject.create_rule(recurrence: { starts_at: t })
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(recurrence: { ends_at: t.utc.iso8601 })
      )

      expect(described_class).to receive(:post)
        .with("/v1/#{oid}/#{scope}/rules", options)
        .and_return(double('response', code: 201, body: '{}'))

      subject.create_rule(recurrence: { ends_at: t })
    end

    it 'raises an error if the RSS responds with code != 201' do
      expect(described_class).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_rule
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_or_update_rule' do
    it 'sends a PUT request to /v1/:oid/:scope/rules/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      expect(
        subject.create_or_update_rule(fake_id)
      ).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(recurrence: { starts_at: t.utc.iso8601 })
      )

      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      subject.create_or_update_rule(
        fake_id, recurrence: { starts_at: t }
      )
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(recurrence: { ends_at: t.utc.iso8601 })
      )

      expect(described_class).to receive(:put)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      subject.create_or_update_rule(
        fake_id, recurrence: { ends_at: t }
      )
    end

    it 'raises an error if the RSS responds with code != 200 and != 201' do
      expect(described_class).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_or_update_rule(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#update_rule' do
    it 'sends a PATCH request to /v1/:oid/:scope/rules/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.update_rule(fake_id)).to eq({})
    end

    it 'converts the attribute "starts_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(
          recurrence: hash_including(starts_at: t.utc.iso8601)
        ),
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      subject.update_rule(
        fake_id, recurrence: { starts_at: t }
      )
    end

    it 'converts the attribute "ends_at" to UTC ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(
          recurrence: hash_including(ends_at: t.utc.iso8601)
        )
      )

      expect(described_class).to receive(:patch)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      subject.update_rule(
        fake_id, recurrence: { ends_at: t }
      )
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:patch)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.update_rule(fake_id)).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:patch)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_rule(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#delete_rule' do
    it 'sends a DELETE request to /v1/:oid/:scope/rules/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:delete)
        .with("/v1/#{oid}/#{scope}/rules/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.delete_rule(fake_id)).to eq({})
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:delete)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.delete_rule(fake_id)).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:delete)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.delete_rule(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_rules' do
    it 'sends a GET request to /v1/:oid/:scope/rules' do
      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/rules", anything)
        .and_return(mock_success({ rules: [] }.to_json))

      expect(subject.get_rules).to eq([])
    end

    context 'stubbed response' do
      let(:rule) { RSS::Rule.new(starts_at: 1.day.from_now) }
      let(:rule_id) { rule.id }

      it 'returns the rules json array' do
        expect(described_class).to receive(:get)
          .with("/v1/#{oid}/#{scope}/rules", anything)
          .and_return(mock_success({ rules: [rule] }.to_json))

        rules = subject.get_rules

        expect(rules).to be_a(Array)
        expect(rules.size).to eq(1)
        expect(rules.first).to match(
          a_hash_including(
            'id' => rule_id
          )
        )
      end
    end

    it 'converts the filter "interval_starts_at" to ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(interval_starts_at: t.iso8601),
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/rules", options)
        .and_return(mock_success)

      subject.get_rules(interval_starts_at: t)
    end

    it 'converts the filter "interval_ends_at" to ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(interval_ends_at: t.iso8601),
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/rules", options)
        .and_return(mock_success)

      subject.get_rules(interval_ends_at: t)
    end
  end

  describe '#get_occurrences' do
    it 'sends a GET request to /v1/:oid/:scope/occurrences' do
      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/occurrences", anything)
        .and_return(mock_success)

      expect(subject.get_occurrences).to eq([])
    end

    context 'stubbed response' do
      let(:occurrence) do
        {
          'id' => SecureRandom.uuid,
          'series_id' => SecureRandom.uuid,
          'starts_at' => '2010-01-01T00:00:00.000Z',
          'ends_at' => '2010-01-01T00:59:59.000Z'
        }
      end

      it 'converts starts_at and ends_at to Time objects' do
        expect(described_class).to receive(:get)
          .with("/v1/#{oid}/#{scope}/occurrences", anything)
          .and_return(mock_success({ occurrences: [occurrence] }.to_json))

        expect(subject.get_occurrences).to match_array(
          [
            a_hash_including(
              'starts_at' => Time.zone.parse('2010-01-01T00:00:00.000Z'),
              'ends_at' => Time.zone.parse('2010-01-01T00:59:59.000Z')
            )
          ]
        )
      end
    end

    it 'converts the filter "interval_starts_at" to ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(interval_starts_at: t.iso8601),
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/occurrences", options)
        .and_return(mock_success)

      subject.get_occurrences(interval_starts_at: t)
    end

    it 'converts the filter "interval_ends_at" to ISO8601' do
      t = Time.zone.now
      options = hash_including(
        query: hash_including(interval_ends_at: t.iso8601),
        basic_auth: an_instance_of(Hash)
      )

      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/occurrences", options)
        .and_return(mock_success)

      subject.get_occurrences(interval_ends_at: t)
    end

    it 'raises an error if the RSS responds with code != 200' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_occurrences
      end.to raise_error(RuntimeError)
    end

    context 'with occurrences' do
      let(:occurrences) do
        {
          occurrences: [
            {
              id: '21cb4078-0a3f-47c7-8589-2c71aa0f353f',
              series_id: '11cb4078-0a3f-47c7-8589-2c71aa0f353f',
              starts_at: '2015-06-27T10:00:00Z',
              ends_at: '2015-06-27T10:59:59Z'
            }
          ]
        }
      end

      let(:occurrences_response)do
        double('response', code: 200, body: occurrences.to_json)
      end

      it 'sends a GET request to /v1/:oid/:scope/occurrences' do
        expect(described_class).to receive(:get)
          .with("/v1/#{oid}/#{scope}/occurrences", anything)
          .and_return(occurrences_response)

        expect(subject.get_occurrences).to eq(
          occurrences[:occurrences].map(&:stringify_keys)
        )
      end
    end
  end

  describe '#get_occurrence' do
    it 'sends a GET request to /v1/:oid/:scope/occurrences/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:get)
        .with("/v1/#{oid}/#{scope}/occurrences/#{fake_id}", options)
        .and_return(
          mock_success(
            { occurrence: { starts_at: Time.zone.local(2015) } }.to_json
          )
        )

      expect_any_instance_of(described_class).to receive(
        :build_occurrence_payload
      ).and_call_original

      expect(subject.get_occurrence(fake_id)).to(
        eq('starts_at' => Time.zone.local(2015))
      )
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(
        subject.get_occurrence(fake_id)
      ).to be_nil
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_occurrence(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#update_occurrence' do
    let(:t) { Time.zone.now }

    it 'sends a PATCH request to /v1/:oid/:scope/occurrences/:id' do
      occurrence_response = {
        occurrence: {
          starts_at: Time.zone.local(2015, 1),
          ends_at: Time.zone.local(2015, 2)
        }
      }.to_json

      expect(described_class).to receive(:authenticated_patch)
        .with("/v1/#{oid}/#{scope}/occurrences/#{fake_id}", anything)
        .and_return(mock_success(occurrence_response))

      expect_any_instance_of(described_class).to receive(
        :build_occurrence_payload
      ).and_call_original

      expect(subject.update_occurrence(fake_id)).to eq(
        'starts_at' => Time.zone.local(2015, 1),
        'ends_at' => Time.zone.local(2015, 2)
      )
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:authenticated_patch)
        .with(any_args)
        .and_return(mock_not_found)

      expect(
        subject.update_occurrence(fake_id)
      ).to be_nil
    end

    it 'converts the attribute "starts_at" to ISO8601' do
      options = { query: hash_including(starts_at: t.iso8601) }

      expect(described_class).to receive(:authenticated_patch)
        .with("/v1/#{oid}/#{scope}/occurrences/#{fake_id}", options)
        .and_return(mock_success('{}'))

      subject.update_occurrence(fake_id, starts_at: t)
    end

    it 'converts the attribute "ends_at" to ISO8601' do
      options = { query: hash_including(ends_at: t.iso8601) }

      expect(described_class).to receive(:authenticated_patch)
        .with("/v1/#{oid}/#{scope}/occurrences/#{fake_id}", options)
        .and_return(mock_success('{}'))

      subject.update_occurrence(fake_id, ends_at: t)
    end

    it 'raises an error if the RSS responds with code != 200 and != 404' do
      expect(described_class).to receive(:authenticated_patch)
        .with(any_args).and_return(mock_server_error)

      expect do
        subject.update_occurrence(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#delete_occurrence' do
    it 'sends a DELETE request to /v1/:oid/:scope/occurrences/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(described_class).to receive(:delete)
        .with("/v1/#{oid}/#{scope}/occurrences/#{fake_id}", options)
        .and_return(mock_success)

      expect(subject.delete_occurrence(fake_id)).to eq({})
    end

    it 'returns nil if the RSS responds with code 404' do
      expect(described_class).to receive(:delete)
        .and_return(mock_not_found)
      expect(subject.delete_occurrence(fake_id)).to be_nil
    end
  end
end
