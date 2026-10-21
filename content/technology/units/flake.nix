{
  description = "Bendancom's Blog development environment - article of units";
  inputs = {
    nixpkgs-proxy.url = "git+https://gh-proxy.com/https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";
  };

  outputs =
    { self, nixpkgs-proxy }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs-proxy.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages =
          (with pkgs; [
            python3
            zig
          ])
          ++ (with pkgs.python3.withPackages; [
            sympy
          ]);

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ ];
      };
    };
}
