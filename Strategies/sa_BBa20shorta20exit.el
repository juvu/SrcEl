[LegacyColorValue = TRUE];

{***************************************

Written by: Emi 24gen05

 Description: if C < prev. Close and < BBhi

****************************************}
Inputs: Length(9), StdDevDn(2);
Variables: BBtop(0),BBbot(0);

BBtop = BollingerBand(Close, Length, StdDevDn);
BBBot = BollingerBand(Close, Length, -StdDevDn);


Condition1 = C>=C[1];
Condition2 = C>BBbot;
Condition3 = L<L[1];

If Condition1 AND Condition2 AND Condition3 Then
	ExitShort ("BBlow brk") Next Bar at Open;







