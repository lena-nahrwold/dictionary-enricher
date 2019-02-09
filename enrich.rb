require 'net/http'
require 'json'
require 'pry'

#!/usr/bin/env ruby

# Author: Lena Nahrwold

def get_result_from_jisho(input)
	uri = URI.parse(URI.escape("https://jisho.org/api/v1/search/words?keyword=" + input))
	result = Net::HTTP.get(uri) 
	json = JSON.parse(result)
	return json["data"]
end

begin

	unless ARGV.length == 1
		puts "Fehler: Bitte übergebe genau einen Kommandozeilenparameter mit dem Pfad der Input-Datei." 
		return 
	end

	file_name = ARGV[0]
	#input = File.read(file_name)

	output = Array.new
	lines = Array.new

	File.open(file_name) do |file|
	  file.each_line do |line|
	  	unless line.strip == ""
	  		lines << line.strip
	  	end
	  end
	end

	unless lines.count % 4 == 0 
		puts "Fehler: Die Zeilenanzahl der Input-Datei ist nicht durch vier teilbar."
		return 
	end

	lines.each_with_index do |line, index|
		if (index + 1) % 4 == 0 
			entry = Hash.new
			entry = { 
					  "lautschrift": lines[index - 3],
					  "japanisch": lines[index - 2],
					  "english": lines[index - 1],
					  "seitenzahl": lines[index],
					  "jisho": get_result_from_jisho(lines[index - 2])
					}
			output.push(entry)
		end
	end

	puts "#{output.length} Datensätze gelesen."

	File.open("output.json", 'w') { |file| file.write(output.to_json) }

	puts "Ausgabedatei output.json erfolgreich geschrieben."

rescue Exception => e
	puts "Fehler: #{e}"
end


