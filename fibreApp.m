function fibreApp()
%FIBREAPP GUI for the Fibre Optic Link Budget & OTDR Simulator.
%   Run:  fibreApp     (MATLAB R2020a or later; uses uifigure)
%   Uses the same functions in src/ as main.m.

    projectRoot = fileparts(mfilename('fullpath'));
    addpath(fullfile(projectRoot, 'src'));

    fig  = uifigure('Name', 'Fibre Optic Link Budget & OTDR Simulator', ...
                    'Position', [60 40 1180 720]);
    main = uigridlayout(fig, [1 2]);
    main.ColumnWidth = {300, '1x'};

    %% ---------- LEFT: inputs ----------
    left = uipanel(main, 'Title', 'Inputs');
    g = uigridlayout(left, [15 2]);
    g.RowHeight   = repmat({28}, 1, 15);
    g.ColumnWidth = {'1x', 100};
    g.Scrollable  = 'on';

    addLabel(1, 'Fibre type');
    ddFibre = uidropdown(g, 'Items', {'Single-mode', 'Multimode'}, ...
        'Value', 'Single-mode', 'ValueChangedFcn', @(~,~) onFibreChange());
    ddFibre.Layout.Row = 1; ddFibre.Layout.Column = 2;

    addLabel(2, 'Wavelength (nm)');
    ddWl = uidropdown(g, 'Items', {'1310', '1550'}, 'Value', '1550');
    ddWl.Layout.Row = 2; ddWl.Layout.Column = 2;

    efL      = addNum(3,  'Length (km)',          10,  [0.1 200]);
    efNs     = addNum(4,  'Number of splices',     4,  [0 100]);
    efNc     = addNum(5,  'Number of connectors',  2,  [0 20]);
    efLs     = addNum(6,  'Loss per splice (dB)',  0.1, [0 2]);
    efLc     = addNum(7,  'Loss per connector (dB)', 0.5, [0 3]);
    efPtx    = addNum(8,  'Tx power (dBm)',        0,  [-30 20]);
    efSens   = addNum(9,  'Rx sensitivity (dBm)', -28, [-60 0]);
    efSafety = addNum(10, 'Safety margin (dB)',    3,  [0 20]);

    chkCut = uicheckbox(g, 'Text', 'Simulate fibre cut', ...
        'ValueChangedFcn', @(~,~) onCutToggle());
    chkCut.Layout.Row = 11; chkCut.Layout.Column = [1 2];

    efCut = addNum(12, 'Cut position (km)', 5, [0.1 200]);
    efCut.Enable = 'off';

    btnCalc = uibutton(g, 'Text', 'Calculate', 'ButtonPushedFcn', @(~,~) calculate());
    btnCalc.Layout.Row = 13; btnCalc.Layout.Column = [1 2];
    btnCalc.FontWeight = 'bold';

    btnReset = uibutton(g, 'Text', 'Reset defaults', 'ButtonPushedFcn', @(~,~) resetDefaults());
    btnReset.Layout.Row = 14; btnReset.Layout.Column = [1 2];

    btnSave = uibutton(g, 'Text', 'Save OTDR plot (PNG)', 'ButtonPushedFcn', @(~,~) savePlot());
    btnSave.Layout.Row = 15; btnSave.Layout.Column = [1 2];

    %% ---------- RIGHT: results ----------
    right = uigridlayout(main, [3 2]);
    right.RowHeight   = {160, '1x', 230};
    right.ColumnWidth = {'1x', '1x'};

    txt = uitextarea(right, 'Editable', 'off', 'FontName', 'Courier New', 'FontSize', 13);
    txt.Layout.Row = 1; txt.Layout.Column = [1 2];

    axTrace = uiaxes(right);
    axTrace.Layout.Row = 2; axTrace.Layout.Column = [1 2];

    axBar = uiaxes(right);
    axBar.Layout.Row = 3; axBar.Layout.Column = 1;

    tbl = uitable(right);
    tbl.Layout.Row = 3; tbl.Layout.Column = 2;

    calculate();   % show a result on start-up

    %% ---------- helper (nested) functions ----------
    function addLabel(row, str)
        l = uilabel(g, 'Text', str);
        l.Layout.Row = row; l.Layout.Column = 1;
    end

    function ef = addNum(row, str, val, lim)
        addLabel(row, str);
        ef = uieditfield(g, 'numeric', 'Value', val, 'Limits', lim);
        ef.Layout.Row = row; ef.Layout.Column = 2;
    end

    function onFibreChange()
        if strcmp(ddFibre.Value, 'Single-mode')
            ddWl.Items = {'1310', '1550'}; ddWl.Value = '1550';
        else
            ddWl.Items = {'850', '1300'};  ddWl.Value = '850';
        end
    end

    function onCutToggle()
        if chkCut.Value, efCut.Enable = 'on'; else, efCut.Enable = 'off'; end
    end

    function resetDefaults()
        ddFibre.Value = 'Single-mode'; onFibreChange();
        efL.Value = 10; efNs.Value = 4; efNc.Value = 2;
        efLs.Value = 0.1; efLc.Value = 0.5;
        efPtx.Value = 0; efSens.Value = -28; efSafety.Value = 3;
        chkCut.Value = false; efCut.Value = 5; onCutToggle();
        calculate();
    end

    function calculate()
        ft  = ddFibre.Value;
        wl  = str2double(ddWl.Value);
        L   = efL.Value;
        nS  = round(efNs.Value);
        nC  = round(efNc.Value);
        lS  = efLs.Value;   lC = efLc.Value;
        Ptx = efPtx.Value;  sens = efSens.Value;  safety = efSafety.Value;

        if chkCut.Value
            cutPos = efCut.Value;
            if cutPos > L
                uialert(fig, 'Cut position must be within the fibre length.', 'Invalid input');
                return;
            end
        else
            cutPos = [];
        end

        alpha = getAttenuation(ft, wl);
        r = calcLinkBudget(L, alpha, nS, nC, lS, lC, Ptx, sens, safety);

        % verdict
        if ~isempty(cutPos)
            verdict = sprintf('FIBRE CUT at %.2f km - link DOWN', cutPos);
            txt.BackgroundColor = [1 0.85 0.85];
        elseif r.margin >= 0
            verdict = 'Link WORKS';
            txt.BackgroundColor = [0.85 1 0.85];
        else
            verdict = 'Link FAILS (loss too high)';
            txt.BackgroundColor = [1 0.85 0.85];
        end
        txt.Value = { ...
            sprintf('RESULT          : %s', verdict), ...
            sprintf('Attenuation     : %.2f dB/km (%s, %d nm)', alpha, ft, wl), ...
            sprintf('Total loss      : %.2f dB  (fibre %.2f + splices %.2f + connectors %.2f)', ...
                    r.totalLoss, r.fibreLoss, r.spliceLoss, r.connLoss), ...
            sprintf('Received power  : %.2f dBm', r.pRx), ...
            sprintf('Power margin    : %.2f dB', r.margin), ...
            sprintf('Maximum reach   : %.1f km', r.maxLen)};

        % OTDR trace
        splices = L * (1:nS) / (nS + 1);
        if nC == 0
            conns = [];
        elseif nC == 1
            conns = 0;
        else
            conns = linspace(0, L, nC);
        end
        [z, tr] = buildOTDRTrace(L, alpha, splices, conns, lS, lC, cutPos);
        cla(axTrace);
        plot(axTrace, z, tr, 'LineWidth', 0.8);
        grid(axTrace, 'on');
        xlabel(axTrace, 'Distance (km)');
        ylabel(axTrace, 'Backscatter level (dB, relative)');
        title(axTrace, sprintf('Simulated OTDR trace: %s, %d nm', ft, wl));

        % loss breakdown
        cla(axBar);
        bar(axBar, 1:4, [r.fibreLoss r.spliceLoss r.connLoss r.totalLoss]);
        xticks(axBar, 1:4);
        xticklabels(axBar, {'Fibre', 'Splices', 'Connectors', 'Total'});
        ylabel(axBar, 'Loss (dB)');
        title(axBar, 'Loss breakdown');
        grid(axBar, 'on');

        % comparison table
        tbl.Data = compareFibres(L, nS, nC, lS, lC, Ptx, sens, safety);
    end

    function savePlot()
        try
            folder = fullfile(projectRoot, 'screenshots');
            if ~exist(folder, 'dir'), mkdir(folder); end
            exportgraphics(axTrace, fullfile(folder, 'gui_otdr_trace.png'));
            uialert(fig, 'Saved to screenshots/gui_otdr_trace.png', 'Saved', 'Icon', 'success');
        catch err
            uialert(fig, err.message, 'Could not save');
        end
    end
end
