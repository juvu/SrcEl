[LegacyColorValue = TRUE];

{ TSMTrendZones : Intraday price zones based on trend and volatility
  Copyright 1999-2004, P.J.Kaufman. All rights reserved. }

	inputs: tlength(5), vlength(10);
	vars:	chg(0), trend(0), high2(0), high1(0), avg(0), low1(0), low2(0);

	chg = absvalue(close - close[1]);
	avg = average(chg,vlength);
	trend = average(close,tlength);

	high2 = trend + 2*avg;
	high1 = trend + avg;
	low1 = trend - avg;
	low2 = trend - 2*avg;
	plot1(high2,"TSMhigh2");
	plot2(high1,"TSMhigh1");
	plot3(low1,"TSMlow1");
	plot4(low2,"TSMlow2");
