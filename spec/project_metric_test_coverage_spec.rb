require "spec_helper"

RSpec.describe ProjectMetricTestCoverage do
  before :each do
    stub_request(:get, "https://api.codeclimate.com/v1/repos?github_slug=an-ju/teamscope")
      .to_return(body: File.read('spec/data/project.json'))
    stub_request(:get, "https://api.codeclimate.com/v1/repos/696a76232df2736347000001/test_reports")
      .to_return(body: File.read('spec/data/reports.json'))
    stub_request(:get, "https://api.codeclimate.com/v1/repos/696a76232df2736347000001/test_reports/596ad7629c5b3756bc000003/test_file_reports?page%5Bsize%5D=100")
      .to_return(body: File.read('spec/data/page1.json'))
    stub_request(:get, "https://api.codeclimate.com/v1/repos/696a76232df2736347000001/test_reports/596ad7629c5b3756bc000003/test_file_reports?page%5Bnumber%5D=2&page%5Bsize%5D=3")
      .to_return(body: File.read('spec/data/page2.json'))
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
    image = project_metric_test_coverage.image
    expect(image).to have_key(:data)
    expect(image[:data][:report]['id']).to eql("596ad7629c5b3756bc000003")
  end

  it 'has correctly sorted files' do
    image = project_metric_test_coverage.image
    expect(image[:data][:least_covered].first['id']).to eql('596ad7622df1731de5000152')
    expect(image[:data][:lowest_strength].first['id']).to eql('596ad7622df1731de500015e')
  end

  it 'has non-empty file_coverage' do
    expect(project_metric_test_coverage.instance_variable_get('@codeclimate_file_coverage')).to be_a(Array)
  end

  it 'has the proper commit_sha' do
    expect(project_metric_test_coverage.obj_id).to eql('cd3811626d5f723130417735d10a132f285795cc')
  end

  context 'data generator' do
    it 'generates an array of data' do
      expect(described_class.fake_data).to be_a(Array)
    end

    it 'sets data properly' do
      data_item = described_class.fake_data.first
      expect(data_item).to have_key(:score)
      expect(data_item).to have_key(:image)
    end

    it 'sets image properly' do
      image_data = described_class.fake_data.first[:image]
      expect(image_data).to be_a(Hash)
      expect(image_data[:chartType]).to be_a(String)
      expect(image_data[:data]).to be_a(Hash)
    end

  end

end
