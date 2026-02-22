function mono = stereo_to_mono(stereo)
  % Average the two channels to get mono
  mono = mean(stereo, 2);

  % Normalise to prevent clipping
  mono = mono / max(abs(mono));
end
