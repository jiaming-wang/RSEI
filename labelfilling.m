function output_label = labelfilling(label)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

a = all(label== 0, 1);
%%
a = ~a;
b = all(label== 0, 2);
b = ~b;
output_label = double(b) * double(a); 
end

