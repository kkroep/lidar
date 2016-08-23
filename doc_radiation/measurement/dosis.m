% octave file for postprocessing info
clear all;
close;
clc;


hours =5;
minutes = 60;

coordinates = [
0 0
15 0
116 40
152 40
251 100
360 100
]

y_min = 0;
y_max = 150;

hold on;
plot(coordinates(:,1),coordinates(:,2), 'k');

x = [15 116];
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','r');
end

x = 144;
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','b');
end

x = [152 251];
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','g');
end

xlabel('time (min)');
ylabel('dosis (krads)')
hold off;

print -deps test.eps;