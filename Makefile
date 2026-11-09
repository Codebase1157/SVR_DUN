.PHONY: help install dev test lint fmt verify quick figures notebook clean all

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

install:  ## install the package
	pip install -e .

dev:      ## install with test and lint extras
	pip install -e ".[dev,data]"

test:     ## run the test suite
	pytest -q

fast:     ## run the test suite, skipping model training
	pytest -q -m "not slow"

lint:     ## check style
	ruff check svrdun tests scripts

fmt:      ## fix what can be fixed automatically
	ruff check --fix svrdun tests scripts

verify:   ## check the published tables and regenerate configs/splits
	svrdun verify-tables
	svrdun make-configs -o /tmp/svrdun_configs
	diff -r --exclude=baselines.yaml configs /tmp/svrdun_configs
	svrdun make-splits -o /tmp/svrdun_splits
	diff -r splits /tmp/svrdun_splits
	svrdun recoverability --size 128

quick:    ## end-to-end QUICK run
	svrdun run -c configs/quick.yaml -o outputs/quick

figures:  ## motivation figures, no dataset needed
	svrdun figures -o outputs/figures

notebook: ## execute the Colab notebook headlessly
	python -c "import nbformat,sys; from nbclient import NotebookClient; \
	nb=nbformat.read('notebooks/SVR_DUN_Reproducibility.ipynb',as_version=4); \
	NotebookClient(nb,timeout=1800,kernel_name='python3',allow_errors=True, \
	resources={'metadata':{'path':'notebooks'}}).execute(); \
	e=[1 for c in nb.cells if c.cell_type=='code' for o in c.get('outputs',[]) \
	if o.get('output_type')=='error']; print('cells with errors:',len(e)); sys.exit(1 if e else 0)"

all: lint test verify  ## lint, test and verify

clean:    ## remove build and cache artifacts
	rm -rf build dist *.egg-info .pytest_cache .ruff_cache .coverage htmlcov
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
