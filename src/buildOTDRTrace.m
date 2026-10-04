function [z, tr] = buildOTDRTrace(L, alpha, splices, conns, lSplice, lConn, cutPos)
%BUILDOTDRTRACE Simulated OTDR trace (relative dB vs distance in km).
%   Slope = attenuation | splice = small step | connector = step + spike
%   Fibre end / cut = spike then noise floor.
    rng(1);
    z  = linspace(0, 1.15 * L, 3000);
    tr = -alpha * z;
    if isempty(cutPos), endPos = L; else, endPos = cutPos; end

    evPos  = [splices(:); conns(:)];
    evLoss = [lSplice * ones(numel(splices), 1); lConn * ones(numel(conns), 1)];
    evRefl = [false(numel(splices), 1); true(numel(conns), 1)];

    for k = 1:numel(evPos)
        if evPos(k) <= endPos
            m = z >= evPos(k);
            tr(m) = tr(m) - evLoss(k);
        end
    end

    floorLvl = min(tr(z <= endPos)) - 8;
    tr(z > endPos) = floorLvl;

    keep   = evRefl & (evPos <= endPos);
    spikeP = [evPos(keep); endPos];
    spikeH = [4 * ones(nnz(keep), 1); 6];
    w    = max(6, round(0.01 * numel(z)));       % spike width in samples
    prof = exp(-(0:w-1) / (w / 4));              % sharp peak with decaying tail
    for k = 1:numel(spikeP)
        i = find(z >= spikeP(k), 1);
        j = min(i + w - 1, numel(z));
        tr(i:j) = tr(i:j) + spikeH(k) * prof(1:(j - i + 1));
    end

    tr = tr + 0.08 * randn(size(tr));
end