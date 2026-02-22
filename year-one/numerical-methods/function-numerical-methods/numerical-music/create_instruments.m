function instrument_map = create_instruments(file, fs, num_instruments)
  % Preallocate cell array to hold instrument parameters
  instruments = cell(num_instruments, 7);

  % Read instrument definitions line by line
  for i = 1:num_instruments
    line = fgetl(file);  % read one line from file
    instruments(i, :) = strtrim(strsplit(line, ',')); % split and clean
  end

  % Initialize a map: key = instrument name, value = waveform
  instrument_map = containers.Map('KeyType', 'char', 'ValueType', 'any');

  % Convert parameters and generate instrument waveforms
  for i = 1:num_instruments
    name = char(instruments{i, 1});
    freq = str2double(instruments{i, 2});
    duration = str2double(instruments{i, 3});
    attack = str2double(instruments{i, 4});
    decay = str2double(instruments{i, 5});
    sustain = str2double(instruments{i, 6});
    release = str2double(instruments{i, 7});

    % Generate waveform using oscillator
    osc = oscillator(freq, fs, duration, attack, decay, sustain, release);

    % Store in map
    instrument_map(name) = osc;
  end
end
