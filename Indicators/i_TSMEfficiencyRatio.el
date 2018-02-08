[LegacyColorValue = TRUE];

{ TSMEfficiencyRatio : Kaufman's Efficiency Ratio
  Copyright 1990-2004, P J Kaufman.  All rights reserved. }
  
	input: period(20), navg(5);
	vars:	 change(0), noise(0), diff(0), ratio(0), signal(0), ERavg(0);

	ratio = 0;
	diff = AbsValue(close - close[1]);
	if currentbar > period then begin
	      change = close - close[period];
    		signal = AbsValue(change);
      	noise = summation(diff,period);
      	ratio = 0;
      	if noise <> 0 then ratio = signal/noise;
      	ERavg = average(ratio,navg);
      	end;
	plot1(ratio,"ER");
	plot2(ERavg,"avg");
