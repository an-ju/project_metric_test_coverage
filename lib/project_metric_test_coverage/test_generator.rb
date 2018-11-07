class ProjectMetricTestCoverage
  def self.fake_data
    [_test_data(10.0), _test_data(70.0), _test_data(90.0)]
  end

  def self._test_data(value)
    { image: _test_image(value), score: 100.0-value }
  end

  def self._test_image(value)
    { chartType: 'test_coverage',
      data:
          { report:
                {
                    id: "596ad7629c5b3756bc000003",
                    type: "test_reports",
                    attributes: {
                        branch: "master",
                        commit_sha: "cd3811626d5f723130417735d10a132f285795cc",
                        committed_at: "2017-07-16T02:55:52.000Z",
                        covered_percent: value,
                        rating: {
                            path: "/",
                            letter: _test_letter(value),
                            measure: {
                                value: value,
                                unit: "percent"
                            },
                            pillar: "Test Coverage"
                        },
                        received_at: "2018-09-06T20:25:28.098Z",
                        state: "done"
                    }
                },
            least_covered:
                [
                    {
                        id: "596ad7622df1731de500015e",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, 4, null, 4, null, 4, 6, 2, null, 2, null, null, null, 1, null, null, 1, null, null, 4, 6, 3, null, 3, null, 3, 2, 2, null, 1, null, null, null, 4, null, 4, 6, null, null, 4, null, null, 3, null, null, 4, 2, 2, 2, null, 2, null, null, null, null, null, null, 4, 2, 1, null, 1, null, null, null, null],
                            covered_percent: 10,
                            covered_strength: 3.0606060606061,
                            path: "lib/book.rb",
                            line_counts: {
                                missed: 0,
                                covered: 33,
                                total: 33
                            }
                        }
                    },
                    {
                        id: "596ad7622df1731de5000147",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, null, 4, null, 4, 12, 5, null, 5, 1, null, null, 4, 1, null, null, 3, 1, null, null, 2, 2, null, null, 4, null, 4, 1, 1, null, null, 4, 1, null, null, null, null, null, 4, 1, null, null, null, null, null, 4, 2, null, 2, null, null, null, 4, 24, null, null, 4, 1, 1, null, null, null, null, 1, null, null, 4, 5, null, null, null],
                            covered_percent: 12,
                            covered_strength: 3.7647058823529,
                            path: "lib/group.rb",
                            line_counts: {
                                missed: 0,
                                covered: 34,
                                total: 34
                            }
                        }
                    },
                    {
                        id: "596ad762e13a1a6a9d0000a8",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, null, 4, null, 4, 4, 6, null, 2, null, null, null],
                            covered_percent: 13,
                            covered_strength: 4,
                            path: "lib/user.rb",
                            line_counts: {
                                missed: 0,
                                covered: 8,
                                total: 8
                            }
                        }
                    }
                ],
            lowest_strength:
                [
                    {
                        id: "596ad7622df1731de500015e",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, 4, null, 4, null, 4, 6, 2, null, 2, null, null, null, 1, null, null, 1, null, null, 4, 6, 3, null, 3, null, 3, 2, 2, null, 1, null, null, null, 4, null, 4, 6, null, null, 4, null, null, 3, null, null, 4, 2, 2, 2, null, 2, null, null, null, null, null, null, 4, 2, 1, null, 1, null, null, null, null],
                            covered_percent: 10,
                            covered_strength: 3.0606060606061,
                            path: "lib/book.rb",
                            line_counts: {
                                missed: 0,
                                covered: 33,
                                total: 33
                            }
                        }
                    },
                    {
                        id: "596ad7622df1731de5000147",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, null, 4, null, 4, 12, 5, null, 5, 1, null, null, 4, 1, null, null, 3, 1, null, null, 2, 2, null, null, 4, null, 4, 1, 1, null, null, 4, 1, null, null, null, null, null, 4, 1, null, null, null, null, null, 4, 2, null, 2, null, null, null, 4, 24, null, null, 4, 1, 1, null, null, null, null, 1, null, null, 4, 5, null, null, null],
                            covered_percent: 12,
                            covered_strength: 3.7647058823529,
                            path: "lib/group.rb",
                            line_counts: {
                                missed: 0,
                                covered: 34,
                                total: 34
                            }
                        }
                    },
                    {
                        id: "596ad762e13a1a6a9d0000a8",
                        type: "test_file_reports",
                        attributes: {
                            coverage: [4, 4, 4, null, 4, null, 4, 4, 6, null, 2, null, null, null],
                            covered_percent: 13,
                            covered_strength: 4,
                            path: "lib/user.rb",
                            line_counts: {
                                missed: 0,
                                covered: 8,
                                total: 8
                            }
                        }
                    }
                ],
            coverage_link: 'https://codeclimate.com/github/an-ju/projectscope/issues' } }.to_json
  end

  def self._test_letter(value)
    if value > 80.0
      'A'
    elsif value > 60.0
      'B'
    elsif value > 30.0
      'C'
    else
      'D'
    end
  end

  def self.null
    nil
  end
end