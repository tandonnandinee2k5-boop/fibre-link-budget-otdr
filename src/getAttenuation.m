function alpha = getAttenuation(fibreType, wavelength)
%GETATTENUATION Typical fibre attenuation in dB/km.
%   alpha = getAttenuation('Single-mode', 1550) returns 0.20
%   Valid: Single-mode 1310/1550 nm, Multimode 850/1300 nm.
    if strcmp(fibreType, 'Single-mode')
        wls = [1310 1550]; vals = [0.35 0.20];
    elseif strcmp(fibreType, 'Multimode')
        wls = [850 1300];  vals = [3.0 1.0];
    else
        error('Unknown fibre type: %s', fibreType);
    end
    idx = find(wls == wavelength, 1);
    if isempty(idx)
        error('Wavelength %d nm is not valid for %s fibre.', wavelength, fibreType);
    end
    alpha = vals(idx);
end
