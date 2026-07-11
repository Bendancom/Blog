# Blog / 博客

岑白Bd的博客

Bendancom's blog

# TODO / 待办

- [x] sitemap
- [x] incremental build

# To Run Locally

(If you are using NixOS or prefer nix, see the next section.)

1. Install uv

2. Run

```sh
cd Blog

uv run build.py build
uv run python -m http.server 0 --directory public
```

## To Run Locally on NixOS

```sh
cd Blog

nix develop

uv run build.py build
uv run python -m http.server 0 --directory public
```
