"""Draw the README charts from the query results in results/.

    pip install -r requirements.txt
    python scripts/make_charts.py

Charts are saved to docs/charts/. Colours follow a colour-blind-checked palette.
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "results"
OUT = ROOT / "docs" / "charts"
OUT.mkdir(parents=True, exist_ok=True)

BLUE, ORANGE, AQUA, YELLOW, MAGENTA, GREEN = "#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300"
INK, INK2, GRID, SURFACE = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb"

plt.rcParams.update({
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "font.family": "DejaVu Sans", "font.size": 10, "text.color": INK,
    "axes.edgecolor": GRID, "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2,
    "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.8, "axes.axisbelow": True,
    "axes.spines.top": False, "axes.spines.right": False, "axes.spines.left": False,
    "axes.titleweight": "bold", "axes.titlesize": 12, "axes.titlelocation": "left",
    "legend.frameon": False,
})


def rupees_lakh(x, _pos=None):
    return f"₹{x / 1e5:,.0f}L"


def save(fig, name):
    fig.tight_layout()
    fig.savefig(OUT / name, dpi=160)
    plt.close(fig)
    print("saved", name)


def monthly_yoy():
    df = pd.read_csv(RES / "03_year_over_year_by_month.csv")
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(months, df["revenue_2024"], color=BLUE, lw=2, marker="o", ms=4, label="2024")
    ax.plot(months, df["revenue_2025"], color=ORANGE, lw=2, marker="o", ms=4, label="2025")
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(rupees_lakh))
    ax.axvspan(8.5, 10.5, color=GRID, alpha=0.6, lw=0)
    ax.text(9.5, ax.get_ylim()[0], " Festive season", ha="center", va="bottom", color=INK2, fontsize=9)
    ax.set_title("Monthly revenue, 2024 vs 2025")
    ax.legend(loc="upper left")
    ax.grid(axis="x", visible=False)
    save(fig, "01_monthly_revenue_yoy.png")


def category_share_margin():
    df = pd.read_csv(RES / "06_category_revenue_share.csv").sort_values("revenue_share_pct")
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9, 4), sharey=True)
    a1.barh(df["category"], df["revenue_share_pct"], color=BLUE, height=0.6)
    a1.set_title("Share of revenue (%)")
    a2.barh(df["category"], df["margin_pct"], color=AQUA, height=0.6)
    a2.set_title("Profit margin (%)")
    for ax, col in ((a1, "revenue_share_pct"), (a2, "margin_pct")):
        ax.grid(axis="y", visible=False)
        for y, v in enumerate(df[col]):
            ax.text(v + 0.6, y, f"{v:.1f}", va="center", fontsize=8.5, color=INK2)
        ax.set_xlim(0, df[col].max() * 1.18)
    save(fig, "02_category_share_vs_margin.png")


def discount_margin():
    df = pd.read_csv(RES / "17_discount_impact_on_margin.csv")
    fig, ax = plt.subplots(figsize=(8, 4))
    for cat, color in (("Fashion", BLUE), ("Electronics", ORANGE), ("Grocery", AQUA)):
        d = df[df["category"] == cat]
        ax.plot(d["discount_pct"], d["margin_pct"], color=color, lw=2, marker="o", ms=5, label=cat)
    ax.axhline(0, color=INK2, lw=1)
    ax.set_xticks([0, 5, 10, 20, 30])
    ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _p: f"{x:.0f}%"))
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _p: f"{x:.0f}%"))
    ax.set_xlim(-1, 31)
    ax.set_xlabel("Discount given")
    ax.set_title("Profit margin by discount level")
    ax.legend(loc="lower left")
    save(fig, "03_discount_vs_margin.png")


def rfm_segments():
    df = pd.read_csv(RES / "14_rfm_segments.csv").sort_values("revenue_share_pct")
    fig, ax = plt.subplots(figsize=(8, 3.6))
    ax.barh(df["segment"], df["revenue_share_pct"], color=BLUE, height=0.6)
    for y, (share, n) in enumerate(zip(df["revenue_share_pct"], df["customers"])):
        ax.text(share + 0.8, y, f"{share:.1f}% of revenue · {n:,} customers", va="center", fontsize=8.5, color=INK2)
    ax.set_xlim(0, df["revenue_share_pct"].max() * 1.6)
    ax.grid(axis="y", visible=False)
    ax.set_title("Revenue share by customer segment (RFM)")
    save(fig, "04_rfm_segments.png")


def payment_mix():
    df = pd.read_csv(RES / "16_payment_method_mix.csv")
    p = df.pivot(index="payment_method", columns="year", values="share_pct").loc[["UPI", "Card", "Cash", "Wallet"]]
    x = range(len(p))
    fig, ax = plt.subplots(figsize=(7, 3.8))
    w = 0.36
    ax.bar([i - w / 2 - 0.01 for i in x], p[2024], width=w, color=BLUE, label="2024")
    ax.bar([i + w / 2 + 0.01 for i in x], p[2025], width=w, color=ORANGE, label="2025")
    for i, (a, b) in enumerate(zip(p[2024], p[2025])):
        ax.text(i - w / 2, a + 0.8, f"{a:.0f}%", ha="center", fontsize=8.5, color=INK2)
        ax.text(i + w / 2, b + 0.8, f"{b:.0f}%", ha="center", fontsize=8.5, color=INK2)
    ax.set_xticks(list(x), p.index)
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda v, _p: f"{v:.0f}%"))
    ax.grid(axis="x", visible=False)
    ax.set_title("Share of orders by payment method")
    ax.legend(loc="upper right")
    save(fig, "05_payment_mix.png")


def festive_moving_avg():
    df = pd.read_csv(RES / "20_daily_revenue_7day_moving_avg.csv", parse_dates=["full_date"])
    fig, ax = plt.subplots(figsize=(9, 3.8))
    ax.plot(df["full_date"], df["revenue"], color="#b9c9de", lw=1, label="Daily revenue")
    ax.plot(df["full_date"], df["moving_avg_7d"], color=BLUE, lw=2, label="7-day moving average")
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(rupees_lakh))
    ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter("%d %b"))
    ax.set_title("Daily revenue around the 2025 festive season")
    ax.legend(loc="upper left")
    ax.grid(axis="x", visible=False)
    save(fig, "06_festive_moving_average.png")


if __name__ == "__main__":
    monthly_yoy()
    category_share_margin()
    discount_margin()
    rfm_segments()
    payment_mix()
    festive_moving_avg()
