# Baselines and fair-comparison protocol

The paper compares SVR-DUN with eleven methods. They fall into three groups,
and the groups are **not** equally reproducible. Keeping them apart is the
point of this file.

## Group 1 — values quoted from [6], not rerun

Table III's nine baseline rows and Table IV's nine entries are, in the paper's
own words, *"the measured values reported in [6]"*. Table V's baseline
parameter counts and FLOPs likewise.

| Method | Ref | Quoted for |
|---|---|---|
| NSSR | [46] | Tables III, IV |
| HySure | [9] | Tables III, IV |
| SMGU-Net | [24] | Tables III, IV, V |
| CSGAV | [47] | Tables III, IV, V |
| LRTN | [19] | Tables III, IV, V, VIII |
| DSPNet | [48] | Tables III, IV, V, VIII |
| PSRT | [15] | Tables III, IV, V |
| PanMamba | [17] | Tables III, IV, V |
| RASD-FuNet | [6] | Tables III–V, VIII–XII |

**What this means for a fair comparison.** These numbers were produced by the
authors of [6] on their machines, under their training schedule. They are
comparable with SVR-DUN only to the extent that the protocol matches — same
splits, same degradation (Gaussian blur size 8, variance 3, s = 8, Nikon D700
response), same normalisation to [0, 1] by the maximum. The paper follows that
protocol deliberately so the quoted numbers remain comparable. If you change
any of it, the quoted baselines stop being valid comparators and must be
rerun.

Timing and memory in Table V come from [6] as well, measured for a 512 × 512
output on one RTX 4090. Numbers measured on other hardware are not comparable;
`svrdun.cost.measure_cost` records the device in every row for that reason.

## Group 2 — retrained by the authors on the same splits

| Method | Ref | Where |
|---|---|---|
| RASD-FuNet (retrained) | [6] | Tables XIII, XIV |
| Region-aware MoE | [32] | Tables III, XIII, XIV |
| TPTransformer | [26] | Tables III, XIII, XIV |

These are the only three used for the paired statistical tests, because a
paired test needs per-image outputs of both methods under the same protocol —
which is exactly what quoted numbers cannot give. Section V-K says so: *"The
other entries of Table III are taken from [6], come without per-image outputs
and are not tested."*

**To rerun this group** you need, for each method: the authors' public code at
a pinned commit, retraining on the same splits with the same three seeds, and
per-image metric dumps. Record all of it in `configs/` alongside your own run.

## Group 3 — SVR-DUN itself

`svrdun/model.py` here is a reference implementation written from equations
(8)–(34), not the authors' code. It is a comparator for *structure*, not for
accuracy: its block widths are not published, so its parameter count and PSNR
differ from Tables III and V.

---

## Recording baseline versions

A comparison is only checkable if the baseline code is pinned. Put one entry
per baseline in `configs/baselines.yaml` with at least:

```yaml
baselines:
  - name: RASD-FuNet
    reference: "[6]"
    source: "https://github.com/<owner>/<repo>"       # fill in
    commit: "<40-char sha>"                            # pin it
    retrained: true
    seeds: [1, 2, 3]
    split_file: splits/CAVE_split.json
    per_image_outputs: outputs/baselines/rasd_funet/cave_per_image.csv
    notes: "trained with the authors' default recipe, same splits and seeds"
```

The repository does not ship URLs or commit hashes for the baselines: this
code cannot verify them, and an unverified link that looks authoritative is
worse than a blank to fill in.

## Fair-comparison checklist

Before putting a baseline next to SVR-DUN in a table, confirm all of:

1. **Same split file**, verified with `svrdun.splits.verify_split` — not just
   the same dataset. CAVE's "last 12" depends on an ordering the paper does
   not state, and ICVL's random 40 depends on a seed it does not state.
2. **Same degradation**: Gaussian blur of size 8 and variance 3, s = 8,
   the same spectral response, noise at the same SNR or none.
3. **Same normalisation**: each image scaled to [0, 1] by its own maximum
   before simulation.
4. **Same metric definitions**: PSNR per band with that band's own maximum as
   the peak (equation 35), ERGAS with the correct s (36), SAM in degrees (37),
   UIQI over sliding windows (38) — and the same UIQI window size, which the
   paper does not state.
5. **Same output size for cost**: parameters, FLOPs, time and peak memory for
   a 512 × 512 output, on the same GPU.
6. **Same seed count** for any mean reported, and per-image dumps if the
   comparison will be tested statistically.
7. **For paired tests**: per-image values for both methods, from runs that
   share the split and the seeds.

Failing 1–3 makes the comparison invalid. Failing 4–5 makes it misleading.
Failing 6–7 makes the statistics unavailable, not merely weaker.

## Per-image outputs

`svrdun.train.evaluate_model` writes a `per_image` list, which is what
`svrdun.stats.paired_comparison` consumes. Dump the same for each baseline in
the same shape:

```
image_index, PSNR, ERGAS, SAM, UIQI
```

one row per test image per seed. With those files the p-values, confidence
intervals and rank-biserial r of Table XIV become recomputable — they are the
only reason those three columns currently cannot be.
