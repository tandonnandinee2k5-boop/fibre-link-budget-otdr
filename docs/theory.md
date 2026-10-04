# Theory notes

## Link budget
- Total loss = alpha x L + Ns x Ls + Nc x Lc
- Received power = Ptx - Total loss  (dBm)
- Margin = Prx - Receiver sensitivity - Safety margin (dB). Link works if margin >= 0.
- Max reach = (Ptx - Sensitivity - Safety - Splice loss - Connector loss) / alpha

## Typical values used
| Fibre | Wavelength | Attenuation |
|---|---|---|
| Single-mode | 1310 nm | 0.35 dB/km |
| Single-mode | 1550 nm | 0.20 dB/km |
| Multimode | 850 nm | 3.0 dB/km |
| Multimode | 1300 nm | 1.0 dB/km |

Splice ~0.1 dB, connector ~0.5 dB. Replace with field values from BSNL if available.

## OTDR trace
- Slope = fibre attenuation (dB/km)
- Splice = small step down, no reflection
- Connector = step down plus reflection spike (glass-air interface)
- Fibre end / break = reflection spike, then trace falls to the noise floor
