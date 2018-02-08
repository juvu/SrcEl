Inputs: nos(4),lenl(3),kl(0.15),lens(3),ks(3.57),adxlen(21),adxlimit(26),alfa(.2);
Inputs: stopl(1700),stops(900),brkl(1500),brks(500),tl(1500),ts(1900),
        tl1(10000),ts1(15000),minmcp(250);

Vars: upperk(0,data2),lowerk(0,data2),adxval(0,data2),mcp(0);
Vars: underK(false,data2),overK(false,data2), t2(0);

if barstatus(2) = 2 then begin
 upperk = KeltnerChannel(h,lenl,kl)data2;
 lowerk = KeltnerChannel(l,lens,-ks)data2;
 upperk = alfa*upperk + (1-alfa)*upperk[1];
 lowerk = alfa*lowerk + (1-alfa)*lowerk[1];
 adxval = adx(adxlen)data2;
 underK = c data2 < upperk;
 overK = c data2 > lowerk;
 t2 = t data2;
end;

mcp = MM.MaxContractProfit;

if t > 800 and t < 2200 then begin
 
 if marketposition <> 0 then begin
  
  setstopshare;
  
  //STOPLOSS
  setstoploss(iff(marketposition=1,stopl,stops));
  if mcp < minmcp/bigpointvalue then begin
   if marketposition = 1 then sell("xl.stbr.s") next bar at entryprice + (mcp - stopl/bigpointvalue) stop;
   if marketposition = -1 then buytocover("xs.stbr.s") next bar at entryprice - (mcp - stops/bigpointvalue) stop;
  end;
  
  //BREAKEVEN
  if marketposition = 1 and mcp > brkl/bigpointvalue then
   sell("xl.brk.s") next bar at entryprice + 100/bigpointvalue stop;
  if marketposition = -1 and mcp > brks/bigpointvalue then
   buytocover("xs.brk.s") next bar at entryprice - 100/bigpointvalue stop;
  
  //MODAL EXIT
  if currentcontracts = nos and nos > 1 then begin
   if marketposition = 1 then sell("tl") nos/2 shares next bar at entryprice + tl/bigpointvalue limit;
   if marketposition = -1 then buytocover("ts") nos/2 shares next bar at entryprice - ts/bigpointvalue limit;
  end;
  
  //PROFIT TARGET - TRAILING STOP
  if currentcontracts = nos/2 then begin
   if marketposition = 1 then begin
    setprofittarget(tl1);
   end;
   if marketposition = -1 then begin
    setprofittarget(ts1);
   end;
  end;
 
 end;
   
 //ENGINE
 if adxval < adxlimit and 800 < t2 and t2 < 2200 then begin
  if marketposition < 1 and underK and c < upperk then
   buy("long") nos shares next bar at upperk stop;
  if marketposition > -1 and overK and c > lowerk then
   sellshort("short") nos shares next bar at lowerk stop;
 end;
 
end;
