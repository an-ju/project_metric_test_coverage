require "project_metric_test_coverage/version"
require 'nokogiri'
require 'open-uri'
require 'json'

class ProjectMetricTestCoverage

  attr_reader :raw_data

  def initialize credentials = {}, raw_data = nil
    @identifier = "github#{URI::parse(credentials[:github_project]).path}"
    @raw_data = raw_data
  end

  def image
    @raw_data ||= remote_data
    @image ||= { chartType: 'test_coverage', data: @raw_data, titleText: 'Test Coverage' }.to_json
  end

  def score
    @raw_data ||= remote_data
    @score ||= @raw_data['GPA']
  end

  def raw_data=(new)
    @raw_data = new
    @score = @image = nil
  end

  def refresh
    @raw_data = remote_data
    @score = @image = nil
    true
  end

  def self.credentials
    %I[github_project]
  end

  private

  def remote_data
    page = Nokogiri::HTML(open("https://codeclimate.com/#{@identifier}"))
    # page = Nokogiri::HTML(open("https://codeclimate.com/github/hrzlvn/coursequestionbank"))

    raw_data = page.css('div.repos-show__overview-summary-number')
    { GPA: raw_data[0].text[/\d.+/], issues: raw_data[1].text[/\d+/], coverage: raw_data[2].text[/\d+/] }
  end

end
