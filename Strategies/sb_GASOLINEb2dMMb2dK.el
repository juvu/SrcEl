Inputs: nos(2),lenl(20),kl(1.170),lens(20),ks(2.744),adxlen(14),adxlimit(30);
Inputs: stopl(100000),stopdl(1450),brkl(100000),modl(100000),tl(100000),tld(100000),trsl(100000);
Inputs: stops(100000),stopds(1350),brks(100000),mods(100000),ts(100000),tsd(100000),trss(100000);

vars: upk(0,data2),lok(0,data2),el(true,data2),es(true,data2),engine(true,data2),adxval(0,data2);
vars: trade(true),stopval(0),minstop(-1),maxstop(999999),stp(false),mkt(false),mcp(0),yc(0),settle(false);

if currentbar > maxlist(lenl,lens) then begin

if d <> d[1] then begin
 trade = true;
 settle = false;
end;

if not settle and 2030 < t then begin
 settle = true;
 yc = c[1];
 maxstop = yc + .25;
 minstop = yc - .25;
end;

if barstatus(2) = 2 then begin
 upk = KeltnerChannel(h,lenl,kl)data2;
 lok = KeltnerChannel(l,lens,-ks)data2;
 
 el = c data2 < upk;
 es = c data2 > lok;
 
 adxval = adx(adxlen)data2;
 
 engine = 800 < t data2 and t data2 < 2200;
end;

if marketposition <> 0 and barssinceentry = 0 then trade = false;
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
   if stp then buytocover("xs.trgtd") next bar at stopval limit;
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

condition1 = 1100101 < d;

if trade and engine and adxval < adxlimit then begin
 if marketposition < 1 and el and c < upk then
  buy("el") nos shares next bar at upk stop;
 if marketposition > -1 and es and c >lok then
  sellshort("es") nos shares next bar at lok stop;
end;

end;

//if d = 1050826 then setexitonclose;
