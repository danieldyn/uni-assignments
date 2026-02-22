# Task 1 - Numerical Music

## Table of Contents

- [Overview](#overview)
- [Theoretical References](#theoretical-references)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

This task is designed for **sound synthesis, digital signal processing, and analysis**.
It allows the creation of synthetic musical sounds, manipulation of audio signals, and visualisation through spectrograms.
It uses oscillators and ADSR envelopes and the application of effects such as high-pass filtering and reverb.
We could say we can create Numerical Music with Numerical Methods!

## Theoretical References

At the core, sounds are generated as **sinusoidal waveforms shaped by ADSR envelopes**, which simulate the natural amplitude evolution of musical instruments. 
The **attack phase** determines how quickly a note reaches its peak amplitude after being triggered, the **decay phase** transitions to the sustain level, 
the **sustain phase** maintains a relatively constant amplitude, and the **release phase** gradually fades the note after it ends. 
This ADSR framework allows for realistic emulation of acoustic instruments, giving synthetic sounds a natural temporal dynamic. 
By manipulating the envelope parameters, one can mimic the behaviour of percussive instruments, sustained tones, or plucked strings.

These synthesised signals can be combined into **musical patterns or sequences**, where each element represents a rhythmic or melodic event. 
By aligning signals according to a specific tempo (beats per minute) and subdividing beats into smaller units (e.g., semiquavers), complex musical phrases can be constructed programme­tically. 
This approach facilitates the composition of digital music entirely from algorithmically generated sounds, allowing precise control over timing and amplitude characteristics.

Once sounds are created, they can undergo **digital signal processing (DSP) operations**. A **high-pass filter** removes low-frequency components, which can be used to eliminate rumble, enhance clarity, or shape the tonal balance of a track. 
**Reverb convolution** simulates the reflection of sound waves in a physical environment, creating the perception of spatial depth and ambience. 
To simplify processing, stereo signals are often converted to mono, reducing data dimensionality while preserving essential auditory information. 
Additionally, normalisation ensures that signal amplitudes remain within a standard range, preventing clipping and maintaining consistent perceived loudness.

For analysis and verification, **spectral analysis tools** provide insight into the frequency content and temporal evolution of audio signals. 
The **spectrogram** computes the short-time Fourier transform (STFT) by segmenting the signal into overlapping windows and calculating the frequency spectrum of each window. 
This produces a time-frequency representation that reveals how energy is distributed across frequencies over time. 
Using a **logarithmic amplitude scale** aligns the visualisation with human auditory perception, emphasising weaker harmonics and making patterns such as attack transients, decay curves, and resonances more apparent. 

## Functions

Now that the theoretical background is fully documented, here are the necessary MATLAB functions:

#### 1. `function x = oscillator(freq, fs, dur, A, D, S, R)`

**Purpose**: Generates a sinusoidal audio signal for a specified frequency and applies an ADSR amplitude envelope.

**Parameters**:
- `freq` – signal frequency (Hz)
- `fs` – sample rate (samples/second)
- `dur` – duration of the note (seconds)
- `A, D, S, R` – attack, decay, sustain, release parameters (seconds or relative amplitude)

**Returns**:
- `x` – generated waveform

#### 2. `function signal = apply_reverb(signal, impulse_response)`

**Purpose**: Applies reverberation to an audio signal by convolving it with an impulse response.

**Parameters**:
- `signal` – input audio waveform
- `impulse_response` – reverb impulse response

**Returns**:
- `signal` – reverberated output (normalized)

#### 3. `function mono = stereo_to_mono(stereo)`

**Purpose**: Converts a stereo audio signal into mono by averaging the left and right channels.

**Parameters**:
- `stereo` – stereo input signal

**Returns**:
- `mono` – mono output signal (normalised)

#### 4. `function [S, f, t] = spectrogram(signal, fs, window_size)`

**Purpose**: Computes the short-time Fourier transform to analyse frequency content over time.

**Parameters**:
- `signal` – input waveform
- `fs` – sample rate
- `window_size` – number of samples per window

**Returns**:
- `S` – spectrogram matrix
- `f` – frequency vector
- `t` – time vector

#### 5. `function signal = high_pass(signal, fs, cutoff_freq)`

**Purpose**: Filters out low-frequency components from a signal, retaining frequencies above the cutoff.

**Parameters**:
- `signal` – input waveform
- `fs` – sample rate
- `cutoff_freq` – cutoff frequency in Hz

**Returns**:
- `signal` – high-pass filtered waveform (normalised)

#### 6. `function instrument_map = create_instruments(file, fs, num_instruments)`

**Purpose**: Reads instrument definitions from a file and generates oscillator signals for each instrument.

**Parameters**:
- `file` – open file handle to the instrument CSV
- `fs` – sample rate
- `num_instruments` – number of instruments in the file

**Returns**:
- `instrument_map` – mapping of instrument names to precomputed audio signals

#### 7. `function [signal, fs] = create_sound(filename)`

**Purpose**: Generates a full audio signal from a CSV file describing instruments, rhythms, and patterns.

**Parameters**:
- `filename` – path to CSV containing BPM, sample rate, instruments, and patterns

**Returns**:
- `signal` – synthesised audio waveform
- `fs` – sample rate

#### 8. `pattern = parse_pattern(file, fs, bpm, instrument_map)`

**Purpose**: Converts a sequence of instrument hits and rests into a complete audio track aligned to the tempo.

**Parameters**:
- `file` – open file handle containing a pattern
- `fs` – sample rate
- `bpm` – beats per minute
- `instrument_map` – mapping of instrument names to audio signals

**Returns**:
- `pattern` – generated waveform corresponding to the sequence

#### 9. `function plot_spectrogram(S, f, t, window_title)`

**Purpose**: Visualises a spectrogram as a color-coded image with logarithmic amplitude scaling.

**Parameters**:
- `S` – spectrogram matrix
- `f` – frequency vector
- `t` – time vector
- `window_title` – figure title

**Returns**: None (generates a plot)

## Running the Tasks

- Check the `studio.m` file and change marked parameters if desired (`.csv` file name, `.wav` file name)
- Ensure that the input files exist at the specified path and is well-formatted
- From the MATLAB/GNU Octave Command Window, enter `studio` and inspect the output
