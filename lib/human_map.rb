require 'yaml'
require 'json'
require 'erb'

class HumanMap
  def initialize(title_image_base64)
    @data = load_data
    @start_year = -100  # BC100年から
    @end_year = 2024    # 現代まで
    @century_step = 100 # 100年ごとの区切り
    @px_per_century = 300 # 1世紀あたりのピクセル数
    @bar_padding = 20 # バーの左右のパディング合計（10px × 2）
    @title_image_base64 = title_image_base64
  end

  def generate
    template = File.read(File.join(__dir__, '../templates/index.html.erb'))
    renderer = ERB.new(template)
    output = renderer.result(binding)

    File.write('index.html', output)
  end

  private

  def load_data
    YAML.load_file(File.join(__dir__, '../data/human.yaml'))
  end

  def timeline_years
    (@start_year..@end_year).step(@century_step).to_a
  end

  def timeline_config
    {
      startYear: @start_year,
      endYear: @end_year,
      centuryStep: @century_step,
      pxPerCentury: @px_per_century
    }
  end

  def timeline_data
    {
      config: timeline_config,
      years: timeline_years,
      tags: @data['tags'],
      humans: @data['humans'],
      titleImage: @title_image_base64
    }
  end

  def year_to_position(year)
    # マイナスの年（BC）も適切に処理
    year_value = year.to_s.sub('?', '').to_i
    ((year_value - @start_year) * @px_per_century / @century_step).round
  end

  def total_width
    total_years = @end_year - @start_year
    (total_years * @px_per_century / @century_step).round
  end

  # バーの幅を計算（パディングを考慮）
  def calculate_bar_width(birth_year, death_year)
    width = year_to_position(death_year) - year_to_position(birth_year)
    width - @bar_padding # パディング分を引く
  end
end
