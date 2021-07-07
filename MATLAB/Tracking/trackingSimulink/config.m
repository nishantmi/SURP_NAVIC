%Run this before simulating trackingModel.slx
fc = 4128460;     %Carrier Frequency detected after acquisition
fs = 16367600;    %Sampling frequency
fcBasis = fc;
svnum = 22;       %Satellite Number

%For carrier phase error lookup table
QIratio = -5:(2^-7):5;            %Covers -78.7 to 78.7 degrees. 1281 elements
carrErrorValues = atan(QIratio)/(2.0*pi);