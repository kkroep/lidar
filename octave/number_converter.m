% number to correct notation converter



function answer = number_converter (number, unit)


if(number>=1e9)
	answer = sprintf('$%.2f\\,G', number/1e9);
elseif(number>=1e6)
	answer = sprintf('$%.2f\\,M', number/1e6);
elseif(number>=1e3)
	answer = sprintf('$%.2f\\,k', number/1e3);
elseif(number>=1)
	answer = sprintf('$%.2f\\,', number);
elseif(number>=1e-3)
	answer = sprintf('$%.2f\\,m', number*1e3);
elseif(number>=1e-6)
	answer = sprintf('$%.2f\\,\\mu', number*1e6);
elseif(number>=1e-9)
	answer = sprintf('$%.2f\\,n', number*1e9);
elseif(number>=1e-12)
	answer = sprintf('$%.2f\\,p', number*1e12);
elseif(number>=1e-15)
	answer = sprintf('$%.2f\\,f', number*1e15);
else
	answer = sprintf('$%.2f\\,a', number*1e18);
endif

answer = [answer,' ' ,unit, '$'];

endfunction
