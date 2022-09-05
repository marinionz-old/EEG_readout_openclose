%%
% Exercise 
% Finding the open/close stages
clearvars, close all
load('EEG.mat')
fs = 256;
N = length(eeg);
t = [0:1/fs:(N-1)/fs]';

figure('Position',[100 100 900 300])
plot(t,eeg), axis tight
xlabel('Time (s)','FontSize',24);ylabel('EEG (\muV)','FontSize',24)
xt = get(gca, 'XTick');set(gca, 'FontSize', 16)
title('EEG signal')

eeg = eeg-mean(eeg); % remove DC component
f = (-N/2:N/2-1)/N*fs;
figure()
y = fft(eeg); 
plot(f,abs(fftshift(y)))
title('EEG spectrum')

[b a] = butter(5,[8 13]/(fs/2)); %cutoff freq at 8 and 13 hz for alpha
eeg_alpha = filtfilt(b,a,eeg);
figure()
plot(t,eeg_alpha)
title('Alpha component of EEG signal');

[b a] = butter(5,[14 34]/(fs/2)); %cutoff freq at 14 and 34 hz for beta
eeg_beta = filtfilt(b,a,eeg);
figure()
plot(t,eeg_beta)
title('Beta component of EEG signal');

figure()
window= hamming(100);
spectrogram(eeg_alpha,window,50,[],'yaxis','MinThreshold',-40,fs); colorbar
title('Alpha component spectrogram');

figure()
window= hamming(100);
spectrogram(eeg_beta,window,50,[],'yaxis','MinThreshold',-40,fs); colorbar
title('Beta component spectrogram');

% 
% 2. Derivative Filter.  
b = [-1 -2 0 2 1]/8;
eeg_der = filtfilt(b,1,eeg_alpha);
figure()
plot(t,eeg_der)
title('Derivative filter on alpha component');
xlabel('Time(s)');
ylabel('Amplitude')

% 
% 3.Squaring
eeg_sq = (eeg_der).^2;
figure()
plot(t,eeg_sq)

title('Square of Derivative filter output');
xlabel('Time(s)');
ylabel('Amplitude')

% 4. Moving Average. 
t_ma =2000; %ms. Window 
            
L=floor(t_ma*10^-3*fs); 
b = ones(1,L)/L;
eeg_ma = filtfilt(b,1,eeg_sq);
figure()
plot(t,eeg_ma)

title('Moving average over filtered alpha component');
xlabel('Time(s)');
ylabel('Amplitude')


thr=0.2;
signalThr = eeg_ma>thr; 
Open = find(diff(signalThr)>0);
Close = find(diff(signalThr)<0);

timeOpen= t(Open);
timeClose= t(Close);

fprintf("The eyes open for the first time at time %.2f s and close at %.2f s. \n",timeOpen(1), timeClose(1))
fprintf("After a few seconds, the eyes open again at time %.2f s and close at %.2f s. \n",timeOpen(2), timeClose(2))
