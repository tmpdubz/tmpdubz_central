# tmpdubz Central
A rails app for experimentation, fun, and probably never profit.

This is a Ruby on Rails project configured for development using [Nix flakes](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html), [direnv](https://direnv.net/), and [hivemind](https://github.com/DarthSim/hivemind) for process management.

---

## ⚙️ Development Setup

This project uses:

- 🔄 **Nix** to provide consistent Ruby, Node.js, PostgreSQL, Redis, and system libraries
- 🔐 **direnv** to automatically load the environment
- 🧠 **Hivemind** to run dev services in parallel using a `Procfile.dev`

---

## 📦 Requirements

- [Nix](https://nixos.org/download.html)
- [direnv](https://direnv.net/)
- (Optional but helpful) [hivemind](https://github.com/DarthSim/hivemind)

---

## 🚀 Getting Started

1. **Enable the Nix environment**

   First, make sure `direnv` is installed and hooked into your shell.

   ```bash
   echo "use flake" > .envrc
   direnv allow
   ```

   This loads the dev environment with Ruby, Postgres, Redis, Yarn, etc.

2. **Set up the app**

   ```bash
   bundle install
   ```

3. **Run the app with all services**

   Use the built-in `bin/dev` script (or `hivemind` directly):

   ```bash
   bin/dev
   ```

   This runs:

   | Service  | Command                                |
   |----------|----------------------------------------|
   | `web`    | `bin/rails server -p 3000`             |
   | `worker` | `bundle exec sidekiq`                  |
   | `db`     | `nix run .#start-db`                   |
   | `redis`  | `nix run .#start-redis`                |

---

## 📄 `Procfile.dev`

This file defines how dev services are run together via `hivemind`:

```Procfile
web: bin/rails server -p 3000
worker: bundle exec sidekiq
db: nix run .#start-db
redis: nix run .#start-redis
```

You can add frontend tools (e.g. vite, esbuild) here as needed.

---

## 🗃️ Useful DB Commands

Use these inside the dev shell (`nix develop` or after `direnv allow`):

```bash
# Create and setup the database
bin/rails db:create
bin/rails db:migrate
bin/rails db:setup

# Drop the database
bin/rails db:drop

# Reset everything
bin/rails db:reset

# Open a Rails console
bin/rails console

# Run a single migration
bin/rails db:migrate:up VERSION=20230802000000
```

---

## 🧪 Running Tests

```bash
bin/rails test
# or with RSpec (if configured)
bin/rspec
```

---

## 🧼 Cleaning Up

To stop services started by `hivemind`, just press `Ctrl+C`. If you want to reset Postgres/Redis data, delete:

```bash
rm -rf .pgdata .redis
```

---

## 💬 Notes

- All dependencies (Ruby, Node, etc.) are managed via Nix and not installed globally.
- No need for Docker or RVM in development.
- Will later add Docker support for deployment if needed.

---

## 👤 Author

Tomasz Dubiel
🤖 Built with some Nix-powered magic.
