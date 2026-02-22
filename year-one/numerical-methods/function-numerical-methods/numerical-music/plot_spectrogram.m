function plot_spectrogram(S, f, t, window_title)
  % Create figure window
  figure('Name', window_title);
  % Plot spectrogram
  % We use log scale because human hearing is approximately logarithmic.
  imagesc(t, f, log10(S));
  axis xy;  % Set origin to bottom-left
  xlabel('Time (s)');
  ylabel('Frequency (Hz)');
  title('Spectrogram');
  colormap('jet');
  colorbar; % Add color scale reference
end
