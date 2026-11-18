# Population-level analysis of pitch encoding in ferrets

This project uses electrophysiology data collected by Q. Gaucher and K. Walker. The decoding model was written by B. Willmore. All work was done at Oxford University, Department of Physiology, Anatomy and Genetics.

All material within this repository was authored by Veronica Tarka, DPhil student under K. Walker and A. King.

# Structure of electrophysiology data

Recordings were made with Neuropixels 1.0 probes under anaesthesia. Data are not stored within this repo. 20 penetrations across 4 ferrets were made across A1 and AAF. Two of the 20 penetrations were in PPF, and did not yield many single units. This analysis was performed on well-isolated single units only.

Penetrations are referred to as 1-20 in this way:
1-8: Noah penetrations 1-8
9-12: Ronnie penetrations 4,5,8,13
13-16:
17-20:

# Structure of stimuli

13 different timbres were presented across 17 different F0s. F0s ranged from 250 - 4000 Hz in 0.25 octave increments. Sounds were low-pass filtered at 30 kHz.

1. Click Train - unjittered, energy at F0 and all harmonics
2. Click Train 5% jitter
3. Click Train 10% jitter
4. Click Train 20% jitter
5. Click Train 40% jitter
6. Missing Fundamental - AKA 'all harmonics', no energy at F0
7. Low - AKA 'resolved harmonics', only the ferrets' resolved harmonics, no energy at F0
8. F0MaskLow - Low stimulus + pink noise masker 20 dB below
9. High - AKA 'unresolved harmonics', only the ferrets' unresolved harmonics, no energy at F0
10. F0MaskHigh - High stimulus + pink noise masker 20 dB below
11. Alt - AKA 'alternating phase', unresolved harmonics with alternating harmonics in sine and cosine phase
12. Rand - AKA 'random phase', unresolved harmonics with each harmonic beginning in a random phase
13. Tone - pure tone at F0


# Elaboration of the data structures herein used
## Raw spike data formatted for linear decoder

X_nwt = 3D matrix where dimension (d) 1 is neuron, d2 is window in time, and d3 is trial. Each value is the spike rate for a given neuron at a given time on a given trial.

F0_key = 2D matrix (size w x t of X_nwt variable), labels the F0 of the trial

stim_key = 2D matrix (size w x t of X_nwt variable), labels the stimulus (timbre) of the trial

pen_key = 1D matrix (size n of X_nwt variable), labels the original penetration of the neuron

unit_key = 1D matrix (size n of X_nwt variable), labels the unit number

# Remaining structures

# Dependencies
Ben Willmore's https://github.com/ben-willmore/benlib
