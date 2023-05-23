function alpha = flip_angle(vent_half1,vent_half2, n)
    vent_half1 = abs(vent_half1);
    vent_half2 = abs(vent_half2);
    vent_ratio = abs(vent_half2./vent_half1).^(2/n);
    vent_ratio = medfilt3(vent_ratio);
    vent_ratio(vent_ratio > 1 ) = 1;
    alpha = (180/pi)*acos(vent_ratio);
    alpha = medfilt3(alpha);
end