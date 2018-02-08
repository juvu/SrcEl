[LegacyColorValue = TRUE];

{ TSMParabolic : Parabolic Price/Time System
  This version of the Parabolic system was written by
  Sam Tennis, VISTA Research and Trading, Inc., 
  8103 Camino Real, South Miami, FL 33143, Email: skt@vista.com
  Modified by P.J.Kaufman.
  Copyright 1997-2004, P.J.Kaufman. All rights reserved. }

{ NOTE: When using this plot, place the graph on the same window as the price series,
	scale the same as price, and set the style to "point" to see the SAR correctly }

	input: AFmin(.02), AFinc(.02), AFmax(.02);

	plot1(TSMParabolic(AFmin,AFinc,AFmax),"TSMPara");
