% number to correct notation converter



function answer = number_converter_exp (number, unit)


if(number>=1e18)
	answer = sprintf('$%.2f\\cdot10^{18}', number/1e18);
elseif(number>=1e15)
	answer = sprintf('$%.2f\\cdot10^{15}', number/1e15);
elseif(number>=1e12)
	answer = sprintf('$%.2f\\cdot10^{12}', number/1e12);
elseif(number>=1e9)
	answer = sprintf('$%.2f\\cdot10^9', number/1e9);
elseif(number>=1e6)
	answer = sprintf('$%.2f\\cdot10^6', number/1e6);
elseif(number>=1e3)
	answer = sprintf('$%.2f\\cdot10^3', number/1e3);
elseif(number>=1)
	answer = sprintf('$%.2f\\,', number);
elseif(number>=1e-3)
	answer = sprintf('$%.2f\\cdot10^{-3}', number*1e3);
elseif(number>=1e-6)
	answer = sprintf('$%.2f\\cdot10^{-6}', number*1e6);
elseif(number>=1e-9)
	answer = sprintf('$%.2f\\cdot10^{-9}', number*1e9);
elseif(number>=1e-12)
	answer = sprintf('$%.2f\\cdot10^{-12}', number*1e12);
elseif(number>=1e-15)
	answer = sprintf('$%.2f\\cdot10^{-15}', number*1e15);
elseif(number>=1e-18)
	answer = sprintf('$%.2f\\cdot10^{-18}', number*1e18);
elseif(number>=1e-21)
	answer = sprintf('$%.2f\\cdot10^{-21}', number*1e21);
elseif(number>=1e-24)
	answer = sprintf('$%.2f\\cdot10^{-24}', number*1e24);
elseif(number>=1e-27)
	answer = sprintf('$%.2f\\cdot10^{-27}', number*1e27);
elseif(number>=1e-30)
	answer = sprintf('$%.2f\\cdot10^{-30}', number*1e30);
elseif(number>=1e-33)
	answer = sprintf('$%.2f\\cdot10^{-33}', number*1e33);
else
	answer = sprintf('$%.2f\\cdot10^{-36}', number*1e36);
endif

answer = [answer,'\,' ,unit, '$'];

endfunction
