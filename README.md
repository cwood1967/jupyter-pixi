# jupyter-env

JupyterLab + napari image-analysis environment, managed with [pixi](https://pixi.sh).

## Environments

| Environment | torch build | Platforms |
|---|---|---|
| `default` | CPU (PyPI arm64/MPS build on macOS) | linux-64, osx-arm64, win-64 |
| `cuda` | CUDA 13.0 (`download.pytorch.org/whl/cu130`) | linux-64, win-64 |

Python comes from conda-forge; all other packages come from PyPI, pinned in `pixi.lock`.

## Usage

```bash
pixi run lab              # JupyterLab, CPU env
pixi run -e cuda lab      # JupyterLab, CUDA env
pixi run -e cuda napari   # napari, CUDA env
pixi shell -e cuda        # activate the env in a shell
```

## Detached environments

Environments are stored outside the checkout, so `.pixi/` holds no env.

- **Linux/HPC:** set the location once in your global config:
  `pixi config set --global detached-environments /scratch/$USER/pixi_envs`
- **Windows launchers:** set `detached-environments` to `%USERPROFILE%\pixi-envs`
  (e.g. `C:\Users\<user>\pixi-envs`) in the project-local `.pixi\config.toml`.
- **Mac launchers:** set `detached-environments = true`, which puts envs in pixi's
  cache dir.

Run `pixi info` to see where a project's envs live.

## Updating dependencies

Edit `pyproject.toml`, then run `pixi lock` and commit `pixi.lock`. The launchers
install with `--frozen`, so the committed lock file is what users get.
