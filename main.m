close all; clear all; clc;

%% load audio
[x, Fe] = audioread('data/full-sentence.wav');

x = 0.9*x/max(abs(x)); % normalize
x = resample(x, 44100, Fe);
Fe = 44100;

%% prep
% WINDOW
Nwin = floor(0.03*Fe);% using 30ms Hann window
w = hann(Nwin, 'periodic'); % window creation

% GLOBAL VARIABLES
tInterp = 5; % time of interpolation
nInterp = floor(tInterp * Fe);
Nframes = floor(nInterp / Nwin); % number of frames
p = 8; % number of LPC poles 
[B, G] = lpcEncode(x, p, w);

% INSTANCIATION
%Nframes = length(G);
F = ones(1, Nframes) * 440; % pitch guide (Hz)
G = ones(1, Nframes) * 4e-03; % vocal effort 

%% Interpolating poles
% loading poles
v1p = B(:,85);
v2p = B(:,45);

% ... into A
A = zeros(p, 2);
A(:,1) = sort(v1p);
A(:,2) = sort(v2p);

% Interpolate
A = interpolatePoles(A, Nframes);

%% LPC decode
%interpolatedSig = lpcDecode(A, [G; F], w, 200/Fe);
interpolatedSig = zeros(Nwin, Nframes);
src = impulseTrain(F, Nwin, Fe);
interpolatedSig = interpolatedSig*0.9/max(abs(interpolatedSig));

%% Encoding result to .wav
audiowrite('output/interpolatedSignal.wav', interpolatedSig , Fe);
plot(interpolatedSig)
