require "project_metric_test_coverage/version"
require 'faraday'
require 'open-uri'
require 'date'
require 'json'

class ProjectMetricTestCoverage

  attr_reader :raw_data

  def initialize(credentials = {}, raw_data = nil)
    @project_url = credentials[:github_project]
    @identifier = URI.parse(@project_url).path[1..-1]

    @conn = Faraday.new(url: 'https://api.codeclimate.com/v1')
    @conn.headers['Content-Type'] = 'application/vnd.api+json'
    @conn.headers['Authorization'] = "Token token=#{credentials[:codeclimate_token]}"
    set_project_id
    @raw_data = raw_data
  end

  def image
    @raw_data ||= test_reports
    @image ||= { chartType: 'test_coverage_v2', data: @raw_data['data'], titleText: 'Test Coverage' }.to_json
  end

  def score
    @raw_data ||= test_reports
    raw_data = @raw_data['data']
    @score ||= raw_data.first.nil? ? 0.0 : raw_data.first['attributes']['covered_percent']
  end

  def raw_data=(new)
    @raw_data = new
    @score = @image = nil
  end

  def refresh
    @raw_data = test_reports
    @score = @image = nil
    true
  end

  def self.credentials
    %I[github_project codeclimate_token]
  end

  private

  def set_project_id
    @project_id = JSON.parse(@conn.get("repos?github_slug=#{@identifier}").body)['data'][0]['id']
  end

  def test_reports
    JSON.parse(@conn.get("repos/#{@project_id}/test_reports").body)
  end

end
