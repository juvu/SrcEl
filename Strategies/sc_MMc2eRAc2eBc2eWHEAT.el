{******** - MM.RA.B.WHEAT - **********
 Engine:    BOLLINGER
 Author:    Matteo Mentella
 Portfolio: RA
 Market:    WHEAT
 TimeFrame: 60 min.
 BackBars:  5
 Date:      05 Lug 2011
**************************************}
inputs: lenl(11),kl(3.7),lens(9),ks(5),mnymngmnt(1);
inputs: stopl(1400),funkl(2000),tl(4700);
inputs: stops(2100),funks(1850),ts(2550);

vars: upb(0),lob(0),el(true),es(true),engine(true);
vars: trade(0),dru(0),fnkl(false),fnks(false),stpv(0),stp(true),mkt(true);
vars: maxstp(0),minstp(0),settle(false),mcp(0),nos(1);
{***************************}
{***************************}
if d <> d[1] then begin
 trade = 0;
 fnkl  = false;
 fnks  = false;
 settle = false;
end;

if not settle and t >= 2015 then begin
 settle = true;
 maxstp = c + 60;
 minstp = c - 60;
end;
{***************************}
{***************************}
upb = BollingerBand(h,lenl,kl);
lob = BollingerBand(l,lens,-ks);

el = c < upb;
es = c > lob;

engine = 800 < t  and t  < 2000;

if marketposition <> 0 and barssinceentry = 0 then begin
 trade = trade + 1;
 nos   = currentcontracts;
end;

dru = MM.DailyRunup;
mcp = MM.MaxContractProfit;
{***************************}
{***************************}
if mnymngmnt = 1 and 700 < t and t < 2300 then begin
 
 if marketposition = 1 then begin
  
  //STOPLOSS
  stpv = entryprice - stopl/bigpointvalue;
  stp  = c > stpv and stpv > minstp;
  mkt  = c <= stpv;
  
  if stp then sell("xl.stp") next bar stpv stop
  else if mkt then sell("xl.stp.m") this bar c;
  
  //DAILY STOP
  stpv = c - (dru/currentcontracts + funkl)/bigpointvalue;
  stp  = c > stpv and stpv > minstp;
  mkt  = c <= stpv;
  
  if stp then sell("xl.funk") next bar stpv stop
  else if mkt then sell("xl.funk.m") this bar c;
  
  //PROFIT TARGET
  stpv = entryprice + tl/bigpointvalue;
  stp  = c < stpv and stpv < maxstp;
  mkt  = c > stpv;
  
  if stp then sell("xl.prft") next bar stpv limit
  else if mkt then sell("xl.prft.m") this bar c;
  
 end else if marketposition = -1 then begin
  
  //STOPLOSS
  stpv = entryprice + stops/bigpointvalue;
  stp  = c < stpv and stpv < maxstp;
  mkt  = c >= stpv;
  
  if stp then buy to cover("xs.stp") next bar stpv stop
  else if mkt then buy to cover("xs.stp.m") this bar c;
  
  //DAILY STOP
  stpv = c + (dru/currentcontracts + funks)/bigpointvalue;
  stp  = c < stpv and stpv < maxstp;
  mkt  = c >= stpv;
  
  if stp then buy to cover("xs.funk") next bar stpv stop
  else if mkt then buy to cover("xs.funk.m") this bar c;
  
  //PROFIT TARGET
  stpv = entryprice - ts/bigpointvalue;
  stp  = c > stpv and stpv > minstp;
  mkt  = c <= stpv;
  
  if stp then buy to cover("xs.prft") next bar stpv limit
  else if mkt then buy to cover("xs.prft.m") this bar c;
  
 end;
  
end;
{***************************}
{***************************}
fnkl = dru <= -funkl*nos;
fnks = dru <= -funks*nos;
{***************************}
{***************************}
if trade < 1 and engine then begin
 
 if not fnkl and marketposition < 1 then begin
  stp = el and upb < maxstp;
  mkt = c > upb;
  
  if stp then buy("el") next bar upb stop
  else if mkt then buy("el.m") this bar c;
 end;
 
 if not fnks and marketposition > -1 then begin
  stp = es and lob > minstp;
  mkt = c < lob;
  
  if stp then sell short("es") next bar lob stop
  else if mkt then sell short("es.m") this bar c;
 end;
 
end;
{***************************}
{***************************}
