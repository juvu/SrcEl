[LegacyColorValue = TRUE];

{ TSMMompcVol: Momentum Percentage Volume
  Copyright 1999-2004, P.J.Kaufman. All rights reserved.
}
  inputs:  length(20);

  plot1(TSMMompcVol(close,length),"TSMMom%Vol");
