function x = oscillator(freq, fs, dur, A, D, S, R)
  % Time vector
  step = 1 / fs;
  t = (0:step:dur-step)';

  % Base sine wave
  x = sin(2 * pi * freq * t);

  % Number of samples for each envelope stage
  attack_samples  = floor(A * fs);
  decay_samples   = floor(D * fs);
  release_samples = floor(R * fs);
  sustain_samples = length(t) - attack_samples - decay_samples - release_samples;

  % Attack envelope (0 → 1)
  step = 1 / (attack_samples - 1);
  attack_envelope = 0:step:1;

  % Decay envelope (1 → S)
  step = -(1 - S) / (decay_samples - 1);
  decay_envelope = 1:step:S;

  % Sustain envelope (constant at level S)
  sustain_envelope = S * ones(1, sustain_samples);

  % Release envelope (S → 0)
  step = -S / (release_samples - 1);
  release_envelope = S:step:0;

  % Concatenate envelope segments
  envelope = [attack_envelope decay_envelope sustain_envelope release_envelope]';

  % Apply envelope to sine wave
  x = x .* envelope;
end
