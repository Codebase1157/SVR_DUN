# Contributing

## Setup

```bash
pip install -e ".[dev,data]"
pytest -q
ruff check svrdun tests scripts
```


Equally: if the paper does not state something, do not quietly choose a value
and move on. Choose it, mark it `_note` in the config, and add it to
[docs/GAPS.md](docs/GAPS.md).

## Changing the protocol

`svrdun/configs.py` derives every config from `svrdun.reported.PAPER_CONFIG`,
and `validate()` rejects a config that departs from it without declaring the
departure in `meta.deviates_from_paper`. If you need to change a protocol
value, change it in `PAPER_CONFIG` with a source, and regenerate:

```bash
svrdun make-configs -o configs
```

CI checks the configs regenerate identically, so a hand-edited config fails.

## Tests

Mathematical properties are what the tests are for — adjointness, monotonicity,
the bounds Proposition 2 asserts — rather than accuracy against published
numbers, which this code does not claim to reproduce.

```bash
pytest -q                  # everything
pytest -q -m "not slow"    # skip the ones that build or train the network
```

Mark anything that trains or builds the model `@pytest.mark.slow`, and anything
needing a real dataset `@pytest.mark.needs_data`.

## Commits and pull requests

Keep the subject line under ~72 characters and say what changed and why.
A pull request should state which of the three provenance classes its outputs
fall into, and whether it changes anything in `docs/GAPS.md`.
