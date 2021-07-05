function C = fftsearch(data, sat_id, ch_rate, fs, fc, n_data)
% The function
% C = fftsearch(data, sat_id, ch_rate, fs, fc, n_data)
%performs a circular convolution by using the FFT and IFFT. A single % carrier frequency is used and a correlation vector is returned
%
%data = The data to be processed
%sat_id = the PRN number of the satellite
%ch_rate = the C/A code chippingrate (1.023 MHz)
%fs = the sampling frequency
%fc = carrier frequency
% n_data = number of data samples (typically 5000 samples)
%Generate CA code
CA = cacode(sat_id, ch_rate, fs, n_data);
% Time vector
t = (0:(n_data-1))/fs;
%In-phase component
I_comp = cos(2*pi*fc.*t).*data;
%Quadrature component
Q_comp = sin(2*pi*fc.*t).*data;
% FFT of I and Q components
X = fft(I_comp + 1i*Q_comp);
%conj(FFT) of CA code
F_CA = conj(fft(CA));
%Multiply in freq domain and perform IFFT %then get the squared magnitude
C = abs(ifft(X.*F_CA)).^2;
end