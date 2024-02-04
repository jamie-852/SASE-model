function [value,isterminal,direction] = f_EventHealthy(t, y)
value = y(3) - 1;
isterminal = 1;     % stop the integration when B = 1;
direction = 0;      % B = 1 is the maximum value 
                    % for barrier int. 
%}
