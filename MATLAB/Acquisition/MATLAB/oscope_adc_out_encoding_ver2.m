% Author : Swetha Jose (PRA, aiCAS lab, Dept. of Electrical Engineering, IIT Bombay)
% Date : 5 March 2020
% Purpose : Converting ADC digital output from oscilloscope to .bin file
% ==============README==============================================================
% 1. The digital signal from the chip must be viewed in oscilloscope in 
%	 dc coupling mode so that its levels are 0V to 2.5V and saved as .csv file
% 2. Sign and MagH bits (2 bits) are used
% 3. The encoding levels are 
%       ----------------------
%       Sign  |  MagH  |  Code
%       ----------------------      
%         0   |   1    |  +3
%         0   |   0    |  +1
%         1   |   0    |  -1
%         1   |   1    |  -3
%       ----------------------
% 4. The folder name must be edited in the code below. The .csv file name and 
%    sampling frequency must be entering on running the code 
%    This code stores the signal sample as one signed byte (int8) in a .bin file
%    The .bin file is saved in ./generated_files folder
%    The generated .bin file can be directly used in the acquisition code
%====================================================================================
clear all; close all;
% Edit folder name here
folder_name = '/home/users/syedhameed/swetha_matlab/MATLAB_CODES_DATA_ANALYSIS';
file_name = input('Enter filename in single quotes without .csv extension: ');
file_path = strcat(folder_name,'/',file_name,'.csv');
sampling_freq = input('Enter sampling frequency : ');
dig_threshold = 1.25; %midpoint of 2.5V digital out
%% Obtaining ile information
data_adc = csvread(file_path,22);
time = data_adc(:,1);
ch_sign = data_adc(:,2); %sign 
ch_magH = data_adc(:,3); %mag_H
ch_clk = data_adc(:,4); %clock
ch_magL = data_adc(:,5); % magL    //added by hameed for 3 bit detection
data_length = length(time);
time_length = time(length(time))-time(1);
%% Sampling ADC data and Encoding begins 
num_expected = floor(time_length*sampling_freq); % obtaining number of adc samples at clock edges
sample_index = 1;
for i = 1:data_length-1
   if ch_clk(i) > dig_threshold
       clk_current = 1;
   else
       clk_current = 0;
   end
   if ch_clk(i+1) > dig_threshold
       clk_next = 1;
   else
       clk_next = 0;
   end
   if (clk_current == 1 && clk_next == 0)
       if ch_sign(i) > 1.25
           sign = 1;
       else
           sign = 0;
       end
       if ch_magH(i) > 1.25
           magH = 1;
       else
           magH = 0;
       end
       % for 3 bit data  // added by hameed
       if ch_magL(i) > 1.25
           magL = 1;
       else
           magL = 0;
       end
       % for 3 bit data  // added by hameed
       bin2dec = 4*sign + 2*magH + magL ;
       switch bin2dec
           case 0
               adc_data(sample_index) = 1;
           case 1
               adc_data(sample_index) = 2;
           case 2
               adc_data(sample_index) = 3;
           case 3
               adc_data(sample_index) = 4;
           case 4
               adc_data(sample_index) = -1;
           case 5
               adc_data(sample_index) = -2;
           case 6
               adc_data(sample_index) = -3;
           case 7
               adc_data(sample_index) = -4;
       end
       sample_index = sample_index + 1;
   end 
end

%% saving in 2-bit ADC samples in bin format
out_file_path = strcat(folder_name,'/',file_name,'_gen.bin');
file1 = fopen(out_file_path,'w');
fwrite(file1,adc_data,'int8');
fclose(file1);
fprintf('The .bin file is generated.\n')
fprintf('Plotting histogram\n')
%% opening the bin file and plotting histogram of 2-bit ADC samples
file2 = fopen(out_file_path);
samples = fread(file2,'int8');
fclose(file2);
histogram(samples);