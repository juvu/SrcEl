

variables:
	cur_delta(0),
	prev_delta(0),

	delta_volume(0),

	initialized(false);


if {initialized}1=1 then begin

	delta_volume = upticks - downticks;
	prev_delta = cur_delta[1];

	if ( delta_volume >= 0 ) then
		cur_delta = maxlist(0, prev_delta) + delta_volume
	else
		cur_delta = minlist(0, prev_delta) + delta_volume;

	if cur_delta >= 0 then begin
		plot1(cur_delta, "UpMomo");
		noplot(2);
	end
	else begin
		plot2(cur_delta, "DownMomo");
		noplot(1);
	end;

end;

initialized = initialized or lastbaronchart_s and barstatus = 2;


