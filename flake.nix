{
    description = "BendancomBlog development environment";
    inputs = {
        nixpkgs-proxy.url = "git+https://gh-proxy.com/https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";
    };

    outputs = { self, nixpkgs-proxy }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs-proxy.legacyPackages.${system};
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            packages = [ pkgs.uv ];
            UV_PYTHON = "${pkgs.python3}";
            UV_PYTHON_DOWNLOADS = "never";

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ ];
        };
    };
}
