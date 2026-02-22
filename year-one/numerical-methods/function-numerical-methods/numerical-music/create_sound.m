function [signal, fs] = create_sound(filename)
  % Open file for reading
  file = fopen(filename, 'r');
  
  % Read global settings (bpm, fs, number of instruments)
  header = fgetl(file);
  header = strtrim(strsplit(header, ','));
  bpm = str2double(header{1});
  fs = str2double(header{2});
  num_instruments = str2double(header{3});

  % Create a map of instruments (name -> waveform)
  instrument_map = create_instruments(file, fs, num_instruments);

  % The format of the rhythm patterns is something like:
  %   kick, _, hihat, _, kick, _, hihat, _
  %
  % where "_" means silence (but sound can "bleed" from earlier notes).
  
  % Parse two rhythmic patterns from the file
  pat1 = parse_pattern(file, fs, bpm, instrument_map);
  pat2 = parse_pattern(file, fs, bpm, instrument_map);

  % Close the file
  fclose(file);

  % Align patterns to equal length (pad with zeros if needed)
  if length(pat1) > length(pat2)
    pat2 = [pat2, zeros(1, length(pat1) - length(pat2))];
  else
    pat1 = [pat1, zeros(1, length(pat2) - length(pat1))];
  end

  % Mix the patterns together
  signal = pat1 + pat2;

  % Convert to column vector
  signal = signal(:);

  % Normalise amplitude
  signal = signal / max(abs(signal));
end
