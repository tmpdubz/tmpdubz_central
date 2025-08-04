{
  description = "Rails app with Nix, PostgreSQL, Redis, Sidekiq";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ruby = pkgs.ruby_3_2;

        postgresDataDir = ".pgdata";
        redisDataDir = ".redis";

        # Shell apps
        redisApp = pkgs.writeShellApplication {
          name = "start-redis";
          runtimeInputs = [ pkgs.redis ];
          text = ''
            set -euo pipefail
            export REDIS_DATA_DIR=${redisDataDir}
            mkdir -p "$REDIS_DATA_DIR"
            echo "🚀 Starting Redis..."
            redis-server --dir "$REDIS_DATA_DIR"
          '';
        };

        postgresApp = pkgs.writeShellApplication {
          name = "start-db";
          runtimeInputs = [ pkgs.postgresql ];
          text = ''
            set -euo pipefail
            export PGDATA=${postgresDataDir}
            mkdir -p "$PGDATA"
            if [ ! -f "$PGDATA/PG_VERSION" ]; then
              echo "⏳ Initializing Postgres data directory..."
              initdb -D "$PGDATA"
            fi
            echo "🚀 Starting Postgres..."
            pg_ctl -D "$PGDATA" -l "$PGDATA/logfile" start
          '';
        };

        bundlerApp = (pkgs.bundlerEnv {
          inherit ruby;
          name = "rails-app";
          gemdir = ./.;
        }).rubyEnv;

      in {
        devShells.default = pkgs.mkShell {
          name = "rails-env";

          packages = with pkgs; [
            ruby
            bundler
            nodejs
            yarn
            postgresql
            redis
            hivemind
            pkg-config
            libffi
            zlib
            libyaml
            readline
            imagemagick
          ];

          shellHook = ''
            export DATABASE_URL="postgres://postgres:password@localhost:5432/my_rails_app_development"
            export REDIS_URL="redis://localhost:6379/0"

            echo "💡 Welcome to the Rails dev shell"
            echo "   Use: nix run .#start-db    to launch PostgreSQL"
            echo "        nix run .#start-redis to launch Redis"
            echo "   Or:  hivemind Procfile.dev to run everything together"
          '';
        };

        apps = {
          start-db = {
            type = "app";
            program = "${postgresApp}/bin/start-db";
          };

          start-redis = {
            type = "app";
            program = "${redisApp}/bin/start-redis";
          };

          default = {
            type = "app";
            program = "${bundlerApp}/bin/rails";
          };
        };

        packages = {
          default = bundlerApp;
          rails-app = bundlerApp;
        };
      });
}
