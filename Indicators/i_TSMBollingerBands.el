[LegacyColorValue = TRUE];

{ TSMBollingerBand 
  Copyright 1999-2004, P.J.Kaufman. All rights reserved.

  Returns the width of the Bollinger band as measured from the moving average value.
  To create an upper and lower band, add and subtract this value from a trend value. 

  length = calculation period
  nsd = number of standard deviations }

  inputs:	length(20), nsd(2);
  vars:	bandwidth(0), highband(0), lowband(0), mavg(0);

  bandwidth = TSMBollingerBands(length,nsd);
  mavg = average(close,length);
  highband = mavg + bandwidth;
  lowband = mavg - bandwidth;
  plot1(highband,"TSMBBupper");
  plot2(lowband,"TSMBBlower");
