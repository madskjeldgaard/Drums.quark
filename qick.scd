/*

A kick loosely based on the 808 kick drum with a pulse being input into a resonant filter but with some extra bells and whistles.

*/
(
SynthDef(\qick, {
    arg
        gate = 1,
        amp=0.9,
        pan=0,
        dur=0.5,
        decay=1.0,
        kickFreq=60,
        noiseCutoff=800,
        noiseDecay=0.2,
        kickMix=0.10;
    var pulse, fmOsc, sig, noise, noiseEnv, noiseAttack, noiseRelease;

    // ------------ PULSE ----------------
    pulse = EnvGen.ar(
        Env(levels: [0,1,0], times: [0,1],
    ), gate: gate, timeScale: dur, doneAction: 0);

    // ------------ PULSE SHAPE ----------------
    // Note: There are two freqs here, one for the base frequency and one for an overtone
    pulse = Ringz.ar(in: pulse, freq: kickFreq * [1,1+(5.0/12.0)], decaytime: decay) * 0.01 * [1,0.5];
    pulse = pulse.sum;

    // ----------- NOISE -----------------------
    noiseAttack = 0.0001;
    noiseRelease = dur - noiseAttack * decay * noiseDecay;
    noiseEnv = EnvGen.ar(
        Env.perc(noiseAttack, noiseRelease), gate: gate, timeScale: dur, doneAction: 0);
    noise = WhiteNoise.ar(noiseEnv);
    noise = LPF.ar(noise, noiseCutoff);

    // ------------ MIX ------------------------
    sig = XFade2.ar(inA:pulse, inB:noise, pan:kickMix.linlin(0.0,1.0,-1.0,1.0));
    sig = sig.tanh; // A sort of limiter
    sig = Pan2.ar(sig, pan);

    DetectSilence.ar(in:sig, amp:0.0001, time:0.1, doneAction:2);

    Out.ar(0, sig * amp * 0.25);

}).add;
/*
// Test
Pbind(
    \instrument, \qick,
    \dur, 0.5,
    \kickFreq, 60,
    \decay, Pseg([0.25,2.0],16,\lin,inf),
    \amp, 1.0,
).play;
*/
)
