%% Simple tests - run this file; every line should print PASS.
clear; clc;
projectRoot = fileparts(fileparts(mfilename('fullpath')));
if ~isfolder(fullfile(projectRoot, 'src'))   % happens when started with run(...)
    projectRoot = pwd;                       % fall back to the current folder
end
addpath(fullfile(projectRoot, 'src'));
tol = 1e-9; n = 0;

alpha = getAttenuation('Single-mode', 1550);
r = calcLinkBudget(10, alpha, 4, 2, 0.1, 0.5, 0, -28, 3);

n = check(abs(r.totalLoss - 3.4)  < tol, 'Total loss = 3.4 dB', n);
n = check(abs(r.pRx + 3.4)        < tol, 'Received power = -3.4 dBm', n);
n = check(abs(r.margin - 21.6)    < tol, 'Margin = 21.6 dB', n);
n = check(abs(r.maxLen - 118)     < 1e-6, 'Max reach = 118 km', n);

rLong = calcLinkBudget(200, alpha, 4, 2, 0.1, 0.5, 0, -28, 3);
n = check(rLong.margin < 0, '200 km link fails', n);

r0 = calcLinkBudget(10, alpha, 0, 0, 0.1, 0.5, 0, -28, 3);
n = check(abs(r0.totalLoss - 2.0) < tol, 'No events: loss = alpha*L', n);

n = check(getAttenuation('Multimode', 850) == 3.0, 'MM 850 nm = 3.0 dB/km', n);

failed = false;
try, getAttenuation('Single-mode', 850); catch, failed = true; end
n = check(failed, 'Invalid wavelength throws error', n);

% --- extra tests with expected values worked out by hand ---
% 5 km multimode 1300 nm, 2 splices, 1 connector: 5*1.0 + 2*0.1 + 1*0.5 = 5.7 dB
a = getAttenuation('Multimode', 1300);
r2 = calcLinkBudget(5, a, 2, 1, 0.1, 0.5, 0, -28, 3);
n = check(abs(r2.totalLoss - 5.7) < tol, 'MM 1300 nm, 5 km = 5.7 dB', n);

% 30 km single-mode 1310 nm, 3 splices, 2 connectors:
% total = 30*0.35 + 3*0.1 + 2*0.5 = 11.8 dB ; margin = 0 - 11.8 + 28 - 3 = 13.2 dB
a2 = getAttenuation('Single-mode', 1310);
r3 = calcLinkBudget(30, a2, 3, 2, 0.1, 0.5, 0, -28, 3);
n = check(abs(r3.totalLoss - 11.8) < tol, 'SM 1310 nm, 30 km = 11.8 dB', n);
n = check(abs(r3.margin - 13.2) < tol, 'SM 1310 nm, 30 km margin = 13.2 dB', n);

% 15 km multimode 850 nm loses 45 dB+ so the link must fail
a3 = getAttenuation('Multimode', 850);
r4 = calcLinkBudget(15, a3, 2, 1, 0.1, 0.5, 0, -28, 3);
n = check(r4.margin < 0, 'MM 850 nm, 15 km fails', n);

fprintf('\n%d tests passed.\n', n);

function n = check(cond, name, n)
    if cond, fprintf('PASS: %s\n', name); n = n + 1;
    else,    fprintf('FAIL: %s\n', name); end
end