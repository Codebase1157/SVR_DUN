# SVR-DUN — reproducibility code

[![CI](https://github.com/OWNER/svr-dun-repro/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/svr-dun-repro/actions/workflows/ci.yml)
[![Python 3.9+](https://img.shields.io/badge/python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/OWNER/svr-dun-repro/blob/main/notebooks/SVR_DUN_Reproducibility.ipynb)

Companion code for **"Learning Where Rank Matters: Spatially-Varying-Rank Deep
Unfolding for Budget-Adaptive Hyperspectral and Multispectral Image Fusion."**

> Replace `OWNER` in the badge URLs and in `pyproject.toml` once the
> repository has a home.

---


Two consequences, stated plainly:

* `svrdun/model.py` is a **reference implementation written from equations
  (8)–(34)**, not the authors' code. Its block widths are not published, so its
  parameter count and accuracy differ from Tables III and V. It is a
  comparator for *structure*, not for accuracy.
* `QUICK` mode proves every code path runs. It does **not** reproduce the
  paper's numbers and never claims to.

See [docs/PROVENANCE.md](docs/PROVENANCE.md).

## Quick start

```bash
git clone https://github.com/OWNER/svr-dun-repro.git
cd svr-dun-repro
pip install -e ".[dev,data]"

pytest -q                          # 134 tests, no dataset needed
svrdun verify-tables               # 70/70 consistency checks on the paper
svrdun run -c configs/quick.yaml   # end-to-end in minutes, CPU is fine
```

Or open the notebook in Colab with the badge above — it is self-contained and
writes this package itself.

## What runs with no data at all

The whole of Level 1 in [docs/REPRODUCING.md](docs/REPRODUCING.md), on a
deterministic synthetic scene rebuilt from the Fig. 1 description. It
establishes by execution that:

* `(BS)ᵀ` is **exactly** the adjoint of `BS` — this caught two real bugs: an
  even-length Gaussian kernel offsets the naive adjoint, and `F.conv2d` is
  cross-correlation, not convolution, which silently corrupts the gradient
  step of equation (14);
* `ε_k` is non-increasing with `ε₀ = 1`, and equation (4)'s cumulative-sum
  identity matches a direct projection;
* raising `λ_ρ` never raises the mean rank — the budget knob is monotone;
* `σ_min(R D_k)` is zero beyond `k = L` and non-increasing, i.e. Proposition
  2(b) and 2(c);
* the network trains, resumes from a checkpoint, and its atoms stay
  orthonormal through the QR step of equation (18);
* **all 70 internal-consistency checks on the published tables pass.**

## Layout

```
svrdun/           the package  (operators, rank estimator, model, stats, provenance)
configs/          42 YAML configs, one per experiment table
splits/           split files with their rule, caveats and SHA-256
notebooks/        the self-contained Colab notebook
tests/            134 tests
docs/             PROVENANCE.md, REPRODUCING.md, GAPS.md
outputs/
  reference_runs/ a QUICK run, committed so a fresh clone has a baseline to diff
BASELINES.md      baseline versions and the fair-comparison checklist
```

## CLI

```
svrdun verify-tables                     check the published tables for self-consistency
svrdun make-configs | make-splits        regenerate the configs / split specifications
svrdun materialise-split CAVE /data/CAVE apply a split rule to a real directory
svrdun verify-split  splits/CAVE_split.json /data/CAVE
svrdun run   -c configs/cave.yaml        train and evaluate one configuration
svrdun cost  -c configs/cave.yaml        parameters, FLOPs, time, peak memory
svrdun recoverability                    sigma_min(R D_k) per sensor (Proposition 2)
svrdun figures -o outputs/figs           motivation figures, no dataset needed
svrdun manifest DIR                      hash a directory into a provenance manifest
```

## Configs

One YAML fully determines a run. `svrdun/configs.py` generates them from the
transcribed protocol, so they cannot drift from it.

| Files | Covers |
|---|---|
| `cave`, `icvl`, `kaist`, `gf5_gf1` | per-dataset runs, Section V-C schedule |
| `ablation_A1..A8`, `ablation_full` | Table VI |
| `sensitivity_{K_max,T,w}_*` | Table VII |
| `robustness_blur_var*` | Table VIII |
| `robustness_response_*` | Tables IX and X |
| `sensor_gaussian_L{4,6,8}` | Table XII |
| `noise_{snr*,noisefree}_{plain,aware}` | Table XI |
| `baselines.yaml` | baseline versions to pin — **ships blank on purpose** |

**The validator rejects silent drift.** Change `K_max` or an epoch count
without declaring it in `meta.deviates_from_paper` and `load_config` raises,
so an accidental edit cannot pass as the published setting. Fields the paper
does not state — the block widths, `mu`, the UIQI window size, the ridge
weights of (33)–(34) — each carry a `_note` saying so rather than being
quietly invented.

## Splits

Each file ships as **SPECIFIED**: the rule, the ordering assumption, the seed
and the expected counts are fixed; the file names are not, because the datasets
are gated. `svrdun materialise-split` applies the rule to your copy and fixes
names plus a SHA-256; `verify-split` then fails loudly on a differing file set,
a train/test overlap, a wrong test count, or a SHA that does not match the
file's own contents.

Two gaps in the paper surfaced while building these, and the files state both:

* **"The last 12 images" (CAVE) and "its last 10" (KAIST) have no stated
  ordering.** These assume alphabetical. A different order gives different
  test images.
* **ICVL's 40 test scenes are drawn "at random" with no stated seed**, so an
  exactly matching ICVL split cannot be rebuilt from the paper. The seed used
  here is recorded in the file.

For CAVE the canonical 32-scene list is included so the split can be *checked*
rather than taken on trust.

## Known gaps

Eight gaps in the paper and six in this repository, each with what would close
it: [docs/GAPS.md](docs/GAPS.md). The most consequential is that the per-image
metrics behind Table XIV are not published, so its p-values, intervals and
rank-biserial *r* cannot be recomputed — `svrdun verify-tables` prints exactly
that rather than approximating them.

## Citing

See [CITATION.cff](CITATION.cff). Cite the paper; cite this repository only as
the reproducibility scaffold it is.

## Licence

MIT — see [LICENSE](LICENSE). **Confirm this is what you want before
publishing**; it is a conventional default for research code, not a decision
this repository can make for you.
