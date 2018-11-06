require "spec_helper"

RSpec.describe ProjectMetricTestCoverage do
  before :each do
    @conn = double('conn')
    project_resp = double('project')
    allow(project_resp).to receive(:body) { File.read './spec/data/project.json' }
    report_resp = double('report')
    allow(report_resp).to receive(:body) { File.read './spec/data/reports.json' }
    file_resp_1 = double('file1')
    allow(file_resp_1).to receive(:body) { File.read './spec/data/page1.json' }
    file_resp_2 = double('file2')
    allow(file_resp_2).to receive(:body) { File.read './spec/data/page2.json' }

    allow(Faraday).to receive(:new).and_return(@conn)
    allow(@conn).to receive(:headers).and_return({})
    allow(@conn).to receive(:get).with('repos', github_slug: 'an-ju/teamscope').and_return(project_resp)
    allow(@conn).to receive(:get).with('repos/696a76232df2736347000001/test_reports').and_return(report_resp)
    allow(@conn).to receive(:get).with('repos/696a76232df2736347000001/test_reports/596ad7629c5b3756bc000003/test_file_reports', { page: { size: 100 } }).and_return(file_resp_1)
    allow(Faraday).to receive(:get).and_return(file_resp_2)
  end

  subject(:project_metric_test_coverage) do
    described_class.new(github_project: 'https://github.com/an-ju/teamscope', code_climate_token: 'token')
  end

  it "has a version number" do
    expect(ProjectMetricTestCoverage::VERSION).not_to be nil
  end

  it 'has the corresponding score value' do
    expect(project_metric_test_coverage.score).to eq(84.946657957762)
  end

  it 'has the proper image' do
    image = JSON.parse(project_metric_test_coverage.image)
    expect(image).to have_key('data')
    expect(image['data']['report']['id']).to eql("596ad7629c5b3756bc000003")
  end

  it 'has correctly sorted files' do
    image = JSON.parse(project_metric_test_coverage.image)
    expect(image['data']['least_covered'].first['id']).to eql('596ad7622df1731de5000152')
    expect(image['data']['lowest_strength'].first['id']).to eql('596ad7622df1731de500015e')
  end

  it 'has the proper commit_sha' do
    expect(project_metric_test_coverage.commit_sha).to eql('cd3811626d5f723130417735d10a132f285795cc')
  end

  it 'generates test files' do
    expect(ProjectMetricTestCoverage.fake_data.length).to eql(3)
  end

end
