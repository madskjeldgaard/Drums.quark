/*

A sort of cymbal sound

*/
(
SynthDef(\cymbool, {
    arg
        out=0,
        dur=1,
        gate=1,
        hihatFreq=1013.49,
        amp=0.5,
        pan=0,
        attack=0.005,
        release=0.75,
        highCut=2500.0,
        decimate=0.5,
        wobble=0.1,
        spread=0.05;

    var envs, sig, detuneFreqs, numOscillators, pulseAmps;

    // A dummy envelope to release the synth
    EnvGen.kr(envelope:Env.perc(), gate:gate, timeScale:dur, doneAction:2);

    numOscillators = 10;

    envs = numOscillators.collect{
        EnvGen.ar(Env.perc(attack, release, curve: (-9.0) * Rand(0.95,1.0)), timeScale: Rand(0.95,1.0), doneAction:0)
    };

    detuneFreqs = numOscillators.collect{|freqNum|
        1+(freqNum * spread * Rand(1.001,1.01)) * LFNoise2.ar(0.05).range(1.0 - (wobble / 100.0),1.0 + (wobble/100.0))
    };

    pulseAmps = numOscillators.collect{|freqNum|
        1.0 / (freqNum+1) * Rand(0.95,1.0) * envs[freqNum]
    };

    sig = PulseDPW.ar(freq:hihatFreq * detuneFreqs, width: 0.5, mul: pulseAmps ).sum * 0.2;

    // Elektron style sample rate reduction / decimation
    sig = Decimator.ar(sig, decimate.linlin(0.0,1.0,SampleRate.ir, SampleRate.ir/16.0));

    sig = LPF.ar(sig, highCut.clip(20.0, 18000.0));
    sig = sig * 0.125;

    Out.ar(out, Pan2.ar(sig, pan)*envs);
}).add;
/*
// Test
Pbind(
    \instrument, \cymbool,
    \dur, 0.125,
    \release, Pseg([0.1,2.0],16,\lin,inf)
).play(quant:4)

*/
)
