vars: id(0);

if currentbar > 1 then begin
 if d < 1120501 then begin
 
 
 {--------------------------}
 {--------------------------}
 
 {******* - MM.LUGA.K1.BOBL - ********
  Engine:    TF
  Author:    Matteo Mentella
  Portfolio: LUGA
  Market:    BOBL
  TimeFrame: 60 min. / 14 ore
  BackBars:  50
  Date:      14 Apr 2011
 **************************************}
 {*************************************}
 {*************************************}
 vars: alphal(0.95),flenl(10),rngpctl(0.18);
 vars: alphas(0.02),flens(33),rngpcts(0.45);
 vars: stopl(1100),funkl(1250),brkl(750),tl(2800);
 vars: stops(1100),funks(650 ),brks(800),ts(1850);
 
 vars: trendl(0,data2),triggerl(0,data2),cyclel(0,data2),fishl(0,data2),engl(true,data2),entrylong(0,data2);
 vars: trends(0,data2),triggers(0,data2),cycles(0,data2),fishs(0,data2),engs(true,data2),entryshort(0,data2);
 
 vars: stpv(0),mkt(true),stp(true),trade(0),dru(0),mcp(0),fnkl(false),fnks(false),bpv(1/bigpointvalue),nos(1);
 {*************************************}
 {*************************************}
 if d <> d[1] then begin  
  trade = 0;
  fnkl  = false;
  fnks  = false;
 end;
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

 dru = MM.DailyRunup;
 mcp = MM.MaxContractProfit;
 {*************************************}
 {*************************************}
 if marketposition <> 0 then begin
  
  if barssinceentry = 0 then begin
   trade = trade + 1;
   nos   = currentcontracts;
  end;
 
  if marketposition = 1 then begin
   
   //STOPLOSS
   stpv = entryprice - stopl*bpv;
   stp  = c > stpv;
   mkt  = c <= stpv;
   
   if stp then sell("xl.stp") next bar stpv stop
   else if mkt then sell("xl.stp.m") this bar c;
   
   //DAILY STOPLOSS
   stpv = c - (dru + funkl*currentcontracts)*bpv;
   stp  = c > stpv;
   mkt  = c <= stpv;
   
   if stp then sell("xl.funk") next bar stpv stop
   else if mkt then sell("xl.funk.m") this bar c;
   
   //BREAKEVEN
   stpv = entryprice + 10*MinMove points;
   stp  = mcp > brkl*bpv and c > stpv;
   mkt  = mcp > brkl*bpv and c <= stpv;
   
   if stp then sell("xl.brk") next bar stpv stop
   else if mkt then sell("xl.brk.m") this bar c;
   
   //PROFIT TARGET
   stpv = entryprice + tl*bpv;
   stp  = c < stpv;
   mkt  = c >= stpv;
   
   if stp then sell("xl.trgt") next bar stpv limit
   else if mkt then sell("xl.trgt.m") this bar c;
   
  end else begin
   
   //STOPLOSS
   stpv = entryprice + stops*bpv;
   stp  = c < stpv;
   mkt  = c >= stpv;
   
   if stp then buy to cover("xs.stp") next bar stpv stop
   else if mkt then buy to cover("xs.stp.m") this bar c;
   
   //DAILY STOPLOSS
   stpv = c + (dru + funks*currentcontracts)*bpv;
   stp  = c < stpv;
   mkt  = c >= stpv;
   
   if stp then buy to cover("xs.funk") next bar stpv stop
   else if mkt then buy to cover("xs.funk.m") this bar c;
   
   //BREAKEVEN
   stpv = entryprice - 10*MinMove points;
   stp  = mcp > brks*bpv and c < stpv;
   mkt  = mcp > brks*bpv and c >= stpv;
   
   if stp then buy to cover("xs.brk") next bar stpv stop
   else if mkt then buy to cover("xs.brk.m") this bar c;
   
   //PROFIT TARGET
   stpv = entryprice - ts*bpv;
   stp  = c > stpv;
   mkt  = c <= stpv;
   
   if stp then buy to cover("xs.trgt") next bar stpv limit
   else if mkt then buy to cover("xs.trgt.m") this bar c;
 
  end;
  
 end;
 {*************************************}
 {*************************************}
 fnkl = dru <= -funkl*nos;
 fnks = dru <= -funks*nos;
 {*************************************}
 {*************************************}
 if trade = 0 then begin
  if not fnkl and marketposition < 1 and engl then
   buy("el") next bar entrylong limit; 
 if not fnks and marketposition > -1 and engs then
  sellshort("es") next bar entryshort limit;
 end;

 
 {--------------------------}
 {--------------------------}
 
 
end else begin
 text_setlocation(id,d,t,c);
 text_setstring(id,"Periodo di Trading scaduto. Aggiornare la Licenza o contattare 'm.mentella@gmail.com'. " + 
                   "Potrebbero essere rimaste delle posizioni aperte in Banca.");
end;

end else begin
 id = text_new(d,t,c,"");
 text_setcolor(id,white);
 text_setsize(id,10);
 text_setstyle(id,1,1);
end;

