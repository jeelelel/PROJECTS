#!/usr/bin/env python3
"""Run basic EDA over ALS-style water sample JSON exports."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate basic pandas EDA outputs for a water sample JSON file."
    )
    parser.add_argument("--input", required=True, help="Path to JSON file.")
    parser.add_argument(
        "--output",
        default="outputs",
        help="Directory where outputs are written (default: outputs).",
    )
    return parser.parse_args()


def parse_result_value(value: Any) -> tuple[float | None, str | None, bool | None]:
    """Return (numeric_value, category, is_non_detect)."""
    if value is None:
        return None, None, None

    text = str(value).strip()
    if text in {"", "-", "--"}:
        return None, None, None

    lowered = text.lower()
    if lowered in {"yes", "no"}:
        return None, lowered, None

    if text.startswith("<"):
        threshold = text[1:].replace(",", "").strip()
        try:
            return float(threshold), "below_reporting_limit", True
        except ValueError:
            return None, "below_reporting_limit", True

    numeric_text = text.replace(",", "")
    try:
        return float(numeric_text), "detected", False
    except ValueError:
        return None, "text", None


def load_results(input_path: Path) -> pd.DataFrame:
    with input_path.open("r", encoding="utf-8") as fp:
        payload = json.load(fp)

    if not isinstance(payload, dict) or "Results" not in payload:
        raise ValueError("Input JSON must be an object with a 'Results' field.")

    if not isinstance(payload["Results"], list):
        raise ValueError("'Results' must be a list.")

    df = pd.DataFrame(payload["Results"])
    if df.empty:
        raise ValueError("No rows found under 'Results'.")
    return df


def clean_results(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    for col in ("SampleDate", "ReceivedDate", "AnalysisDate"):
        if col in cleaned.columns:
            cleaned[col] = pd.to_datetime(cleaned[col], dayfirst=True, errors="coerce")

    if "Result" in cleaned.columns:
        parsed = cleaned["Result"].apply(parse_result_value)
        parsed_df = pd.DataFrame(
            parsed.tolist(),
            columns=["result_numeric", "result_category", "is_non_detect"],
            index=cleaned.index,
        )
        cleaned = pd.concat([cleaned, parsed_df], axis=1)

    return cleaned


def build_compound_summary(df: pd.DataFrame) -> pd.DataFrame:
    numeric = df[df["result_numeric"].notna()].copy()
    if numeric.empty:
        return pd.DataFrame(
            columns=[
                "Compound",
                "Units",
                "rows",
                "min",
                "median",
                "max",
                "mean",
            ]
        )

    summary = (
        numeric.groupby(["Compound", "Units"], dropna=False)["result_numeric"]
        .agg(rows="count", min="min", median="median", max="max", mean="mean")
        .reset_index()
        .sort_values(["rows", "Compound"], ascending=[False, True])
    )
    return summary


def build_sample_summary(df: pd.DataFrame) -> pd.DataFrame:
    sample_col = "LabSampleID" if "LabSampleID" in df.columns else "SampleID1"
    summary = (
        df.groupby(sample_col, dropna=False)
        .agg(
            rows=(sample_col, "count"),
            compounds=("Compound", "nunique"),
            methods=("AnalysisMethod", "nunique"),
            numeric_results=("result_numeric", lambda s: s.notna().sum()),
            non_detects=(
                "is_non_detect",
                lambda s: s.fillna(False).astype(bool).sum(),
            ),
        )
        .reset_index()
        .sort_values("rows", ascending=False)
    )
    return summary


def build_missingness_summary(df: pd.DataFrame) -> pd.DataFrame:
    missing_pct = (df.isna().mean() * 100).round(2).sort_values(ascending=False)
    summary = missing_pct.rename("missing_pct").reset_index(names="column_name")
    return summary


def table_block(df: pd.DataFrame, max_rows: int = 10) -> str:
    if df.empty:
        return "_No rows to display._"
    preview = df.head(max_rows)
    return "```\n" + preview.to_string(index=False) + "\n```"


def write_report(
    cleaned: pd.DataFrame,
    compound_summary: pd.DataFrame,
    sample_summary: pd.DataFrame,
    missingness_summary: pd.DataFrame,
    output_dir: Path,
) -> None:
    numeric_count = int(cleaned["result_numeric"].notna().sum())
    non_detect_count = int(cleaned["is_non_detect"].fillna(False).astype(bool).sum())
    unique_samples = (
        int(cleaned["LabSampleID"].nunique(dropna=True))
        if "LabSampleID" in cleaned.columns
        else int(cleaned["SampleID1"].nunique(dropna=True))
    )
    unique_compounds = int(cleaned["Compound"].nunique(dropna=True))
    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    report_lines = [
        "# Water Sample EDA Report",
        "",
        f"Generated at: **{generated_at}**",
        "",
        "## Overview",
        "",
        f"- Rows: **{len(cleaned)}**",
        f"- Unique samples: **{unique_samples}**",
        f"- Unique compounds: **{unique_compounds}**",
        f"- Numeric results parsed: **{numeric_count}**",
        f"- Non-detect results (`<x`): **{non_detect_count}**",
        "",
        "## Top compounds by numeric row count",
        "",
        table_block(compound_summary, max_rows=12),
        "",
        "## Sample-level summary",
        "",
        table_block(sample_summary, max_rows=12),
        "",
        "## Highest missingness columns",
        "",
        table_block(missingness_summary, max_rows=12),
        "",
    ]

    (output_dir / "eda_report.md").write_text("\n".join(report_lines), encoding="utf-8")


def main() -> None:
    args = parse_args()
    input_path = Path(args.input).expanduser().resolve()
    output_dir = Path(args.output).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    raw = load_results(input_path)
    cleaned = clean_results(raw)

    compound_summary = build_compound_summary(cleaned)
    sample_summary = build_sample_summary(cleaned)
    missingness_summary = build_missingness_summary(cleaned)

    cleaned.to_csv(output_dir / "cleaned_results.csv", index=False)
    compound_summary.to_csv(output_dir / "compound_numeric_summary.csv", index=False)
    sample_summary.to_csv(output_dir / "sample_summary.csv", index=False)
    missingness_summary.to_csv(output_dir / "missingness_summary.csv", index=False)
    write_report(
        cleaned=cleaned,
        compound_summary=compound_summary,
        sample_summary=sample_summary,
        missingness_summary=missingness_summary,
        output_dir=output_dir,
    )

    print(f"EDA completed. Outputs written to: {output_dir}")


if __name__ == "__main__":
    main()
