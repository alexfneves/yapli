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
                    pkgs.websocat
                    pkgs.inotify-tools
                  ];

                  git-hooks.excludes = [ ".devenv" ];
                  git-hooks.hooks = {
                    clang-format.enable = true;
                    prettier.enable = true;
                  };

                  enterShell = ''
                    echo "Yet Another Platform for Learning Idioms"
                  '';

                  scripts = {
                    build.exec = ''
                      export INJA_INCLUDE_PATH=${pkgs.inja}/include
                      export JSON_INCLUDE_PATH=${pkgs.nlohmann_json}/include
                      echo "Building"
                      cd build && emcmake cmake .. && emmake make && cd ..
                      mv build/compile_commands.json .
                    '';
                    hot-reload.exec = ''
                      build
                      echo "Finishing building and sending the reload message to the websockets"
                      echo "reload" | websocat ws://127.0.0.1:1234
                    '';
                  };
                  processes = {
                    serve.exec = "http-server -p 8080 . -c-1";
                    watch.exec = "bash ./watch.bash";
                    reload-server.exec = "websocat -E -t ws-l:127.0.0.1:1234 broadcast:mirror:";
                  };
                }
              ];
            };
          });
    };
}
