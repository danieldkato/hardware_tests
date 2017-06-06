function dB = pa2db(p)

p0 = 20e-6; % reference sound pressure level, in Pascals, for dB SPL
dB = 20*log10(p/p0);