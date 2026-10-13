"""Generate a realistic, synthetic retail sales dataset for an Indian retail chain.

Uses only the Python standard library, so it runs anywhere:

    python data/generate_data.py            # writes CSVs into data/
    python data/generate_data.py --seed 7   # a different but reproducible dataset

The data is synthetic. Patterns such as festival-season peaks, weekend traffic,
repeat customers and discount effects are built in on purpose so the SQL
analysis has something real to find.
"""
import argparse
import csv
import datetime as dt
import random
from pathlib import Path

OUT = Path(__file__).resolve().parent

START = dt.date(2024, 1, 1)
END = dt.date(2025, 12, 31)

STORES = [
    # city, region, store_type, opened
    ("Pune", "West", "Mall", "2019-03-15"),
    ("Mumbai", "West", "Mall", "2018-07-01"),
    ("Ahmedabad", "West", "High Street", "2020-11-20"),
    ("Nagpur", "West", "Express", "2022-02-10"),
    ("Hyderabad", "South", "Mall", "2018-12-05"),
    ("Bengaluru", "South", "Mall", "2018-04-18"),
    ("Chennai", "South", "High Street", "2019-09-09"),
    ("Kochi", "South", "Express", "2021-06-30"),
    ("Delhi", "North", "Mall", "2018-10-12"),
    ("Jaipur", "North", "High Street", "2020-01-25"),
    ("Lucknow", "North", "Express", "2022-08-14"),
    ("Kolkata", "East", "High Street", "2019-05-02"),
]
STORE_WEIGHT = {"Mall": 1.6, "High Street": 1.0, "Express": 0.6}

CATEGORIES = {
    # category: (subcategories, price range INR, margin range, popularity)
    "Electronics": (["Mobiles", "Audio", "Accessories", "Smart Home"], (499, 34999), (0.08, 0.18), 0.9),
    "Home & Kitchen": (["Cookware", "Appliances", "Storage", "Decor"], (199, 8999), (0.20, 0.35), 1.1),
    "Fashion": (["Men", "Women", "Kids", "Footwear"], (299, 4999), (0.35, 0.55), 1.3),
    "Grocery": (["Staples", "Snacks", "Beverages", "Personal Care"], (40, 899), (0.08, 0.15), 2.2),
    "Beauty": (["Skincare", "Haircare", "Makeup", "Fragrance"], (149, 2999), (0.30, 0.50), 1.0),
    "Sports": (["Fitness", "Cricket", "Outdoor", "Cycling"], (299, 14999), (0.20, 0.35), 0.6),
    "Books": (["Fiction", "Exam Prep", "Children", "Self-help"], (99, 999), (0.15, 0.30), 0.7),
    "Toys": (["Board Games", "Educational", "Soft Toys", "Outdoor Play"], (199, 3499), (0.30, 0.45), 0.6),
}
BRAND_WORDS = ["Nova", "Kiran", "Urban", "Prime", "Sagar", "Lotus", "Tara", "Veda", "Zen", "Aura"]

PAYMENT_BY_YEAR = {
    2024: (["UPI", "Card", "Cash", "Wallet"], [0.46, 0.27, 0.19, 0.08]),
    2025: (["UPI", "Card", "Cash", "Wallet"], [0.55, 0.25, 0.13, 0.07]),
}
CITIES = [s[0] for s in STORES]


def daterange(a, b):
    d = a
    while d <= b:
        yield d
        d += dt.timedelta(days=1)


def season_factor(d):
    f = 1.0
    if d.month in (10, 11):          # Navratri / Diwali festive season
        f *= 1.65
    elif d.month == 12:              # year-end sales
        f *= 1.25
    elif d.month in (6, 7):          # monsoon dip
        f *= 0.85
    if d.weekday() >= 5:             # weekends
        f *= 1.35
    f *= 1.0 + 0.12 * (d.year - 2024)  # ~12% growth in 2025
    return f


def main(seed):
    rnd = random.Random(seed)

    # ---- dim_date
    dates = []
    for d in daterange(START, END):
        dates.append({
            "date_key": int(d.strftime("%Y%m%d")),
            "full_date": d.isoformat(),
            "year": d.year,
            "quarter": (d.month - 1) // 3 + 1,
            "month": d.month,
            "month_name": d.strftime("%B"),
            "day_of_week": d.strftime("%A"),
            "is_weekend": 1 if d.weekday() >= 5 else 0,
            "is_festive_season": 1 if d.month in (10, 11) else 0,
        })

    # ---- dim_store
    stores = []
    for i, (city, region, stype, opened) in enumerate(STORES, 1):
        stores.append({"store_key": i, "store_name": f"{city} {stype}", "city": city,
                       "region": region, "store_type": stype, "opened_date": opened})

    # ---- dim_product
    products = []
    pk = 1
    for cat, (subs, (lo, hi), (mlo, mhi), _pop) in CATEGORIES.items():
        for sub in subs:
            for _ in range(4):
                price = round(rnd.uniform(lo, hi) / 10) * 10 - 1
                price = max(price, lo)
                margin = rnd.uniform(mlo, mhi)
                products.append({
                    "product_key": pk,
                    "product_name": f"{rnd.choice(BRAND_WORDS)} {sub} {rnd.choice(['Classic', 'Plus', 'Pro', 'Lite', 'Max', 'Essential'])}",
                    "category": cat,
                    "subcategory": sub,
                    "brand": rnd.choice(BRAND_WORDS),
                    "unit_price": f"{price:.2f}",
                    "unit_cost": f"{price * (1 - margin):.2f}",
                    "launch_date": (START + dt.timedelta(days=rnd.randint(-400, 500))).isoformat(),
                })
                pk += 1
    # a handful of products that never sell (for the slow-mover query)
    for j in range(4):
        products.append({
            "product_key": pk, "product_name": f"Legacy Item {j + 1}", "category": "Home & Kitchen",
            "subcategory": "Decor", "brand": "Legacy", "unit_price": "1499.00", "unit_cost": "1100.00",
            "launch_date": "2023-01-01"})
        pk += 1
    sellable = [p for p in products if p["brand"] != "Legacy"]
    prod_weights = [CATEGORIES[p["category"]][3] * rnd.uniform(0.3, 1.7) for p in sellable]

    # ---- dim_customer
    customers = []
    for ck in range(1, 3001):
        signup = START + dt.timedelta(days=rnd.randint(-300, 700))
        customers.append({
            "customer_key": ck,
            "customer_code": f"CUST{ck:05d}",
            "city": rnd.choice(CITIES),
            "age_band": rnd.choices(["18-24", "25-34", "35-44", "45-54", "55+"], [0.18, 0.34, 0.25, 0.14, 0.09])[0],
            "loyalty_tier": rnd.choices(["Bronze", "Silver", "Gold"], [0.6, 0.3, 0.1])[0],
            "signup_date": min(signup, END).isoformat(),
        })
    # heavy shoppers make repeat-purchase patterns realistic
    cust_weight = [{"Bronze": 1.0, "Silver": 2.2, "Gold": 4.5}[c["loyalty_tier"]] * rnd.paretovariate(2.5)
                   for c in customers]
    cust_by_city = {}
    for c, w in zip(customers, cust_weight):
        cust_by_city.setdefault(c["city"], ([], []))
        cust_by_city[c["city"]][0].append(c)
        cust_by_city[c["city"]][1].append(w)

    # ---- fact_sales (one row per order line)
    sales = []
    sid = 1
    oid = 1
    for d in dates:
        day = dt.date.fromisoformat(d["full_date"])
        for s in stores:
            base = 1.6 * STORE_WEIGHT[s["store_type"]] * season_factor(day)
            n_orders = max(0, int(rnd.gauss(base, base * 0.35) + 0.5))
            for _ in range(n_orders):
                # 85% of shoppers are local to the store's city
                if rnd.random() < 0.85:
                    pool, w = cust_by_city[s["city"]]
                    cust = rnd.choices(pool, w)[0]
                else:
                    cust = rnd.choices(customers, cust_weight)[0]
                pay_opts, pay_w = PAYMENT_BY_YEAR[day.year]
                payment = rnd.choices(pay_opts, pay_w)[0]
                n_lines = rnd.choices([1, 2, 3, 4], [0.45, 0.30, 0.17, 0.08])[0]
                for prod in rnd.sample(rnd.choices(sellable, prod_weights, k=n_lines * 3), n_lines):
                    qty = rnd.choices([1, 2, 3, 4], [0.7, 0.2, 0.07, 0.03])[0]
                    if prod["category"] == "Grocery":
                        qty += rnd.randint(0, 3)
                    disc = rnd.choices([0, 5, 10, 20, 30], [0.5, 0.2, 0.15, 0.1, 0.05])[0]
                    if d["is_festive_season"] and rnd.random() < 0.4:
                        disc = max(disc, 20)
                    price = float(prod["unit_price"])
                    cost = float(prod["unit_cost"])
                    net = round(price * qty * (1 - disc / 100), 2)
                    sales.append({
                        "sales_id": sid, "order_id": oid, "date_key": d["date_key"],
                        "store_key": s["store_key"], "product_key": prod["product_key"],
                        "customer_key": cust["customer_key"], "quantity": qty,
                        "unit_price": f"{price:.2f}", "discount_pct": disc,
                        "net_amount": f"{net:.2f}", "cost_amount": f"{cost * qty:.2f}",
                        "payment_method": payment,
                    })
                    sid += 1
                oid += 1

    for name, rows in [("dim_date", dates), ("dim_store", stores), ("dim_product", products),
                       ("dim_customer", customers), ("fact_sales", sales)]:
        with open(OUT / f"{name}.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()), lineterminator="\n")
            w.writeheader()
            w.writerows(rows)
        print(f"{name:13s} {len(rows):>7,} rows")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=42)
    main(ap.parse_args().seed)
