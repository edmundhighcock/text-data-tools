require 'helper'

class TestTextDataTools < Test::Unit::TestCase
	def test_1d
		assert_raise(ArgumentError){TextDataTools::Column.get_1d_array('test/test_dat.dat', true, 2.2)} 
		assert_raise(ArgumentError){TextDataTools::Column.get_1d_array('test/test_dat.dat',true, /ii\+ temp/, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)} 
		array = TextDataTools::Column.get_1d_array('test/test_dat.dat', true, /i\+ temp/, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)
		#puts array
		assert_equal(array.size, 18)
		assert_equal(array[9].to_f, 0.9753E+09)
		array = TextDataTools::Column.get_1d_array_float('test/test_dat.dat', true, /i\+ temp/, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)
		assert_equal(array[9], 0.9753E+09)
	end
	def test_2d
		array = TextDataTools::Column.get_2d_array('test/test_dat.dat', true, /i\+ temp/, 0, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)
		assert_equal(array.size, 2)
		array = TextDataTools::Column.get_2d_array('test/test_dat.dat', true, /i\+ temp/, 1, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)
		assert_equal(array.size, 18)
		array = TextDataTools::Column.get_2d_array_float('test/test_dat.dat', true, /i\+ temp/, 0, /\S+/, /(?:\#\s+)?\d:.*?(?=\d:)/)
		assert_equal(array[0].size, 9)
		assert_equal(array[1][0], 0.9753E+09)

		#assert_equal(array[9].to_f, 0.9753E+09)

	end
	def test_2d_newlines
		file = TextDataTools::Column::DataFile.new('test/test_dat_new_lines.dat', true, /\S+/,  /(?:\#\s+)?\d:.*?(?=\d:)/)
		array = file.get_2d_array(/Qi.*GB/, /1.*time/)
		assert_equal(24, array[0].size)
	end
	def test_get_variable
		variable = TextDataTools::Named.get_variable_value('test/test_dat_2.dat', 'Q', ':')
		assert_equal(variable.to_f, 11.989644168449118)
		variable = TextDataTools::Named.get_variable_value('test/test_dat_2.dat', 'Fusion power', ':')
		assert_equal(variable.to_f, 484.34196189744871)
	end
	def test_texdatafile_class
		file = TextDataTools::Named::DataFile.new('test/test_dat_2.dat', ':')
		assert_equal(file.get_variable_value('Alpha power').to_f, 116.90499891894469 )
		file = TextDataTools::Column::DataFile.new('test/test_dat.dat', true, /\S+/,  /(?:\#\s+)?\d:.*?(?=\d:)/)
		array = file.get_2d_array(/i\+ temp/, /1.*time/)
		assert_equal(array.size, 2)
		assert(file.exists?)
		array = file.get_2d_array_float(/i\+ temp/, 0)
		assert_equal(array[0].size, 9)
		assert_equal(array[1][0], 0.9753E+09)
	end
	def test_inspect
		file1 = TextDataTools::Named::DataFile.new('test/test_dat_2.dat', ':')
		file2 = TextDataTools::Column::DataFile.new('test/test_dat.dat', true, /\S+/,  /(?:\#\s+)?\d:.*?(?=\d:)/)
		file1a = eval(file1.inspect) 
		file2a = eval(file2.inspect) 
		assert_equal(file1.instance_variable_get(:@filename), file1a.instance_variable_get(:@filename))
		assert_equal(file2.instance_variable_get(:@header_match), file2a.instance_variable_get(:@header_match))
	end
	def test_to_s
		file1 = TextDataTools::Named::DataFile.new('test/test_dat_2.dat', ':')
		#file1.view
		assert_equal('test/test_dat_2.dat', file1.to_s)
	end
end
