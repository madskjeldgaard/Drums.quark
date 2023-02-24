/*

This clap synth is partly inspired by a digital Elektron clap sound engine.

*/
(
SynthDef(\klap, {
    arg out=0,
        amp=1.0,
        pan=0,

        decimate = 0.25, // Bit reduce noise source

        clapFreq = 1200.0,
        clapSpread=0.05, // Spacing between individual claps
        clapDur=0.5, // Overall clap duration
        clapRq=0.45, // Lower number = more ringing

        verbAttack=0.0125,
        verbDecay=1.0,
        verbDamp=0.15,
        verbLowCut=100,
        verbMix=0.5;

    var verbEnv, clapEnv, sig, verbSig, clapSig, numClaps;

    // ------------- NOISE -----------------//
    var noise = WhiteNoise.ar();

    // Elektron style sample rate reduction / decimation
    noise = Decimator.ar(noise, decimate.linlin(0.0,1.0,SampleRate.ir, SampleRate.ir/16.0));

    // ------------- REVERB -----------------//
    // Note: It's the verb envelope that is responsible for freeing the synth
    verbEnv = EnvGen.ar(Env(
        levels: [0.0,1.0,0.000001],
        times: [verbAttack, verbDecay],
        curve: [\lin, \exp]
    ), doneAction: 2);

    verbSig = RLPF.ar(noise * verbEnv, verbDamp.linexp(0.001, 1.0, 10000.0, 50.0), rq: 0.4);
    verbSig = HPF.ar(verbSig, verbLowCut);

    // ------------- CLAPS -----------------//
    numClaps = 4;

    clapEnv = numClaps.collect{|clapNum|
        var clapDelay = clapNum.linlin(0, numClaps, 0.0, clapSpread);
        EnvGen.ar(Env(
            levels: [0, 0.00001,1.0,0.000001],
            times: [clapDelay, 0, clapDur],
            curve: [\lin, \exp, \exp]
        ), doneAction: 0);
    };

    clapSig = noise * clapEnv;
    clapSig = BPF.ar(in:clapSig, freq:clapFreq, rq:clapRq) * clapRq.reciprocal;
    clapSig = clapSig.sum * numClaps.reciprocal;

    // ------------- MIX -----------------//
    sig = XFade2.ar(inA:verbSig * 0.125, inB:clapSig * 2, pan:verbMix.linlin(0.0,1.0,-1.0,1.0));

    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig * amp * 0.5);
}).add;

/*
// Test
Pbind(
    \instrument, \klap,
    \dur, 0.5,
    \clapFreq, Pstep(Prand([1300.0,1400.0,1200.0,1500.0]),16,inf),
    \clapDur, Pseg([0.1,0.5],16,\exp,inf),
    \verbDecay, Pseg([0.25,5.0],16,\exp,inf),
    \decimate, Pstep(Prand([0.0,0.25,0.5,0.75,1.0]),16,inf),
    \amp, 1.0,
).play;
*/

)
