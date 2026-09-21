# Pipeline tiền xử lý dữ liệu

Tài liệu này mô tả pipeline trong `preprocessing.ipynb`.

## 1. Mục tiêu

Pipeline thực hiện các bước:

1. Đọc và lọc dữ liệu đầu vào.
2. Loại bỏ bản ghi trùng lặp.
3. Loại bỏ các dòng thiếu giá trị target.
4. Tách target, loại ID và các biến gây rò rỉ dữ liệu.
5. Chia dữ liệu thành train/test có phân tầng theo target.
6. Loại bỏ các dòng có feature thiếu, one-hot encode dữ liệu phân loại và tùy chọn chuẩn hóa dữ liệu số.
7. Mã hóa target theo thứ tự mức độ burnout.
8. Gộp train và test để xuất thành một file CSV duy nhất.

## 2. Dữ liệu đầu vào

- File: `mental_health.csv`
- Target: `burnout_level`
- Chỉ giữ các bản ghi có `gender` là `Male` hoặc `Female`.

## 3. Các biến bị loại bỏ

Các cột sau không được đưa vào tập feature:

```python
TARGET = "burnout_level"
LEAKAGE_COLUMNS = [
    "employee_id",
    "burnout_score",
    "phq9_category",
    "gad7_category",
]
```

Lý do loại bỏ:

- `burnout_level`: biến mục tiêu cần dự đoán.
- `employee_id`: định danh, không mang ý nghĩa dự báo.
- `burnout_score`: có thể gây rò rỉ thông tin liên quan đến target.
- `phq9_category` và `gad7_category`: các biến phân loại được suy ra từ điểm số tương ứng.

## 4. Pipeline xử lý

### 4.1. Đọc và lọc dữ liệu

```python
import pandas as pd

data = pd.read_csv("mental_health.csv")
data.columns = data.columns.str.strip().str.lower()
data = data[data["gender"].isin(["Male", "Female"])].reset_index(drop=True)
data["employee_id"] = range(1, len(data) + 1)
```

### 4.2. Làm sạch dữ liệu

```python
model_data = data.copy()
model_data = model_data.drop_duplicates().reset_index(drop=True)
model_data = model_data.dropna(subset=["burnout_level"]).copy()
```

### 4.3. Tách feature và target

```python
TARGET = "burnout_level"
LEAKAGE_COLUMNS = [
    "employee_id",
    "burnout_score",
    "phq9_category",
    "gad7_category",
]

X = model_data.drop(columns=[TARGET] + LEAKAGE_COLUMNS)
y = model_data[TARGET]

valid_rows = X.notna().all(axis=1)
X = X.loc[valid_rows].reset_index(drop=True)
y = y.loc[valid_rows].reset_index(drop=True)
```

Nếu một feature bị thiếu ở một dòng, toàn bộ dòng đó bị loại bỏ. Pipeline không dùng phương pháp điền giá trị thiếu.

### 4.4. Chia train/test

Dữ liệu được chia theo tỷ lệ 80/20. Tham số `stratify=y` giữ tỷ lệ các lớp target tương đối đồng đều giữa train và test.

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y,
)
```

### 4.5. Dựng pipeline biến đổi dữ liệu

- Cột số: dùng `StandardScaler` khi `USE_STANDARDIZATION = True`; nếu tắt thì giữ nguyên bằng `passthrough`.
- Cột phân loại: mã hóa one-hot.
- Các dòng có feature thiếu đã bị loại bỏ ở bước trước.

```python
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

USE_STANDARDIZATION = False

numeric_features = X.select_dtypes(include="number").columns.tolist()
categorical_features = X.select_dtypes(include="object").columns.tolist()

numeric_pipeline = (
    Pipeline([("scaler", StandardScaler())])
    if USE_STANDARDIZATION
    else "passthrough"
)

categorical_pipeline = Pipeline([
    ("encoder", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
])

preprocessor = ColumnTransformer([
    ("numeric", numeric_pipeline, numeric_features),
    ("categorical", categorical_pipeline, categorical_features),
])
```

### 4.6. Fit và biến đổi dữ liệu

Pipeline chỉ được fit trên tập train. Sau đó pipeline đã fit được dùng để biến đổi cả train và test, giúp tránh rò rỉ dữ liệu từ test vào quá trình huấn luyện.

- `fit`: học quy tắc xử lý từ dữ liệu train, như giá trị trung bình hoặc các nhóm phân loại.
- `transform`: áp dụng quy tắc đã học để chuyển dữ liệu sang dạng phù hợp cho mô hình.
- `fit_transform`: thực hiện cả hai thao tác trên tập train.

Tập test chỉ dùng `transform`, không dùng `fit`, để tránh làm lộ thông tin test cho quá trình huấn luyện.

```python
X_train_processed = preprocessor.fit_transform(X_train)
X_test_processed = preprocessor.transform(X_test)
```

Target được mã hóa theo đúng thứ tự mức độ burnout.

```python
burnout_mapping = {
    "Low": 0,
    "Moderate": 1,
    "High": 2,
    "Severe": 3,
}

y_train_encoded = y_train.map(burnout_mapping).to_numpy()
y_test_encoded = y_test.map(burnout_mapping).to_numpy()
processed_feature_names = preprocessor.get_feature_names_out()
```

Các giá trị `0` đến `3` thể hiện thứ bậc tăng dần của mức độ burnout. Với bài toán phân loại đa lớp thông thường, các nhãn này vẫn là mã lớp; không nên chuẩn hóa target bằng `StandardScaler`.

## 5. Gộp và xuất file

Train và test được chuyển thành DataFrame, bổ sung target và target đã mã hóa, sau đó nối theo chiều dọc thành một DataFrame duy nhất.

```python
train_export = pd.DataFrame(
    X_train_processed,
    columns=processed_feature_names,
)
test_export = pd.DataFrame(
    X_test_processed,
    columns=processed_feature_names,
)

train_export[TARGET] = y_train.reset_index(drop=True)
test_export[TARGET] = y_test.reset_index(drop=True)
train_export[f"{TARGET}_encoded"] = y_train_encoded
test_export[f"{TARGET}_encoded"] = y_test_encoded

combined_export = pd.concat(
    [train_export, test_export],
    ignore_index=True,
)

file_suffix = "standardized_filtered" if USE_STANDARDIZATION else "preprocessed_filtered"
combined_path = f"{file_suffix}.csv"
combined_export.to_csv(combined_path, index=False)

print(f"Đã xuất: {combined_path} - {combined_export.shape}")
```

## 6. File đầu ra

- File đầu ra là `preprocessed_filtered.csv` khi tắt chuẩn hóa hoặc `standardized_filtered.csv` khi bật chuẩn hóa.
- Chứa toàn bộ dữ liệu sau tiền xử lý; dữ liệu số chỉ được chuẩn hóa khi `USE_STANDARDIZATION = True`.
- Không tạo riêng file train và test.
- Các cột feature số được chuẩn hóa bằng `StandardScaler` khi bật tùy chọn chuẩn hóa.
- Các cột phân loại đã được mã hóa one-hot.
- Hai cột target được giữ lại:
  - `burnout_level`
  - `burnout_level_encoded`

## 7. Thứ tự chạy notebook

Chạy lần lượt 8 cell trong `preprocessing.ipynb`:

1. Đọc và lọc dữ liệu.
2. Loại bản ghi trùng lặp.
3. Xử lý target thiếu.
4. Tách feature và target.
5. Chia train/test.
6. Dựng pipeline one-hot và tùy chọn chuẩn hóa.
7. Fit pipeline, biến đổi dữ liệu và mã hóa target.
8. Gộp dữ liệu và xuất file CSV.
