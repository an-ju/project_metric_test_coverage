require "project_metric_test_coverage/version"
require 'faraday'
require 'open-uri'
require 'date'
require 'json'

class ProjectMetricTestCoverage

  attr_reader :raw_data, :coverage_reports

  def initialize(credentials = {}, raw_data = nil)
    @project_url = credentials[:github_project]
    @identifier = URI.parse(@project_url).path[1..-1]

    @conn = Faraday.new(url: 'https://api.codeclimate.com/v1')
    @conn.headers['Content-Type'] = 'application/vnd.api+json'
    @conn.headers['Authorization'] = "Token token=#{credentials[:codeclimate_token]}"

    @raw_data = raw_data
  end

  def image
    @raw_data ||= project
    p = @raw_data['data'].last
    badge_link = p['links']['test_coverage_badge']
    @coverage_reports ||= test_reports p['id']
    @image ||= { chartType: 'test_coverage_v2',
                 titleText: 'Test Coverage',
                 data: {
                   test_badge: open(badge_link).read,
                   coverage: @coverage_reports
                 } }.to_json
  end

  def score
    @raw_data ||= project
    p = @raw_data['data'].last
    @coverage_reports ||= test_reports p['id']
    @score ||= @coverage_reports['data'].first.nil? ? -1 : @coverage_reports['data'].first['attributes']['covered_percent']
  end

  def raw_data=(new)
    @raw_data = new
    @score = @image = nil
  end

  def refresh
    @raw_data = project
    @score = @image = nil
    true
  end

  def self.credentials
    %I[github_project codeclimate_token]
  end

  private

  def project
    JSON.parse(@conn.get("repos?github_slug=#{@identifier}").body)
  end

  def test_reports(pid)
    JSON.parse(@conn.get("repos/#{pid}/test_reports").body)
  end

end
