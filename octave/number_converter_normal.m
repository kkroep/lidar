% number to correct notation converter



function answer = number_converter_normal (number, unit)


exponent = floor(log10(number));
answer = sprintf('$%.0f', number);
answer = [answer,'\,' ,unit, '$'];
endfunction
