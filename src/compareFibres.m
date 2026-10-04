function T = compareFibres(L, nSplice, nConn, lSplice, lConn, Ptx, sens, safety)
%COMPAREFIBRES Table comparing single-mode and multimode for the same link.
    types = {'Single-mode'; 'Single-mode'; 'Multimode'; 'Multimode'};
    wls   = [1310; 1550; 850; 1300];
    n = numel(wls);
    a = zeros(n,1); tot = a; mar = a; reach = a; works = strings(n,1);
    for k = 1:n
        a(k) = getAttenuation(types{k}, wls(k));
        x = calcLinkBudget(L, a(k), nSplice, nConn, lSplice, lConn, Ptx, sens, safety);
        tot(k) = x.totalLoss; mar(k) = x.margin; reach(k) = x.maxLen;
        if x.margin >= 0, works(k) = "Yes"; else, works(k) = "No"; end
    end
    T = table(string(types), wls, a, round(tot,2), round(mar,2), ...
              round(reach,1), works, 'VariableNames', ...
        {'Fibre','Wavelength_nm','dB_per_km','TotalLoss_dB','Margin_dB','MaxReach_km','Works'});
end
