{****** - MM.RA.TF.TBOND - ********
 Engine:    TF
 Author:    Matteo Mentella
 Portfolio: RA
 Market:    TBOND
 TimeFrame: 2 + 1350 min.
 BackBars:  50
 Date:      30 Giu 2011
*************************************}
inputs: alphal(0.01),flenl(24),rngpctl(0.04);
inputs: alphas(0.97),flens(35),rngpcts(0.90);
inputs: stopl(287),funkl(312),modl(2.04);
inputs: stops(245),funks(390),mods(-.28),brks(320),ts(24);

vars: trendl(0,data2),triggerl(0,data2),cyclel(0,data2),fishl(0,data2);
vars: trends(0,data2),triggers(0,data2),cycles(0,data2),fishs(0,data2);

vars: engl(true,data2),engs(true,data2),entrylong(0,data2),entryshort(0,data2);

vars: VolD(0,data2),VolW(0,data2);

vars: stpv(0),mkt(true),stp(true),trades(0),dru(0),mcp(0),fnkl(false),fnks(false),nos(1);
{*************************************}
{*************************************}
if d <> d[1] then begin
 trades = 0;
 fnkl   = false;
 fnks   = false;
end;

if marketposition <> 0 and barssinceentry = 0 then begin
 trades = trades + 1;
 nos    = currentcontracts;
end;

dru = MM.DailyRunup;
mcp = MM.MaxContractProfit;
{*************************************}
{*************************************}
if barstatus(2) = 2 then begin
 
 MM.ITrend(medianprice,alphal,trendl,triggerl)data2;
 cyclel = MM.Cycle(medianprice,alphal)data2;
 fishl  = MM.FisherTransform(cyclel,flenl,true)data2;
 
 MM.ITrend(medianprice,alphas,trends,triggers)data2;
 cycles = MM.Cycle(medianprice,alphas)data2;
 fishs  = MM.FisherTransform(cycles,flens,true)data2;
 
 engl = fishl > fishl[1] and triggerl > trendl;
 engs = fishs < fishs[1] and triggers < trends;
 
 entrylong  = c data2 - rngpctl*(h data2 - l data2);
 entryshort = c data2 + rngpcts*(h data2 - l data2);
 
 VolD = (Range data2) * PriceScale/MinMove;
 VolW = IntPortion(Average(VolD,5)data2);
 
 
end;
{*************************************}
{*************************************}
if 858 < t and t < 2300 then begin
 
 if marketposition = 1 then begin
  
  //STOPLOSS
  stpv = entryprice - stopl*MinMove points;
  stp  = c > stpv;
  mkt  = c <= stpv;
  
  if stp then sell("xl.stpl") next bar stpv stop
  else if mkt then sell("xl.stpl.m") this bar c;
  
  //DAILY STOPLOSS
  stpv = c - (dru/(nos*bigpointvalue) + funkl*MinMove points);
  stp  = c > stpv;
  mkt  = c <= stpv;
  
  if stp then sell("xl.funk") next bar stpv stop
  else if mkt then sell("xl.funk.m") this bar c;
  
  //MODAL
  stpv = entryprice + IntPortion((1 + modl)*VolW)*MinMove points;
  stp  = currentcontracts > 1 and c < stpv;
  mkt  = currentcontracts > 1 and c >= stpv;
  
  if stp then sell("xl.mod") nos/2 shares next bar stpv limit
  else if mkt then sell("xl.mod.m") nos/2 shares this bar c;
  
 end else if marketposition = -1 then begin
  
  //STOPLOSS
  stpv = entryprice + stops*MinMove points;
  stp  = c < stpv;
  mkt  = c >= stpv;
  
  if stp then buy to cover("xs.stpl") next bar stpv stop
  else if mkt then buy to cover("xs.stpl.m") this bar c;
  
  //DAILY STOPLOSS
  stpv = c + (dru/(nos*bigpointvalue) + funks*MinMove points);
  stp  = c < stpv;
  mkt  = c >= stpv;
  
  if stp then buy to cover("xs.funk") next bar stpv stop
  else if mkt then buy to cover("xs.funk.m") this bar c;
  
  //BREAKEVEN
  stpv = entryprice - 24*MinMove points;
  stp  = mcp >= brks*MinMove points and c < stpv;
  mkt  = mcp >= brks*MinMove points and c >= stpv;
  
  if stp then buy to cover("xs.brk") next bar stpv stop
  else if mkt then buy to cover("xs.brk.m") this bar c;
  
  //MODAL
  stpv = entryprice - IntPortion((1 + mods)*VolW)*MinMove points;
  stp  = currentcontracts > 1 and c > stpv;
  mkt  = currentcontracts > 1 and c <= stpv;
  
  if stp then buy to cover("xs.mod") nos/2 shares next bar stpv limit
  else if mkt then buy to cover("xs.mod.m") nos/2 shares this bar c;
  
  //TAKE PROFIT
  stpv = entryprice - IntPortion((1 + ts)*VolW)*MinMove points;
  stp  = currentcontracts < nos and c > stpv;
  mkt  = currentcontracts < nos and c <= stpv;
  
  if stp then buy to cover("xs.tp") next bar stpv limit
  else if mkt then buy to cover("xs.tp.m") this bar c;
  
 end;
 
end;
{*************************************}
{*************************************}
fnkl = dru <= -funkl*nos;
fnks = dru <= -funks*nos;
{*************************************}
{*************************************}
//condition1 = d < 1080925 or 1100519 < d;
//if not condition1 then setexitonclose;

if trades < 1 then begin

 if not fnkl and marketposition < 1 and engl then
  buy next bar entrylong limit;
  
 if not fnks and marketposition > -1 and engs then
  sell short next bar entryshort limit;
  
end;
