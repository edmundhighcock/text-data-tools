
module TextFileTools
	#  Return a one-dimensional array containing data from the file filename,
	#   which may or may not have a line of column headers,
	#  in the column column_header, where column_header maybe either a string
	#  or a regex which matches the title of the column,  or an integer
	#  giving the zero-based  column number.
	#
	#  Match is a regexp that matches data items, and header_match is a regexp that
	#  matches items in the headers.
	#
	#  All data is returned as strings
	def self.get_1d_array(filename, has_header_line, column_header, match=/\S+/, header_match=/\S+/)
		raise ArgumentError.new("column_header header should be a string, regex or integer") unless [String, Regexp, Integer].find{|cls| column_header.kind_of? cls}
		array = []
		File.open(filename) do |file|
			headers = file.gets if has_header_line
			if [String, Regexp].find{|cls| column_header.kind_of? cls}
				raise ("Header search given but has_header_line = false") if not has_header_line
				column_header = column_index_from_headers(headers, column_header, header_match)
			end
			while line = file.gets
				values = line.scan(match)
			 	array.push values[column_header]	
				#puts line
			end
		end
		array
	end
	
	#
	# Calls get_1d_array and converts all data elements to floats
	def self.get_1d_array_float(*args)
		get_1d_array(*args).map{|v| v.to_f}
	end

	#  Return a two-dimensional array containing data from the file filename,
	#   which may or may not have a line of column headers,
	#  in the column column_header, where column_header maybe either a string
	#  or a regex which matches the title of the column,  or an integer
	#  giving the zero-based  column number.
	#
	#	 It is assumed that two-dimensional array is in one column. 
	#  If index_header is nil, data is assumed to be separated by blank lines.
	#  E.g.
	#  		1.2
	#  		4.2
	#  		7.2
	#
	#  		8.2
	#  		4.2
	#  		2.2
	#  If index_header is an integer or string or regexp, it selects a column
	#  in the manner of column_header, and the data is divided by values of this
	#  column.
	#  E.g. 
	#  		1  5.5
	#  		1  3.2
	#  		1  2.6
	#  		2  3.2
	#			2  2.2
	#			2  6.3
	#
	#  Match is a regexp that matches data items, and header_match is a regexp that
	#  matches items in the headers.
	#
	#  All data is returned as strings
	def self.get_2d_array(filename, has_header_line, column_header, index_header=nil, match=/\S+/, header_match=/\S+/)
		raise ArgumentError.new("column_header header should be a string, regex or integer") unless [String, Regexp, Integer].find{|cls| column_header.kind_of? cls}
		raise ArgumentError.new("index_header should be a string, regex, integer or nil") unless [String, Regexp, Integer, NilClass].find{|cls| column_header.kind_of? cls}
		array = []
		File.open(filename) do |file|
			headers = file.gets if has_header_line
			if [String, Regexp].find{|cls| column_header.kind_of? cls}
				raise ("Header search given but has_header_line = false") if not has_header_line
				column_header = column_index_from_headers(headers, column_header, header_match)
			end
			if [String, Regexp].find{|cls| index_header.kind_of? cls}
				raise ("Header search given but has_header_line = false") if not has_header_line
				index_header = column_index_from_headers(headers, index_header, header_match)
			end
			index_value = false
			index = 0
			while line = file.gets
				if index_header.nil?
					if line =~ /^\s*$/
						if array.size == 0 # ignore empty lines at top
							next
						else
							(array.push []; index+=1;next) 
						end
					end
					array.push [] if array.size = 0
				else
					next if line =~ /^\s*$/
				end
				values = line.scan(match)
				if not index_header.nil?
					if array.size ==0
						array.push []
						index_value = values[index_header]
					elsif index_value != values[index_header]
						array.push []
						index+=1
						index_value = values[index_header]
					end
				end
			 	array[index].push values[column_header]	
				#puts line
			end
		end
		array
	end

	# Calls get_2d_array and converts all data elements to floats
	def self.get_2d_array_float(*args)
		get_2d_array(*args).map{|a| a.map{|v| v.to_f}}
	end

	class NotFoundError < StandardError
	end

	# Extract a variable value from the given file where the variable is defined
	# in this form:
	#   name sep value
	# E.g.
	# 	heat = 4.0
	def self.get_variable_value(filename, name, sep='=')
		value = nil
		File.open(filename) do |file|
			while line= file.gets
				next unless line =~ Regexp.new("#{Regexp.escape(name)}\\s*#{Regexp.escape(sep)}\\s*(?<value>.*)")
				value = $~[:value]
					
			end
		end
		raise NotFoundError.new("Can't find #{name} in #{filename}") unless value
		value
	end
	def self.column_index_from_headers(line, column_header, header_match)
		headers = line.scan(header_match)
		#p headers
		index_array = headers.map{|head| head =~ (column_header.kind_of?(Regexp) ? column_header : Regexp.new(Regexp.escape(column_header)))}
		#p index_array
		raise ArgumentError.new("column_header: #{column_header.inspect} does not match any columns in #{headers.inspect}") if index_array.compact.size == 0
		raise ArgumentError.new("column_header: #{column_header.inspect} matches more than 1 column in #{headers.inspect}") if index_array.compact.size > 1
		column_header = index_array.index(index_array.compact[0])
	end

	#  This is a simple class which can interface with the methods of TextFileTools
	#  to prevent the user having to specify the file name for every call. In a
	#  nutshell, create a new instance of this class giving it the filename,
	#  then call methods from TextFileTools omitting the first argument.
	class TextDataFile
		def initialize(filename, has_header_line = false, match = /\S+/, header_match = /\S+/)
			@filename = filename
			@match = match
			@header_match = header_match
			@has_header_line = has_header_line
			self
		end
		def get_1d_array(column_header)
			TextFileTools.get_1d_array(@filename, @has_header_line, column_header, @match, @header_match)
		end
		def get_2d_array(column_header, index_header)
			TextFileTools.get_2d_array(@filename, @has_header_line, column_header, index_header, @match, @header_match)
		end
		def get_variable_value(name, sep)
			TextFileTools.get_variable_value(@filename, name, sep)
		end
		#def method_missing(meth, *args)
			#if TextFileTools.methods.include? meth
				#TextFileTools.send(meth, @filename, *args) 
			#else
				#super
			#end
		#end
	end
end # module TextFileTools
