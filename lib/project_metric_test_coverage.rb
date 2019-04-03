require "project_metric_test_coverage/version"
require 'project_metric_test_coverage/test_generator'
require 'faraday'
require 'open-uri'
require 'date'
require 'json'

require 'project_metric_base'

class ProjectMetricTestCoverage
  include ProjectMetricBase

  add_credentials %I[github_project codeclimate_token]
  add_raw_data %w[codeclimate_project codeclimate_report codeclimate_file_coverage]


  def initialize(credentials = {}, raw_data = nil)
    @project_url = credentials[:github_project]
    @identifier = URI.parse(@project_url).path[1..-1]

    @conn = Faraday.new(url: 'https://api.codeclimate.com/v1')
    @conn.headers['Content-Type'] = 'application/vnd.api+json'
    @conn.headers['Authorization'] = "Token token=#{credentials[:codeclimate_token]}"

    complete_with raw_data
  end

  def image
    if @codeclimate_project.nil?
      return { chartType: 'error_message',
               message: "Cannot find project #{@identifier}." }
    end
    if @codeclimate_report.nil?
      return { chartType: 'error_message',
               message: "No test report found for #{@identifier}." }
    end

    { chartType: 'test_coverage',
      data: {
        coverage_link: @codeclimate_project['links']['web_coverage'],
        report: @codeclimate_report,
        least_covered: least_covered,
        lowest_strength: lowest_strength } }
  end

  def obj_id
    @codeclimate_report['attributes']['commit_sha']
  end

  def score
    return -1 if @codeclimate_report.nil?

    @codeclimate_report['attributes']['covered_percent']
  end

  private

  def codeclimate_project
    @codeclimate_project = JSON.parse(@conn.get('repos', github_slug: @identifier).body)['data'].last
  end

  def codeclimate_report
    if @codeclimate_project.nil?
      @codeclimate_report = nil
    else
      @codeclimate_report = JSON.parse(@conn.get("repos/#{@codeclimate_project['id']}/test_reports").body)['data'].first
    end
  end

  def codeclimate_file_coverage
    if @codeclimate_report.nil?
      @codeclimate_file_coverage = nil
      return
    end

    @codeclimate_file_coverage = []
    next_page = "repos/#{@codeclimate_project['id']}/test_reports/#{@codeclimate_report['id']}/test_file_reports"
    resp = JSON.parse(@conn.get(next_page, page: { size: 100 }).body)
    @codeclimate_file_coverage += resp['data']
    next_page = resp['links']['next']
    get_next_page(next_page)
    @codeclimate_file_coverage
  end

  def least_covered
    @codeclimate_file_coverage.sort_by { |f| f['attributes']['covered_percent'] }.first(5)
  end

  def lowest_strength
    @codeclimate_file_coverage.select { |f| f['attributes']['covered_strength'] > 0 }
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
      @codeclimate_file_coverage += resp['data']
      next_page = resp['links']['next']
    end
  end

end
