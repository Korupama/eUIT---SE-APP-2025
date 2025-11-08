import csv
import random
from pathlib import Path

src = Path(r"d:\eUIT\scripts\database\other_data\ket_qua_hoc_tap_mau.csv")
out = Path(r"d:\eUIT\scripts\database\other_data\ket_qua_hoc_tap_mau_expanded.csv")

# student IDs to add: 23520542..23520589 (inclusive)
new_ids = list(range(23520542, 23520590))

random.seed(12345)  # deterministic output

with src.open(newline='', encoding='utf-8') as f_in:
    reader = csv.DictReader(f_in)
    rows = list(reader)
    fieldnames = reader.fieldnames

expanded = []
# keep original rows first
expanded.extend(rows)

for sid in new_ids:
    for r in rows:
        newr = r.copy()
        newr['mssv'] = str(sid)
        # for each score column, if original had a value, replace with random 5.0-10.0 rounded to 1 decimal
        for col in ['diem_qua_trinh', 'diem_giua_ki', 'diem_thuc_hanh', 'diem_cuoi_ki']:
            val = (r.get(col) or '').strip()
            if val != '':
                # random float between 5 and 10, rounded to nearest 0.5
                v = random.uniform(5.0, 10.0)
                v = round(v * 2) / 2.0  # nearest half
                # format: integer (e.g. 7) or one decimal for halves (e.g. 7.5)
                if float(v).is_integer():
                    newr[col] = str(int(v))
                else:
                    newr[col] = "{:.1f}".format(v)
            else:
                newr[col] = ''
        expanded.append(newr)

with out.open('w', newline='', encoding='utf-8') as f_out:
    writer = csv.DictWriter(f_out, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(expanded)

print(f"Wrote {len(expanded)} rows to {out}")
