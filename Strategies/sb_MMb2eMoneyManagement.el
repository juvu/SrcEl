Inputs: nos(0);
Inputs: stopl(100000),stopdl(100000),stops(100000),stopds(100000),brkl(100000),brks(100000),modl(100000),mods(100000);
Inputs: tl(100000),tld(100000),ts(100000),tsd(100000),trsl(100000),trss(100000);
Inputs: stopperc(0);

vars: stopval(0),minstop(-1),maxstop(999999),stp(false),mkt(false),mcp(0),yc(0);

if d <> d[1] and stopperc <> 0 then begin 
 maxstop = c[1]*(1+stopperc);
 minstop = c[1]*(1-stopperc);
 yc = c[1];
end;

mcp = MM.MaxContractProfit;

if marketposition <> 0 then begin
  
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
  
  //DAILY PROFIT TARGET
  stopval = yc + tld/bigpointvalue;
  stp     = c < stopval and stopval < maxstop;
  mkt     = c >= stopval;
  
  if d > entrydate then begin
   if stp then sell("xl.trgtd") next bar at stopval limit;
   if mkt then sell("xl.trgtd.m") next bar at market;
  end;
  
  //BREAKEVEN
  stopval = entryprice + 100/bigpointvalue;
  stp     = mcp > brkl/bigpointvalue and minstop < stopval and stopval < c;
  mkt     = mcp > brkl/bigpointvalue and stopval >= c;
  
  if stp then sell("xl.brk") next bar at stopval stop;
  if mkt then sell("xl.brk.m") next bar at market;
  
  //MODAL EXIT
  stopval = entryprice + modl/bigpointvalue;
  stp     = currentcontracts = nos and c < stopval and stopval < maxstop;
  mkt     = currentcontracts = nos and c >= stopval;
  
  if stp then sell("xl.modl") nos/2 shares next bar at stopval limit;
  if mkt then sell("xl.modl.m") nos/2 shares next bar at market;
  
  //TRAILING STOP
  stopval = entryprice + (mcp - trsl/bigpointvalue);
  stp     = currentcontracts = nos/2 and minstop < stopval and stopval < c;
  mkt     = currentcontracts = nos/2 and c <= stopval;
  
  if stp then sell("xl.trs") next bar at stopval stop;
  if mkt then sell("xl.trs.m") next bar at market;
  
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
  
  //DAILY PROFIT TARGET
  stopval = yc - tsd/bigpointvalue;
  stp     = c > stopval and stopval > minstop;
  mkt     = c <= stopval;
  
  if d > entrydate then begin
   if stp then sellshort("xs.trgtd") next bar at stopval limit;
   if mkt then buytocover("xs.trgtd.m") next bar at market;
  end;
  
  //BREAKEVEN
  stopval = entryprice - 100/bigpointvalue;
  stp     = mcp > brks/bigpointvalue and maxstop > stopval and stopval > c;
  mkt     = mcp > brks/bigpointvalue and stopval <= c;
  
  if stp then buytocover("xs.brk") next bar at stopval stop;
  if mkt then buytocover("xs.brk.m") next bar at market;
  
  //MODAL EXIT
  stopval = entryprice - mods/bigpointvalue;
  stp     = currentcontracts = nos and c > stopval and stopval > minstop;
  mkt     = currentcontracts = nos and c <= stopval;
  
  if stp then buytocover("xs.modl") nos/2 shares next bar at stopval limit;
  if mkt then buytocover("xs.modl.m") nos/2 shares next bar at market;
  
  //TRAILING STOP
  stopval = entryprice - (mcp - trss/bigpointvalue);
  stp     = currentcontracts = nos/2 and maxstop > stopval and stopval > c;
  mkt     = currentcontracts = nos/2 and c >= stopval;
  
  if stp then buytocover("xs.trs") next bar at stopval stop;
  if mkt then buytocover("xs.trs.m") next bar at market;
  
 end;
  
end;
