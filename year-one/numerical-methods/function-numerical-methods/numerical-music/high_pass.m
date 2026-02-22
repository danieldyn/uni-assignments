function signal = high_pass(signal, fs, cutoff_freq)
  % Compute FFT of the signal
  X = fft(signal);
  n = length(signal);

  % Frequency vector (linear spacing up to Nyquist)
  freq = (0:n-1) * (fs / n);

  % Construct binary mask for high-pass filtering
  mask = zeros(n, 1);
  for i = 1:floor(n / 2)
    if freq(i) > cutoff_freq
      mask(i) = 1;
      mask(n - i + 1) = 1;   % mirror index for negative frequencies
    end
  end

  % Apply mask to spectrum
  X = X .* mask;

  % Inverse FFT to return to time domain
  signal = ifft(X);

  % Normalise signal to [-1, 1]
  signal = signal / max(abs(signal));
end
