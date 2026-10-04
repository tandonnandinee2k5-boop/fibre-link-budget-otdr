function fig = plotMarginSweep(Lmax, nSplice, nConn, lSplice, lConn, Ptx, sens, safety)
%PLOTMARGINSWEEP Power margin vs fibre length for all four fibre/wavelength cases.
%   Where a curve crosses 0 dB is the maximum reach of that fibre.
    Ls    = linspace(0.1, Lmax, 300);
    types = {'Single-mode', 'Single-mode', 'Multimode', 'Multimode'};
    wls   = [1310 1550 850 1300];
    fig = figure('Name', 'Margin vs Length');
    hold on;
    for k = 1:4
        a = getAttenuation(types{k}, wls(k));
        m = (Ptx - (a * Ls + nSplice * lSplice + nConn * lConn)) - sens - safety;
        plot(Ls, m, 'LineWidth', 1.3, 'DisplayName', sprintf('%s %d nm', types{k}, wls(k)));
    end
    yline(0, 'k--', 'Link limit', 'HandleVisibility', 'off');
    ylim([-40 30]);
    grid on; legend('Location', 'southwest');
    xlabel('Fibre length (km)'); ylabel('Power margin (dB)');
    title('Power margin vs length (crossing 0 dB = maximum reach)');
end