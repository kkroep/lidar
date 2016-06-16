% number to correct notation converter



function answer = number_converter_2 (number, unit)


if(number>=1e18)
	answer = sprintf('$%.2f\\,G', number/1e18);
elseif(number>=1e12)
	answer = sprintf('$%.2f\\,M', number/1e12);
elseif(number>=1e6)
	answer = sprintf('$%.2f\\,k', number/1e6);
elseif(number>=1)
	answer = sprintf('$%.2f\\,', number);
elseif(number>=1e-6)
	answer = sprintf('$%.2f\\,m', number*1e6);
elseif(number>=1e-12)
	answer = sprintf('$%.2f\\,\\mu', number*1e12);
elseif(number>=1e-18)
	answer = sprintf('$%.2f\\,n', number*1e18);
elseif(number>=1e-24)
	answer = sprintf('$%.2f\\,p', number*1e24);
elseif(number>=1e-30)
	answer = sprintf('$%.2f\\,f', number*1e30);
else
	answer = sprintf('$%.2f\\,a', number*1e36);
endif

answer = [answer,' ' ,unit, '$'];

endfunction
