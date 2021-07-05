% digitizg.m This prog generates the C/A code and digitizes it
function code2 = digitizg(n,fs,offset,svnum)
% code - gold code
% n - number of samples
% fs - sample frequency in Hz;
% offset - delay time in seconds must be less than 1/fs cannot shift left
% svnum - satellite number;
gold_rate = 1.023e6; %gold code clock rate in Hz. 
ts = 1/fs;
tc = 1/gold_rate;

cdm1 = codegen(svnum); % generate C/A code 
code_in = cdm1;

% ***** creating 16 C/A code for digitizing *****
code_a = [code_in code_in code_in code_in]; 
code_a  = [code_a code_a];
code_a  = [code_a code_a];

% ***** digitizing *****
b=[1:n];
c = ceil((ts*b+offset)/tc); 
code = code_a(c);

% ***** adjusting first data point *****
if offset>=0
    code2=[code(1) code(1:n-1)];
else
    code2=[code(n) code(1:n-1)];
end