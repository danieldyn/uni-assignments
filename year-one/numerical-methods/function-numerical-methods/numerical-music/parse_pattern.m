function pattern = parse_pattern(file, fs, bpm, instrument_map)
    % Calculate timing
  samples_per_beat = 60 * fs / bpm;   % Samples in one beat
  samples_per_minibeat = samples_per_beat / 4;  % Quarter-beat resolution

  % Read raw pattern description from file
  raw_pattern = fgetl(file);
  raw_pattern = strsplit(raw_pattern, ',');
  raw_pattern = strtrim(raw_pattern);
  num_minibeats = length(raw_pattern);

  % Initialise output pattern with zeros
  pattern = zeros(1, samples_per_minibeat * num_minibeats);

  % Fill in pattern with instruments
  for i = 1:num_minibeats
    start_idx = (i - 1) * samples_per_minibeat + 1;

    % Skip silence
    if strcmp(raw_pattern{i}, '_')
      continue;
    end

    % Fetch instrument waveform
    instrument = instrument_map(raw_pattern{i});
    inst_len   = length(instrument);
    end_idx    = start_idx + inst_len - 1;

    % Extend pattern if necessary
    if length(pattern) < end_idx
      pattern = [pattern, zeros(1, end_idx - length(pattern))];
    end

    % Insert instrument waveform
    pattern(start_idx:end_idx) = instrument;
  end
end
