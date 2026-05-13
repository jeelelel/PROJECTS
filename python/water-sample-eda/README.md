# Water Sample EDA (Pandas)

This folder is a lightweight private-repo-ready starter for exploring ALS-style water sample JSON exports with pandas.

## 1) Quick start

```bash
cd python/water-sample-eda
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python run_eda.py --input "/path/to/WaterSample_2026-05-06T06_17_49.json" --output outputs
```

## 2) What gets generated

Running `run_eda.py` creates:

- `outputs/cleaned_results.csv` - flattened and cleaned table
- `outputs/compound_numeric_summary.csv` - numeric summary by compound + units
- `outputs/sample_summary.csv` - per-sample counts and detection summary
- `outputs/missingness_summary.csv` - missingness percentage by column
- `outputs/eda_report.md` - readable markdown report

## 3) Data assumptions

The script expects a JSON object with a top-level `Results` array, such as:

```json
{
  "Results": [...],
  "WorkorderCodes": [...],
  "Contacts": [...]
}
```

## 4) Make this a private GitHub repo

From your machine (or Cursor terminal with write-enabled GitHub auth), run:

```bash
cd python/water-sample-eda
git init
git add .
git commit -m "Initial pandas EDA project for water sample JSON"
gh repo create water-sample-eda --private --source=. --remote=origin --push
```

If this folder already lives inside another repo, create a new remote repo first, then push this project into it using your preferred git workflow.
