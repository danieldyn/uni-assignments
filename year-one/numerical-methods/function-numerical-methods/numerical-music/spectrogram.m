function [S, f, t] = spectrogram(signal, fs, window_size)
  % Initialisation
  n = length(signal);
  m = floor(n / window_size);     % number of windows
  S = zeros(window_size, m);
  h = hanning(window_size);       % Hann window

  % Process each window
  for i = 1:m
    % Window boundaries
    window_start = (i - 1) * window_size + 1;
    window_end   = window_start + window_size - 1;

    % Extract and window the signal
    window = signal(window_start:window_end) .* h;

    % Apply FFT with zero-padding (length = 2*window_size)
    fourier = fft(window, 2 * window_size);

    % Keep only positive frequencies (discard conjugate symmetry)
    fourier = abs(fourier(1:window_size));

    % Store column in spectrogram
    S(:, i) = fourier;
  end

  % Frequency vector (column)
  f = (0:window_size-1)' * (fs / (2 * window_size));

  % Time vector (column)
  t = (0:m-1)' * (window_size / fs);
end

