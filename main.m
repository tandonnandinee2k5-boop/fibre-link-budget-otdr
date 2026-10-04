%% Fibre Optic Link Budget & OTDR Simulator - MAIN SCRIPT
% Edit the INPUTS section, then press Run.
% Requires MATLAB R2016b or later (R2020a+ for saving figures).
clear; clc; close all;

projectRoot = fileparts(mfilename('fullpath'));
if ~isfolder(fullfile(projectRoot, 'src'))   % happens when started with run(...)
    projectRoot = pwd;
end
addpath(fullfile(projectRoot, 'src'));

%% 1. INPUTS
fibreType  = 'Single-mode';   % 'Single-mode' or 'Multimode'
wavelength = 1550;            % SM: 1310 or 1550 | MM: 850 or 1300 (nm)
L          = 10;              % fibre length (km)
nSplice    = 4;               % number of splices
nConn      = 2;               % number of connectors
lSplice    = 0.1;             % loss per splice (dB)
lConn      = 0.5;             % loss per connector (dB)
Ptx        = 0;               % transmitter power (dBm)
sens       = -28;             % receiver sensitivity (dBm)
safety     = 3;               % safety margin (dB)
cutPos     = [];              % fibre cut position (km), [] = no cut
saveFigures = true;          % true = save PNGs into screenshots/

%% 2. LINK BUDGET
alpha = getAttenuation(fibreType, wavelength);
r = calcLinkBudget(L, alpha, nSplice, nConn, lSplice, lConn, Ptx, sens, safety);

fprintf('--- LINK BUDGET ---\n');
fprintf('Fibre / wavelength : %s, %d nm (%.2f dB/km)\n', fibreType, wavelength, alpha);
fprintf('Fibre loss         : %.2f dB\n', r.fibreLoss);
fprintf('Splice loss        : %.2f dB\n', r.spliceLoss);
fprintf('Connector loss     : %.2f dB\n', r.connLoss);
fprintf('Total loss         : %.2f dB\n', r.totalLoss);
fprintf('Received power     : %.2f dBm\n', r.pRx);
fprintf('Power margin       : %.2f dB\n', r.margin);
fprintf('Maximum reach      : %.1f km\n', r.maxLen);

if ~isempty(cutPos)
    fprintf('RESULT: FIBRE CUT at %.2f km - link DOWN\n', cutPos);
elseif r.margin >= 0
    fprintf('RESULT: Link WORKS\n');
else
    fprintf('RESULT: Link FAILS (loss too high)\n');
end

%% 3. OTDR TRACE
splices = L * (1:nSplice) / (nSplice + 1);
if nConn == 0
    conns = [];
elseif nConn == 1
    conns = 0;
else
    conns = linspace(0, L, nConn);
end
[z, tr] = buildOTDRTrace(L, alpha, splices, conns, lSplice, lConn, cutPos);

%% 4. PLOTS
[figTrace, figLoss] = plotResults(z, tr, r, fibreType, wavelength);

%% 5. SINGLE-MODE vs MULTIMODE COMPARISON
T = compareFibres(L, nSplice, nConn, lSplice, lConn, Ptx, sens, safety);
disp(T);

%% 6. MARGIN vs LENGTH SWEEP
figSweep = plotMarginSweep(130, nSplice, nConn, lSplice, lConn, Ptx, sens, safety);

%% 7. SAVE FIGURES (optional)
if saveFigures
    outDir = fullfile(projectRoot, 'screenshots');
    if ~exist(outDir, 'dir'), mkdir(outDir); end
    saveByName('OTDR Trace',       fullfile(outDir, 'otdr_trace.png'));
    saveByName('Loss Breakdown',   fullfile(outDir, 'loss_breakdown.png'));
    saveByName('Margin vs Length', fullfile(outDir, 'margin_sweep.png'));
end

%% ===================== LOCAL FUNCTIONS ================================
function saveByName(figName, filePath)
% Find a figure by its Name and save it as PNG (looks it up fresh, so a
% stale handle from a docked figure window cannot break the export).
    f = findall(groot, 'Type', 'figure', 'Name', figName);
    if isempty(f)
        warning('Figure "%s" not found - not saved.', figName);
        return;
    end
    f = f(1);
    drawnow;
    try
        for ax = findall(f, 'Type', 'axes')'
            ax.Toolbar.Visible = 'off';          % keep the toolbar out of the image
        end
    catch
    end
    try
        exportgraphics(f, filePath);
    catch
        saveas(f, filePath);
    end
    fprintf('Saved %s\n', filePath);
end