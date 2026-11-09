# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [0.1.0] — unreleased

First public version.

### Added
- `svrdun` package: degradation operators (1)–(2), local spectral rank and the
  rank field estimator (4), (5), (15), (16), (32), the unfolded network
  (9), (14)–(28), metrics (35)–(39), recoverability (Proposition 2, (30), (31)),
  exact paired statistics, and provenance tracking.
- 42 experiment configs covering Tables VI–XII, with a validator that rejects
  any silent departure from the paper's stated protocol.
- Split specifications for CAVE, ICVL, KAIST and GF5-GF1, with materialisation
  and loud verification against a real directory.
- `svrdun` CLI with ten subcommands.
- 134 tests; CI runs them on Python 3.9/3.11/3.12 plus a QUICK end-to-end run
  and a full notebook execution.
- Self-contained Colab notebook that writes this package itself.
- A reference QUICK run under `outputs/reference_runs/` to diff against.

### Fixed during development
- The adjoint of `BS` was wrong twice: an even-length Gaussian kernel offsets
  the naive adjoint, and `F.conv2d` performs cross-correlation rather than
  convolution. Both silently corrupt the gradient step of equation (14). The
  operators are now FFT-based and exact; a test asserts
  `<BSx, y> == <x, (BS)ᵀy>` to machine precision.
- The blur ran in float32 regardless of model dtype, so `.double()` silently
  lost precision. The kernel is now built at float64 and the transform follows
  the input's dtype.
- `Manifest.record` duplicated entries when a path was recorded both directly
  and through `record_tree`, which also overwrote split files'
  `DERIVED_REPORTED` tag with `COMPUTED`.
