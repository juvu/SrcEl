[LegacyColorValue = TRUE];

{ McGinley Dynamic
  Copyright 1998-2004, P.J.Kaufman. All rights reserved.
  Indicator based on the work of John McGinley, Technical Trends, P.O. Box 792, Wilton, CT 06897
  Definitions:
	MD = McGinley Dynamic
 	k  = constant, preset to .60 (60% of a selected moving average speed, p)
	period  = the moving average speed }

	input:	period(20);
	vars:	MD(0), k(.60);

	if currentbar <= period then MD = close
		else begin
			MD = MD[1] + (close - MD[1]) / (k*period*power((close / MD[1]),4));
		end;
	plot1 (MD, "MD");

