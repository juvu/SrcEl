{********* - MM.G1.TF.BUND - **********
 Engine:    TF
 Author:    Matteo Mentella
 Portfolio: G1
 Market:    BUND
 TimeFrame: 60 min. / 14 ore
 BackBars:  50
 Date:      23 Set 2010
**************************************}
{*************************************}
{*************************************}
Inputs: nos(2),alphal(0.762),flenl(13),rngpctl(0.16),alphas(0.172),flens(9),rngpcts(.273),mnymngmnt(1);
Inputs: stopl(1350),stopdl(1200),modl(1200),tl(1700);
Inputs: stops(1350),stopds(1200),mods(1200),ts(2200);

vars: trendl(0,data2),triggerl(0,data2),cyclel(0,data2),fishl(0,data2),trends(0,data2),triggers(0,data2),cycles(0,data2),fishs(0,data2),engl(true,data2),engs(true,data2);
vars: entrylong(0,data2),entryshort(0,data2),stopval(0),minstop(-1),maxstop(999999),mkt(true),stp(true),mcp(0),trade(true),mp(0),yc(0);
{*************************************}
{*************************************}
if d <> d[1] then begin trade = true; yc = c[1]; end;
mp = currentcontracts*marketposition;
if mp <> mp[1] then trade = false;
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
 
end;

mcp = MM.MaxContractProfit;
{*************************************}
{*************************************}
if mnymngmnt = 1 and marketposition <> 0 then begin
 
 setstopshare;
 
 if marketposition = 1 then begin
  
  //STOPLOSS
  stopval = entryprice - (stopl - (slippage+commission))/bigpointvalue;
  stp     = c > stopval and stopval > minstop;
  mkt     = c <= stopval;
  
  if stp then setstoploss(stopl);
  if mkt then sell("xl.stpls") next bar at market;
  
  //DAILY STOPLOSS
  stopval = yc - stopdl/bigpointvalue;
  stp     = c > stopval and stopval > minstop;
  mkt     = c <= stopval;
  
  if d > entrydate then begin
   if stp then sell("xl.stpd") next bar at stopval stop;
   if mkt then sell("xl.stpd.m") next bar at market;
  end;
  
  //PROFIT TARGET
  stopval = entryprice + (tl + (slippage+commission))/bigpointvalue;
  stp     = c < stopval and stopval < maxstop;
  mkt     = c >= stopval;
  
  if stp then setprofittarget(tl);
  if mkt then sell("xl.prftrgt") next bar at market;
  
  //MODAL EXIT
  stopval = entryprice + modl/bigpointvalue;
  stp     = currentcontracts = nos and c < stopval and stopval < maxstop;
  mkt     = currentcontracts = nos and c >= stopval;
  
  if stp then sell("xl.modl") nos/2 shares next bar at stopval limit;
  if mkt then sell("xl.modl.m") nos/2 shares next bar at market;
  
 end else begin
  
  //STOPLOSS
  stopval = entryprice + (stops - (slippage+commission))/bigpointvalue;
  stp     = c < stopval and stopval < maxstop;
  mkt     = c >= stopval;
  
  if stp then setstoploss(stops);
  if mkt then buytocover("xs.stpls") next bar at market;
  
  //DAILY STOPLOSS
  stopval = yc + stopds/bigpointvalue;
  stp     = c < stopval and stopval < maxstop;
  mkt     = c >= stopval;
  
  if d > entrydate then begin
   if stp then buytocover("xs.stpd") next bar at stopval stop;
   if mkt then buytocover("xs.stpd.m") next bar at market;
  end;
  
  //PROFIT TARGET
  stopval = entryprice - (ts + (slippage+commission))/bigpointvalue;
  stp     = c > stopval and stopval > minstop;
  mkt     = c <= stopval;
  
  if stp then setprofittarget(ts);
  if mkt then buytocover("xs.prftrgt") next bar at market;
  
  //MODAL EXIT
  stopval = entryprice - mods/bigpointvalue;
  stp     = currentcontracts = nos and c > stopval and stopval > minstop;
  mkt     = currentcontracts = nos and c <= stopval;
  
  if stp then buytocover("xs.modl") nos/2 shares next bar at stopval limit;
  if mkt then buytocover("xs.modl.m") nos/2 shares next bar at market;

 end;
 
end;
{*************************************}
{*************************************}
if trade then begin
 if marketposition < 1 and engl then
  buy nos shares next bar entrylong limit; 
if marketposition > -1 and engs then
 sellshort nos shares next bar entryshort limit;
end;
