{******** - MM.RA.B.CAC40 - *********
 Engine:    Keltner
 Author:    Matteo Mentella
 Portfolio: RA
 Market:    CAC
 TimeFrame: 1 + 15 min.
 BackBars:  50
 Date:      09 Set 2011
*************************************}
input: lenl(26),kl(5),lens(30),ks(5);

input: stopl(2000),funkl(0900),brkl(850),tl(1900);
input: stops(2500),funks(2800),brks(700),ts(3850);

var: upk(0,data2),lok(0,data2),el(true,data2),es(true,data2),goL(true),goS(true);
var: trades(0),dru(0),mcp(0),nos(1),fnkl(false),fnks(false),bpv(1/bigpointvalue);

var: orderL(true),orderS(true);

var: stpw(0),stpv(0),stp(true),mkt(true),reason(0),position(0),stoploss(10),daystop(11),breakeven(12);
{***************************}
{***************************}
if d <> d[1] then begin
 trades = 0;
 fnkl   = false;
 fnks   = false;
 goL    = true;
 goS    = true;
end;

if marketposition <> 0 and barssinceentry = 0 then begin
 trades = trades + 1;
 nos    = currentcontracts;
 goL    = marketposition = -1;
 goS    = marketposition =  1;
end;
{***************************}
{***************************}
if barstatus(2) = 2 then begin
 upk = BollingerBand(h,lenl,kl)data2;
 lok = BollingerBand(l,lens,-ks)data2;
 
 el = c data2 < upk;
 es = c data2 > lok;
end;

dru = MM.DailyRunup;
mcp = MM.MaxContractProfit;

fnkl = dru <= -funkl*nos;
fnks = dru <= -funks*nos;
{***************************}
{***************************}
if trades < 2 then begin

 if goL and not fnkl and marketposition < 1 and el and c < upk then begin
  buy("el") next bar at upk stop;
  orderL = true;
 end else orderL = false;
  
 if goS and not fnks and marketposition > -1 and es and c > lok then begin
  sell short("es") next bar at lok stop;
  orderS = true;
 end else orderS = false;
 
end;
{***************************}
{***************************}
if marketposition = 1 then begin
 
 reason = position;
 stpw   = lok;
 
 //STOPLOSS
 stpv = entryprice - stopl*bpv;
 
 if orderL and stpv > stpw then begin
  reason = stoploss;
  stpw   = stpv;
 end else begin
  reason = stoploss;
  stpw   = stpv;
 end;
 
 //DAILY STOP
 stpv = c - (dru/nos + funkl)*bpv;
 
 if t < sessionendtime(0,1) and stpv > stpw then begin
  reason = daystop;
  stpw   = stpv;
 end;
 
 //BREAKEVEN
 stpv = entryprice + 40*MinMove points;
 
 if mcp > brkl*bpv and stpv > stpw then begin
  reason = breakeven;
  stpw   = stpv;
 end;
 
 stp = c >  stpw;
 mkt = c <= stpw;
 
 if reason = stoploss then begin
  if stp then sell("xl.stp") next bar stpw stop
  else if mkt then sell("xl.stp.m") this bar c;
 end else
 if reason = daystop then begin
  if stp then sell("xl.funk") next bar stpw stop
  else if mkt then sell("xl.funk.m") this bar c;
 end else
 if reason = breakeven then begin
  if stp then sell("xl.brk") next bar stpw stop
  else if mkt then sell("xl.brk.m") this bar c;
 end;
 
 stpv = entryprice + tl*bpv;
 stp  = c <  stpv;
 mkt  = c >= stpv;
 
 if stp then sell("xl.tp") next bar stpv limit
 else if mkt then sell("xl.tp.m") this bar c;
 
end else if marketposition = -1 then begin
 
 reason = position;
 stpw   = upk;
 
 //STOPLOSS
 stpv = entryprice + stops*bpv;
 
 if orderS and stpv < stpw then begin
  reason = stoploss;
  stpw   = stpv;
 end else begin
  reason = stoploss;
  stpw   = stpv;
 end;
 
 //DAILY STOP
 stpv = c + (dru/nos + funks)*bpv;
 
 if t < sessionendtime(0,1) and stpv < stpw then begin
  reason = daystop;
  stpw   = stpv;
 end;
 
 //BREAKEVEN
 stpv = entryprice - 12*MinMove points;
 
 if mcp > brks*bpv and stpv < stpw then begin
  reason = breakeven;
  stpw   = stpv;
 end;
 
 stp = c <  stpw;
 mkt = c >= stpw;
 
 if reason = stoploss then begin
  if stp then buy to cover("xs.stp") next bar stpw stop
  else if mkt then buy to cover("xs.stp.m") this bar c;
 end else
 if reason = daystop then begin
  if stp then buy to cover("xs.funk") next bar stpw stop
  else if mkt then buy to cover("xs.funk.m") this bar c;
 end else
 if reason = breakeven then begin
  if stp then buy to cover("xs.brk") next bar stpw stop
  else if mkt then buy to cover("xs.brk.m") this bar c;
 end;
 
 stpv = entryprice - ts*bpv;
 stp  = c >  stpv;
 mkt  = c <= stpv;
 
 if stp then buy to cover("xs.tp") next bar stpv limit
 else if mkt then buy to cover("xs.tp.m") this bar c;
 
end;
{***************************}
{***************************}
