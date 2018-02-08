Inputs: SumLength(21);

vars: vol(0),ii(0),var0(0);


if bartype >= 2 then vol = Volume else vol = Ticks;

var0 = summation(vol,21);

ii = Summation((2*c - h - l)/iff((h-l)<>0,h-l,4*c),sumlength)*vol;

if var0 <> 0 then ii = 100*ii/var0 else ii = ii[1];

plot1(ii,"Intraday Intensity Index");
