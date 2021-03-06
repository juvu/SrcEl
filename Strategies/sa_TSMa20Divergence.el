[LegacyColorValue = TRUE];

{ TSM Divergence: 
  Single and double divergence using TSMSwing and TSMIndex 
  Copyright 1994-2004, P.J.Kaufman.  All rights reserved. }

{CAUTION: THIS IS A COMPLEX PROGRAM AND THERE IS NO ASSURANCE
 THAT ALL COMBINATIONS OF PRICE AND INDICATOR VALUES HAVE BEEN VERIFIED.
 IT IS THE USER'S RESPONSIBILITY TO VERIFY THAT THIS PROGRAM IS ACCURATE
 BEFORE USING IT. IT IS INTENDED TO PROVIDE A VERY INTERESTING APPROACH
 TO DIVERGENCE THAT MIGHT PROVE USEFUL FOR TRADERS.}

{ INPUT for TSMSwing
  diverge  = 1, single;  2, double
  swing    = price swing in %
  strength = decline in current indicator high (or low) in percent, from last high 
  length   = number of periods in stochastic
  type     = 0, normal price;  1, 3-month rates; 2, bonds
  exit     = value added or subtracted from 50 for exit criteria
  fastx    = close-out when slowK stochastic touches this value
 }
  input: diverge(1), swing(2.0), strength(5), length(5), type(0), exit(0), 
          fastx(10);

  vars:  pcswing(0), last(0), curhigh(0), curlow(0), swhigh(0), swlow(0) ,
            swhigh1(0), swlow1(0), highbar(0), highbar1(0), STslowk(0),
            lowbar(0), lowbar1(0), chighbar(0), clowbar(0), exittype(0),
            STtoday(0), SThigh(0), STlow(0), curSThigh(0), curSTlow(0),
            xhigh(0), xlow(0), xclose(0),signal(0),
            highclose(0), lowclose(0), chighprice(0), clowprice(0);

  pcswing = swing/100.;
  STslowk = SlowK(length);
  STtoday = SlowD(length);

  xclose = close;
  xhigh = high;
  xlow = low;
  if type = 1 then begin
	xclose = 100. - close;
      xhigh   = 100. - low;
      xlow = 100. - high;
      end;
  if type = 2 then begin
      xclose = 800 / close;
      xhigh = 800 / low;
      xlow = 800 / high;
      end;
{ SWINGS: INITIALIZE MOST RECENT HIGH AND LOW }
  if currentbar = 1 then begin
{ Initialize curhigh and curlow }
      curhigh = xhigh;                {current high price}
      curlow  = xlow;                  {current low price}
      end;
                   
{ SEARCH FOR A NEW HIGH }
  if  last<>1 then begin
      if xhigh > curhigh  then begin
         curhigh = xhigh;          {save values at new high}
         curSThigh = STtoday;
         chighbar = currentbar;
         end;
      if xlow < curhigh - curhigh*pcswing  then begin
         last = 1;               {last high fixed}
         if type = 0 and exittype = -1 then exittype = 0;
         if type <> 0 and exittype = 1 then exittype = 0;
         swhigh1  = swhigh;     {previous high}
         highbar1 = highbar;
         swhigh   = curhigh;     {new verified high}
         highbar   = chighbar;
         curlow = xlow;           {initialize new lows}
         if type = 0 then begin
                SThigh = curSThigh;
                highclose = swhigh;
                end
             else begin
                STlow = curSThigh;
                lowclose = close[currentbar - highbar];
             end;
         clowbar = currentbar;
         end;
      end;

{ SEARCH FOR A NEW LOW }
  if last <> -1 then begin
   if xlow < curlow then begin
      curlow = xlow;                  {save values at new lows}
      curSTlow = STtoday;
      clowbar = currentbar;
      end;
   if xhigh > curlow + curlow*pcswing then begin
      last = -1;
      if type = 0 and exittype = 1 then exittype = 0;
      if type <> 0 and exittype = -1 then exittype = 0;
      swlow1  = swlow;
      lowbar1 = lowbar;
      swlow   = curlow;
      lowbar   = clowbar;
      curhigh = xhigh;          {initialize current high}
      if type = 0 then begin
             STlow = curSTlow;
             lowclose = swlow;
             end
          else begin
             SThigh = curSTlow;
             highclose = close[currentbar - lowbar];
          end;
      chighbar = currentbar;
      end;
   end;

{ DIVERGENCE LOGIC }
  if type = 0 then begin
       chighprice = curhigh;
       clowprice   = curlow;
       end
    else begin
       chighprice = high[currentbar - lowbar];
       clowprice = low[currentbar - highbar];
    end;
    

{ SINGLE DIVERGENCE }
  if diverge = 1 then begin
   If (((type = 0 and last = -1) or (type <> 0 and last = 1)) and 
       exittype <> -1 and close > highclose and high = chighprice and
       STslowk > fastx and (STtoday[1] > 50+exit or STtoday < STtoday[1]) and
       STtoday < SThigh - strength) then begin
          sell short this bar close;
          signal = -1;
          exittype = 0;
          end;
   if (((type = 0 and last = 1) or (type <> 0 and last = -1)) and 
       exittype <> 1 and close < lowclose and low = clowprice and 
       STslowk < 100-fastx and (STtoday[1] < 50-exit or STtoday > STtoday[1]) and
       STtoday > STlow + strength) then begin
           buy this bar close;
           signal = 1;
           exittype = 0;
           end;
   end;

{ DOUBLE DIVERGENCE - MIN ON CURRENT STOCH ONLY }
  if diverge = 2 then begin
   If last = -1 and xhigh = curhigh and STslowk > fastx and 
       (STtoday[1] > 50+exit or STtoday < STtoday[1]) then begin
       If xclose > swhigh and swhigh > swhigh1 and
          STtoday < SThigh - strength and 
          SThigh < SlowD(length)[currentbar - highbar1] then begin
          if type = 0 then begin
              sell short this bar close;
              signal = -1;
              exittype = 0;
              end
          else begin
              buy this bar close;
              signal = 1;
              exittype = 0;
              end;
          end;
       end;
   if last = 1 and xlow = curlow and STslowk < 100-fastx and 
       (STtoday[1] < 50-exit or STtoday > STtoday[1]) then begin
       if  xclose < swlow and swlow < swlow1 and
           STtoday > STlow + strength and
           STlow > SlowD(length)[currentbar - lowbar1] then begin
           if type = 0 then buy this bar close else sell short this bar close;
           end;
       end;
   end;

{ Get out if divergence disappears or swing reverses }
  if (STtoday > SThigh or STtoday=100) and signal = -1 then begin
    buy to cover this bar close;
    signal = 0;
    exittype = -1;
    end;
  if (STtoday < STlow or STtoday=0) and signal = 1 then begin
    sell this bar close;
    signal = 0;
    exittype = 1;
    end;

{ Get out if Stochastic reverses after crossing thresholds }
  if STslowk <= fastx or (STtoday[1] < 50+exit and STtoday > STtoday[1])
    and signal = -1 then begin
    buy to cover this bar close;
    exittype = -1;
    signal = 0;
    end;
  if STslowk >= 100-fastx or (STtoday[1] > 50-exit and STtoday < STtoday[1])
    and signal = 1 then begin
    sell this bar close;
    signal = 0;
    exittype = 1;
    end;

  print(date:6:0,high:3:2,low:3:2,close:3:2,highclose:3:2,lowclose:3:2);
  print(curhigh:3:2,curlow:3:2,swhigh:3:2,swlow:3:2);
  print(STtoday:3:1,STlow:3:1,SThigh:3:1,STslowk:3:1,signal:3:0,exittype:3:0);
