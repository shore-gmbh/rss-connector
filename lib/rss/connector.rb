require 'httparty'
require 'net/http'

module RSS
  # Utility class encapsulating synchronous communication with RSS.
  class Connector # rubocop:disable ClassLength
    include HTTParty

    base_uri RSS.configuration.base_uri

    BASIC_AUTH_USERNAME    = (RSS.configuration.secret || 'secret').freeze
    BASIC_AUTH_PASSWORD    = ''.freeze
    BASIC_AUTH_CREDENTIALS = {
      basic_auth: {
        username: BASIC_AUTH_USERNAME,
        password: BASIC_AUTH_PASSWORD
      }
    }.freeze

    attr_reader :oid, :scope

    # @param oid [String] Organziation ID
    # @param scope [String]
    def initialize(oid, scope)
      @oid   = oid
      @scope = scope
    end

    # @param series_id [String]
    # @raise [RuntimeError] RSS request failed
    def get_series(series_id)
      path = "#{base_path}/series/#{series_id}"
      response = self.class.authenticated_get(path)

      case response.code
      when 200 then JSON.parse(response.body)['series']
      when 404 then nil
      else fail "RSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def create_series(attributes = {})
      path = "#{base_path}/series"
      response = self.class.authenticated_post(
        path, query: prepare_series_attributes(attributes)
      )

      case response.code
      when 201 then JSON.parse(response.body)
      else fail "RSS: 'POST #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def create_or_update_series(series_id, attributes = {})
      path = "#{base_path}/series/#{series_id}"
      response = self.class.authenticated_put(
        path, query: prepare_series_attributes(attributes)
      )

      case response.code
      when 200, 201 then JSON.parse(response.body)
      else fail "RSS: 'PUT #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def update_series(series_id, attributes = {})
      path = "#{base_path}/series/#{series_id}"
      response = self.class.authenticated_patch(
        path, query: prepare_series_attributes(attributes)
      )

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'PATCH #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def delete_series(series_id)
      path = "#{base_path}/series/#{series_id}"
      response = self.class.authenticated_delete(path)

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'DELETE #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def get_rule(rule_id)
      path = "#{base_path}/rules/#{rule_id}"
      response = self.class.authenticated_get(path)

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def get_rules(filters = {})
      path = "#{base_path}/rules"
      response = self.class.authenticated_get(
        path, query: sanitize_filters(filters)
      )

      case response.code
      when 200 then JSON.parse(response.body)['rules']
      when 404 then nil
      else fail "RSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def create_rule(attributes = {})
      path = "#{base_path}/rules"
      response = self.class.authenticated_post(
        path, query: prepare_rule_attributes(attributes)
      )

      case response.code
      when 201 then JSON.parse(response.body)
      else fail "RSS: 'POST #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def create_or_update_rule(rule_id, attributes = {})
      path = "#{base_path}/rules/#{rule_id}"
      response = self.class.authenticated_put(
        path, query: prepare_rule_attributes(attributes)
      )

      case response.code
      when 200, 201 then JSON.parse(response.body)
      else fail "RSS: 'PUT #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def update_rule(rule_id, attributes = {})
      path = "#{base_path}/rules/#{rule_id}"
      response = self.class.authenticated_patch(
        path, query: prepare_rule_attributes(attributes)
      )

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'PATCH #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def delete_rule(rule_id)
      path = "#{base_path}/rules/#{rule_id}"
      response = self.class.authenticated_delete(path)

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'DELETE #{path}' failed with status = #{response.code}."
      end
    end

    # @raise [RuntimeError] RSS request failed
    def get_occurrences(filters = {}) # rubocop:disable MethodLength
      path = "#{base_path}/occurrences"
      response = self.class.authenticated_get(
        path, query: sanitize_filters(filters)
      )

      case response.code
      when 200
        (JSON.parse(response.body)['occurrences'] || []).map do |h|
          build_occurrence_payload(h)
        end
      else fail "RSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end

    # @param occurrence_id [String]
    # @raise [RuntimeError] RSS request failed
    def get_occurrence(occurrence_id)
      path = "#{base_path}/occurrences/#{occurrence_id}"
      response = self.class.authenticated_get(path)

      case response.code
      when 200
        occurrence_hash = JSON.parse(response.body)['occurrence']
        build_occurrence_payload(occurrence_hash)
      when 404 then nil
      else fail "RSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end

    # @param occurrence_id [String]
    # @raise [RuntimeError] RSS request failed
    # rubocop:disable MethodLength
    def update_occurrence(occurrence_id, attributes = {})
      path = "#{base_path}/occurrences/#{occurrence_id}"
      response = self.class.authenticated_patch(
        path, query: prepare_occurrence_attributes(attributes)
      )

      case response.code
      when 200
        occurrence_hash = JSON.parse(response.body)['occurrence']
        build_occurrence_payload(occurrence_hash)
      when 404 then nil
      else fail "RSS: 'PATCH #{path}' failed with status = #{response.code}."
      end
    end

    # @param occurrence_id [String]
    # @raise [RuntimeError] RSS request failed
    def delete_occurrence(occurrence_id)
      path = "#{base_path}/occurrences/#{occurrence_id}"
      response = self.class.authenticated_delete(path)

      case response.code
      when 200 then JSON.parse(response.body)
      when 404 then nil
      else fail "RSS: 'DELETE #{path}' failed with status = #{response.code}."
      end
    end

    private

    # Define variants of all HTTParty request methods with authentication
    # support.
    self::Request::SupportedHTTPMethods
      .map { |x| x.name.demodulize.downcase }.each do |method|
      define_singleton_method("authenticated_#{method}") do |path, options = {}|
        send(method, path, options.merge(BASIC_AUTH_CREDENTIALS))
      end
    end

    def base_path
      "/v1/#{oid}/#{scope}"
    end

    # @param series_attributes [Hash]
    # @return [Hash]
    def prepare_series_attributes(series_attributes = {})
      (series_attributes || {}).tap do |attributes|
        attributes[:rules] ||= []

        attributes[:rules].map! do |rule_attributes|
          prepare_rule_attributes(rule_attributes, series_attributes)
        end
      end
    end

    # @param rule_attributes [Hash]
    # @return [Hash]
    def prepare_rule_attributes(rule_attributes = {}, series_attributes = nil)
      {}.tap do |attrs|
        rule = Rule.new(rule_attributes)

        attrs[:id] = rule.id # core is always creating the rule id now
        attrs[:recurrence] = rule.recurrence

        if series_attributes
          attrs[:duration] = series_attributes[:duration] || rule.duration
          attrs[:time_zone] = series_attributes[:time_zone]
        end
      end
    end

    # @param occurrence_attributes [Hash]
    # @return [Hash]
    def prepare_occurrence_attributes(occurrence_attributes = {})
      {}.tap do |attrs|
        if occurrence_attributes[:starts_at].present?
          attrs[:starts_at] = iso8601_param(occurrence_attributes[:starts_at])
        end

        if occurrence_attributes[:ends_at].present?
          attrs[:ends_at] = iso8601_param(occurrence_attributes[:ends_at])
        end
      end
    end

    def sanitize_filters(filters = {})
      filters.tap do |f|
        if f[:interval_starts_at].present?
          f[:interval_starts_at] = iso8601_param(f[:interval_starts_at])
        end

        if f[:interval_ends_at].present?
          f[:interval_ends_at] = iso8601_param(f[:interval_ends_at])
        end
      end
    end

    def iso8601_param(p)
      p.respond_to?(:iso8601) ? p.iso8601 : p.to_s
    end

    # @param occurrence_hash [Hash]
    def build_occurrence_payload(occurrence_hash)
      occurrence_hash.tap do |p|
        p['starts_at'] = Time.zone.parse(p['starts_at']) if p['starts_at']
        p['ends_at']   = Time.zone.parse(p['ends_at'])   if p['ends_at']
      end if occurrence_hash
    end
  end
end
