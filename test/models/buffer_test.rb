require 'test_helper'
require 'minitest/color'

class BufferTest < ActiveSupport::TestCase

  def setup
    @buffer = Buffer.new
    @buffer.name = 'Buffer Three'
  end

  test 'buffer should be present' do
    assert @buffer.present?
  end

  test 'name should be present and unique' do
    duplicate_buffer = @buffer.dup
    duplicate_buffer.name = 'buffer one'
    assert_not duplicate_buffer.valid?
    duplicate_buffer.name = '   '
    assert_not duplicate_buffer.name.present?
  end

  test 'buffer should be valid' do
    assert @buffer.valid?
  end
end
