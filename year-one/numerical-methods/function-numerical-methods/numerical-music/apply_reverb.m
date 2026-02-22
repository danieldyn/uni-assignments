function signal = apply_reverb(signal, impulse_response)
  % Convert impulse response to mono if it is stereo
  impulse_response = stereo_to_mono(impulse_response);

  % Apply convolution in the frequency domain
  signal = fftconv(signal, impulse_response);

  % Normalise to avoid clipping
  signal = signal / max(abs(signal));
end
