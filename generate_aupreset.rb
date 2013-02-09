#!/usr/bin/ruby

MIDI_NUMBER_OFFSET = -21
OCTAVE_NUMBER_OFFSET = -3
NOTES_PER_OCTAVE = 12

ZONES_PLACEHOLDER = '***ZONES***'
FILE_REFERENCES_PLACEHOLDER = '***FILE REFERENCES***'

def file_name_for_midi_number (number)
	number += MIDI_NUMBER_OFFSET
	pitch_number = number % NOTES_PER_OCTAVE
	octave = (number + OCTAVE_NUMBER_OFFSET) / NOTES_PER_OCTAVE + 1

	case pitch_number
		when 0
			pitch = 'A'
		when 1
			pitch = 'A#'
		when 2
			pitch = 'B'
		when 3
			pitch = 'C'
		when 4
			pitch = 'C#'
		when 5
			pitch = 'D'
		when 6
			pitch = 'D#'
		when 7
			pitch = 'E'
		when 8
			pitch = 'F'
		when 9
			pitch = 'F#'
		when 10
			pitch = 'G'
		when 11
			pitch = 'G#'
		else
	end

	pitch + octave.to_s + '.wav'
end

STARTING_SAMPLE_NUMBER = 268435457

def sample_number_for_midi_number (number, starting_pitch)
	STARTING_SAMPLE_NUMBER + number - starting_pitch
end

def write_aupreset (starting_pitch, ending_pitch, template_file_name, output_file_name)
	samples = ''

	for n in starting_pitch..ending_pitch
		filename = file_name_for_midi_number(n)
		sample_number = (sample_number_for_midi_number(n, starting_pitch)).to_s
		samples << "<key>Sample:#{sample_number}</key>\n"
		samples << "<string>/Users/peter/Library/Audio/Sounds/#{filename}</string>\n"
	end

	zones = ''

	for n in starting_pitch..ending_pitch
		zones << "<dict>
<key>ID</key>
<integer>#{n - starting_pitch + 1}</integer>
<key>enabled</key>
<true/>
<key>loop enabled</key>
<false/>
<key>max key</key>
<integer>#{n}</integer>
<key>min key</key>
<integer>#{n}</integer>
<key>root key</key>
<integer>#{n}</integer>
<key>waveform</key>
<integer>#{sample_number_for_midi_number(n, starting_pitch)}</integer>
</dict>\n"
	end

	template = File.open(template_file_name) do |template_file|
		template_file.read
	end
	
	template[ZONES_PLACEHOLDER] = zones
	template[FILE_REFERENCES_PLACEHOLDER] = samples

	output = File.open(output_file_name, "w") do |output|
		output.puts template
	end
end

starting_pitch = $*[0].to_i
ending_pitch = $*[1].to_i
template_file_name = $*[2]
output_file_name = $*[3]

puts "starting pitch: #{starting_pitch}\nending pitch: #{ending_pitch}\ntemplate: #{template_file_name}\noutput: #{output_file_name}"

write_aupreset(starting_pitch, ending_pitch, template_file_name, output_file_name)