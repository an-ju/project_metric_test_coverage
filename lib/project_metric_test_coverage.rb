require "project_metric_test_coverage/version"
require 'project_metric_test_coverage/test_generator'
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
    refresh unless @raw_data

    { chartType: 'test_coverage',
      data: {
        coverage_link: @p['links']['web_coverage'],
        report: @report,
        least_covered: least_covered,
        lowest_strength: lowest_strength
      }
    }.to_json
  end

  def commit_sha
    refresh unless @raw_data

    @report['attributes']['commit_sha']
  end

  def score
    refresh unless @raw_data
    @report['attributes']['rating']['measure']['value']
  end

  def raw_data=(new)
    @raw_data = new
    @score = @image = nil
  end

  def refresh
    set_project
    set_report
    set_file_coverages
    @raw_data = { project: @p, report: @report }.to_json
    @score = @image = nil
    true
  end

  def self.credentials
    %I[github_project codeclimate_token]
  end

  private

  def set_project
    @p = JSON.parse(@conn.get('repos', github_slug: @identifier).body)['data'].last
  end

  def set_report
    @report = JSON.parse(@conn.get("repos/#{@p['id']}/test_reports").body)['data'][0]
  end

  def set_file_coverages
    @file_reports = []
    next_page = "repos/#{@p['id']}/test_reports/#{@report['id']}/test_file_reports"
    resp = JSON.parse(@conn.get(next_page, page: { size: 100 }).body)
    @file_reports += resp['data']
    next_page = resp['links']['next']
    get_next_page(next_page)
  end

  def least_covered
    @file_reports.sort_by { |f| f['attributes']['covered_percent'] }.first(5)
  end

  def lowest_strength
    @file_reports.select { |f| f['attributes']['covered_strength'] > 0 }
                 .sort_by { |f| f['attributes']['covered_strength'] }.first(5)
  end

  def get_next_page(next_page)
    while next_page
      resp = Faraday.get do |req|
        req.url next_page
        req.headers['Content-Type'] = 'application/vnd.api+json'
        req.headers['Authorization'] = @conn.headers['Authorization']
      end
      resp = JSON.parse(resp.body)
      @file_reports += resp['data']
      next_page = resp['links']['next']
    end
  end

end
