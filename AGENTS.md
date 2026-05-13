# AGENTS.md

## Cursor Cloud specific instructions

### Repository overview

This is a collection of independent student projects (not a unified product). The main runnable application is the **LivinHD Flask web app** at `hackatons/livinHD-main/`. Other sub-projects include Python scripts, R assignments, SQL queries, and static HTML games.

### LivinHD Flask app

- **Run:** `cd hackatons/livinHD-main && python3 main.py` — starts on `http://127.0.0.1:5000` with debug mode.
- Uses an embedded **SQLite** database at `hackatons/livinHD-main/database_new/database.db`. No external DB server needed.
- The `database.py` module opens a global `sqlite3` connection at import time; this can lock the database file for external tools. If you need to manipulate the DB outside the app, stop the Flask process first.
- The `requirements.txt` has old pinned versions (2021-era) that are incompatible with Python 3.12. Install only the core dependencies: `pip3 install flask flask-login flask-sqlalchemy`.
- The full signup flow requires completing both `/signup/` and `/signup_details/<email>` (fills in gender, relationship, language, units, interests, and initializes the todo list). Skipping the details step causes a 500 on login because the home page queries the todo table.

### Web games

- Static HTML/JS games at `web/flappy-bird/index.html` and `web/snake/snake.html`.
- Serve with any HTTP server, e.g. `cd web && python3 -m http.server 8080`.

### Python scripts

- `python/water-sample-eda/run_eda.py` — requires `pandas`. Run with `--input <json_file> --output <dir>`.
- `python/dynamic-programming.py` — stdlib only, no dependencies.

### Linting and testing

- No linting or testing frameworks are configured in this repository. There are no `package.json`, `pyproject.toml`, Makefile, CI/CD, or pre-commit hooks.
