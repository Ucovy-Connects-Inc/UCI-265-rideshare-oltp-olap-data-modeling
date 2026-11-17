from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"

def read_csv(name):
    with (DATA / name).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))

def test_all_expected_files_have_rows():
    names = [
        "riders.csv","drivers.csv","vehicles.csv","pricing_zones.csv",
        "rides.csv","payments.csv","ratings.csv"
    ]
    for name in names:
        assert read_csv(name), f"{name} has no rows"

def test_rider_ids_unique():
    rows = read_csv("riders.csv")
    ids = [r["rider_id"] for r in rows]
    assert len(ids) == len(set(ids))

def test_driver_ids_unique():
    rows = read_csv("drivers.csv")
    ids = [r["driver_id"] for r in rows]
    assert len(ids) == len(set(ids))

def test_ride_ids_unique():
    rows = read_csv("rides.csv")
    ids = [r["ride_id"] for r in rows]
    assert len(ids) == len(set(ids))

def test_ratings_in_range():
    for row in read_csv("ratings.csv"):
        assert 1 <= int(row["stars"]) <= 5
