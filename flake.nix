{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
        devenv-test = self.devShells.${system}.default.config.test;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  # https://devenv.sh/reference/options/
                  packages = [
                    pkgs.emscripten
                    pkgs.nlohmann_json
                    pkgs.inja
                    pkgs.http-server
                  ];

                  enterShell = ''
                    echo "Yet Another Platform for Learning Idioms"
                  '';


                  scripts = {
                    build.exec = ''
                      export INJA_INCLUDE_PATH=${pkgs.inja}/include
                      export JSON_INCLUDE_PATH=${pkgs.nlohmann_json}/include
                      emcc src/main.cpp \
                        -std=c++17 \
                        -I"$INJA_INCLUDE_PATH" \
                        -I"$JSON_INCLUDE_PATH" \
                        -s WASM=1 \
                        -s ALLOW_MEMORY_GROWTH=1 \
                        -s MODULARIZE=1 \
                        -s EXPORT_NAME=createModule \
                        -s EXPORTED_RUNTIME_METHODS=ccall,cwrap \
                        -s NO_DISABLE_EXCEPTION_CATCHING \
                        -s ASSERTIONS=1 \
                        -s EXCEPTION_STACK_TRACES=1 \
                        -s DISABLE_EXCEPTION_THROWING=0 \
                        -g \
                        -fdebug-compilation-dir=".." \
                        --preload-file templates@/ \
                        --bind \
                        -o public/out.js
                    '';
                  };
                  processes.serve.exec = "http-server -p 8080 .";

                }
              ];
            };
          });
    };
}
