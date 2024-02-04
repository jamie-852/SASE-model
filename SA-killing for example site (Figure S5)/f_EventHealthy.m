function [value,isterminal,direction] = f_EventHealthy(t, y)
value = y(3) - 1;
isterminal = 1;     % Stop the integration
direction = 0;      % Locate all zeros
%}
