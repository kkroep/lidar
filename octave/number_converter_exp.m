% number to correct notation converter



function answer = number_converter_exp (number, unit)


exponent = floor(log10(number));
if(exponent==0)
	answer = sprintf('$%.2f', number);
else
	answer = sprintf('$%.2f\\cdot10^{%.0f}', number/10^exponent, exponent);
end
answer = [answer,'\,' ,unit, '$'];

endfunction
