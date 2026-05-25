# Smart Course Recommendation System

Prototype web-based Knowledge-Based System (KBS) that recommends university courses to students using a SWI-Prolog knowledge base and a Flask backend. The system follows a hybrid KADS + KBANN-inspired architecture: symbolic rules (Prolog) combined with historical success patterns to compute recommendation confidence.

Project structure

smart-course-recommender/
- app.py
- knowledge_base.pl
- requirements.txt
- README.md
- templates/
  - index.html
- static/
  - style.css
  - script.js

Key features
- Real Prolog reasoning for recommendations
- Explainable recommendations and rule tracing
- Confidence scoring (KBANN-inspired historical patterns)
- Prerequisite validation and risk warnings

Ubuntu 26.04 installation (tested steps)

1. Update and install system deps

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-dev build-essential swi-prolog libssl-dev libffi-dev libswipl-dev
```

2. Create a Python virtual environment and install Python deps

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

3. Notes on pyswip and SWI-Prolog

- `pyswip` is a Python interface to SWI-Prolog. It requires SWI-Prolog and development headers (`libswipl-dev`) so the C extensions can build and link.
- If you encounter errors installing `pyswip`, make sure `swipl` is on your PATH and `libswipl-dev` is installed.

Run the prototype

```bash
export FLASK_APP=app.py
flask run --host=0.0.0.0 --port=5000
```

Open http://localhost:5000 in a browser.

Troubleshooting

- If Prolog cannot be consulted, ensure `knowledge_base.pl` is readable and `swipl` is installed.
- If `pyswip` import fails, re-run `pip install pyswip` after installing `libswipl-dev` and `swi-prolog`.
- On Windows, install SWI-Prolog from https://www.swi-prolog.org/download/stable and ensure `swipl.exe` is on PATH.

How it works

- Frontend (`templates/index.html` + `static/`) collects student KCSE grades and preference.
- Backend (`app.py`) asserts student facts into the Prolog engine via `pyswip` and queries `recommend/3`, `explain/2`, and `risk/2` rules.
- `knowledge_base.pl` contains facts, rules, historical success patterns, and explanation traces.

Extending the KB

- Add new `prereq/2`, `pattern_success/2`, or augment `grade_profile/3` rules.
- Add domain-specific explanation rules to improve traceability.

Example test

1. Load the web UI and click `Load Sample` then `Get Recommendations`.
2. The UI will show ranked recommendations, explanation panel, and any warnings.

Screenshots (example descriptions)

- Dashboard view: Left column student form; right column recommendations and explanation panel.
- Recommendation card: shows course name and confidence badge.
- Explanation panel: concatenated trace of grade profile, prerequisites, interest and historical pattern score.
