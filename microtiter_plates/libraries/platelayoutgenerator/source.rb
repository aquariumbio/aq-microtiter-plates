# frozen_string_literal: true

# Factory class for instantiating `PlateLayoutGenerator`
#
# @author Devin Strickland <strcklnd@uw.edu>
class PlateLayoutGeneratorFactory
  # Instantiates `PlateLayoutGenerator`
  #
  # @param group_size [FixNum] the size of groups of wells, e.g., corresponding
  #   to replicates
  # @return [PlateLayoutGenerator]
  def self.build(group_size: 1, method: nil, dimensions: [8, 12])
    PlateLayoutGenerator.new(group_size: group_size,
                             method: method,
                             dimensions: dimensions)
  end
end

# Provides individual indices or batches of indices from a microtiter plate, in
#   order from top left ,and yielding each index only once
#
# @author Devin Strickland <strcklnd@uw.edu>
class PlateLayoutGenerator
  def initialize(group_size: 1, method: nil, dimensions: [8, 12])
    @group_size = group_size
    method ||= :sample_layout
    @rows = dimensions[0]
    @columns = dimensions[1]
    @start_array = make_start_array
    @layout = send(method)
    @ii = []
    @column = []
    @first_index = []
  end

  def next(column: nil)
    i = column ? first_index_in(column) : 0
    @layout.slice!(i)
  end

  def next_group(column: nil)
    i = column ? first_index_in(column) : 0
    @layout.slice!(i, @group_size)
  end

  def iterate_column(column)
    return nil if column.nil?
    if column < @columns
      column += 1
    else
      column = 0
    end
    column
  end

  private

  def make_start_array
    rem = @rows % @group_size
    divisions = @group_size
    divisions += 1 unless rem == 0
    start_array = []
    @rows.times do |idx|
      start_row = divisions * idx
      break if start_row == @rows && @group_size != 1
      start_array.push(start_row)
    end
    start_array
  end

  def first_index_in(column)
    @layout.index { |x| x[1] == column }
  end

  def cdc_sample_layout
    lyt = []
    [0, 4].each do |j|
      cols = Array.new(12) { |c| c }
      cols.each { |c| @group_size.times { |i| lyt << [i + j, c] } }
    end
    lyt
  end

  # @todo make this responsive to @group_size
  def cdc_primer_layout
    lyt = []
    3.times { |i| [0, 4].each { |j| 12.times { |k| lyt << [i + j, k] } } }
    lyt
  end

  def sample_layout
    lyt = []
    @start_array.each do |j|
      cols = Array.new(@columns) { |c| c }
      cols.each { |c| @group_size.times { |i| lyt << [i+j, c] } }
    end
    lyt
  end

  def primer_layout
    lyt = []
    @group_size.times { |i| @start_array.each { |j| @columns.times { |k| lyt << [i + j, k] } } }
    lyt
  end

end
