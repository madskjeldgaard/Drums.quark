(
Pdef(\all,
    Pbind(
        \instrument, Prand([
            // \klap,
            // \qick,
            // \xick_fm,
            \xick_sine,
            Rest(),
            // \cymbool,
        ], inf).trace,
        \delta, Prand([1.0/8.0, 1.0/4.0, 1.0/2.0],inf),
        \kickFreq, 250,
        \pitchEnvAmount, 0.9,
        \overtoneAmount, 0.75,
        \clapSpread, Pwhite(0.01,0.05),
        \release, Pseg([0.25,1.0],32,\lin,inf),
        \verbDecay, 1.5,
        \decimate, 0.2,
        \amp, 1
    )
).play(quant: 1);
s.record(path: "~/xick2.wav".asAbsolutePath);

// Pdef(\hats,
//     Pbind(
//         \instrument, \cymbool,
//         \release, Pwhite(0.5,2.0),
//         \delta, 1/8.0,
//         \amp, Pexprand(0.3,1.0),
//         \pan, Pseg(Pseq([-0.5,0.5],inf),4,\lin,inf).sin
//     )
// ).play(quant: 4);
)
Synth(\xick_fm, [\kickFreq, 500]);
