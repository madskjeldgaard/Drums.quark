/*

An oscillator based kick drum

*/
(
[\sine, \tri, \square, \fm, \fold].do{|oscShape|
    SynthDef(("xick_" ++ oscShape).asSymbol, {arg
        gate = 1,
        dur = 1,
        amp = 0.5,
        kickFreq = 80,
        attack=0.001,
        release=1.5,
        pan = 0,
        overtoneAmount=0.525,
        pitchEnvAmount=0.5,
        mix=0.275,
        decimate=0.0;

        var sig, oscSig, noiseSig, envFreq, envelopedFreq, envelope, freqMin, freqMax, maxKickFreq, minKickFreq, overtone, freqs, noise, noiseEnv;

        // ------- 808 STYLE ENVELOPE ----------
        // Attempt at emulating the envelope of 808 including the weird "breathing" stage of the envelope
        // https://www.researchgate.net/figure/Pulse-shaper-behavior-under-various-input-pulses_fig4_267629876
        var breathLevel = 0.005;
        var breathRelease = release * 0.25;
        var env = Env(
            levels:[0.00001, 1.0, 0.1, 0.01, breathLevel, breathLevel, 0.0],
            times: [attack, release, 0.025, 0.1, breathRelease, 0.025],
            curve: [\lin, -9, \lin, 4, \lin, \lin]
        );

        // Amp envelope
        envelope = EnvGen.ar(env, gate: gate, timeScale: dur, doneAction:2);

        // ------------- PITCH ENVELOPE -------------
        minKickFreq = 10.0;
        maxKickFreq = 2000.0;
        freqMin = ((1.0 - pitchEnvAmount) * kickFreq).clip(minKickFreq, kickFreq);
        freqMax = kickFreq;
        envelopedFreq = EnvGen.ar(
            env,
            gate: gate,
            timeScale: dur,
            doneAction:0
        ).linexp(
            0.000001,
            1.0,
            freqMin,
            freqMax
        );

        // ---------- OSCILLATOR ---------------
        overtone = 1.0 + ( 5.0 / 12.0 );
        freqs = envelopedFreq * [1.0, overtone];

        switch(oscShape,
            \square, {
                var cutoff = \cutoff.ar(250.0, spec: [20.0,20000.0,\exp]);
                var pwmFreq = \pwmFreq.ar(0.5, spec: [0.0,100.0]);
                var pwm = \pwm.ar(1.0, spec: [0.0,1.0]) * PulseDPW.ar(pwmFreq);
                oscSig = PulseDPW.ar(freqs, width: pwm, mul: [1.0,overtoneAmount]).sum;
                oscSig = LPF.ar(in:oscSig, freq:cutoff);
            },
            \tri,{
                var cutoff = \cutoff.ar(200.0, spec: [20.0,20000.0,\exp]);
                oscSig = LFTri.ar(freqs, mul: [1.0,overtoneAmount]).sum;
                oscSig = LPF.ar(in:oscSig, freq:cutoff);
            },
            \sine, {
                oscSig = SinOsc.ar(freqs, mul: [1.0,overtoneAmount]).sum;
            },
            \fm, {
                var modIndex = \modIndex.ar(0.5383, spec: [0.0,10.0,\exp]);
                oscSig = SinOsc.ar(freqs * SinOsc.ar(freqs * modIndex), mul: [1.0,overtoneAmount]).sum;
            },
            \fold, {
                var foldGain = \foldGain.ar(0.10).linlin(0.0,1.0,1.0,20.0);
                oscSig = SinOsc.ar(freqs, mul: [1.0,overtoneAmount]);
                // NOTE: This is extremely processing intensive to not sum before the folder, but it sounds too damn good!
                oscSig = LockhartWavefolder.ar(oscSig * (foldGain * [1.0,1.01]), numCells: 12).sum;
            },
            \foldfm, {
                var foldGain = \foldGain.ar(0.90).linlin(0.0,1.0,1.0,20.0);
                var modIndex = \modIndex.ar(0.6383, spec: [0.0,10.0,\exp]);
                oscSig = SinOsc.ar(freqs * SinOsc.ar(freqs * modIndex), mul: [1.0,overtoneAmount]).sum;
                oscSig = LockhartWavefolder.ar(oscSig * foldGain, numCells: 12);
            }
        );

        oscSig = oscSig * envelope;

        // --------- NOISE -------------------
        // noiseEnv = EnvGen.ar(Env.perc(attack, release), doneAction:0);
        noiseEnv = EnvGen.ar(envelope:env, timeScale:0.25);
        noise = LPF.ar(WhiteNoise.ar(0.1 * noiseEnv * noiseEnv), freq: 1500);

        // ---------- MIX ---------------
        sig = XFade2.ar(
            inA:oscSig,
            inB:noise,
            pan:mix.linlin(0.0,1.0,-1.0,1.0)
        );

        sig = Decimator.ar(sig, decimate.linlin(0.0,1.0,SampleRate.ir, SampleRate.ir/16.0));
        sig = Pan2.ar(sig, pan);

        Out.ar(0, sig * amp * 0.5);
    }
).load;

};

/*
// Test
Pbind(
    \instrument, \xick_fm,
    \delta, 0.5,
    \kickFreq, 100,
    \release, Pseg([0.1,2.0],16,\lin,inf),
    \amp, 1.5
).play(quant: 4);
*/

)
