function [figTrace, figLoss] = plotResults(z, tr, r, fibreType, wavelength)
%PLOTRESULTS OTDR trace figure and loss-breakdown bar chart.
    figTrace = figure('Name', 'OTDR Trace');
    plot(z, tr, 'LineWidth', 0.8); grid on;
    xlabel('Distance (km)'); ylabel('Backscatter level (dB, relative)');
    title(sprintf('Simulated OTDR: %s, %d nm', fibreType, wavelength));

    figLoss = figure('Name', 'Loss Breakdown');
    bar([r.fibreLoss r.spliceLoss r.connLoss r.totalLoss]);
    set(gca, 'XTickLabel', {'Fibre','Splices','Connectors','Total'});
    ylabel('Loss (dB)'); title('Loss breakdown'); grid on;
end
