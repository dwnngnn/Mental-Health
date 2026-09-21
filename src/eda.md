# Exploratory Data Analysis Pipeline

Tài liệu này mô tả pipeline phân tích khám phá dữ liệu (EDA) được thực hiện trong `eda.ipynb` trên bộ dữ liệu `mental_health.csv`.

## 1. Mục tiêu phân tích

Pipeline nhằm:

- Kiểm tra cấu trúc và chất lượng dữ liệu.
- Mô tả phân bố các biến liên quan đến sức khỏe tinh thần và công việc.
- Phát hiện outlier bằng phương pháp IQR.
- Phân tích mối liên hệ giữa `burnout_score` và các yếu tố liên quan.
- Chuẩn bị thông tin trực quan phục vụ bước phân tích hoặc xây dựng mô hình tiếp theo.

## 2. Đọc và chuẩn hóa dữ liệu

Dữ liệu được đọc từ file `mental_health.csv` bằng Pandas. Tên cột được loại bỏ khoảng trắng ở đầu/cuối và chuyển thành chữ thường.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

data = pd.read_csv("mental_health.csv")
data.columns = data.columns.str.strip().str.lower()
```

Notebook hiện chỉ giữ các bản ghi có `gender` là `Male` hoặc `Female`, sau đó tạo lại `employee_id` tuần tự. Việc lọc này cần được ghi nhận vì nó loại bỏ các nhóm giới tính khác khỏi phân tích.

```python
data = data[data["gender"].isin(["Male", "Female"])].reset_index(drop=True)
data["employee_id"] = range(1, len(data) + 1)
```

## 3. EDA 1: Kiểm tra kích thước và kiểu dữ liệu

Bước đầu tiên kiểm tra:

- Số dòng và số cột của dữ liệu.
- Kiểu dữ liệu của từng cột.
- Các biến số và biến phân loại.

```python
print(data.shape)
print(data.dtypes)
```

Mục đích là xác định các cột có thể dùng trực tiếp cho thống kê, biểu đồ và tính tương quan.

## 4. EDA 2: Thống kê mô tả

`data.describe()` cung cấp các thống kê cơ bản cho biến số:

- Số lượng quan sát.
- Giá trị trung bình.
- Độ lệch chuẩn.
- Min, max.
- Các tứ phân vị Q1, Q2 và Q3.

```python
data.describe()
```

Các thống kê này giúp nhận biết sơ bộ độ phân tán, phạm vi giá trị và khả năng tồn tại outlier.

## 5. EDA 3: Kiểm tra chất lượng dữ liệu

Notebook lập báo cáo gồm số lượng giá trị thiếu và số lượng giá trị duy nhất của từng cột.

```python
quality_report = pd.DataFrame({
    "missing_values": data.isna().sum(),
    "unique_values": data.nunique()
})

print(f"Tổng dòng trùng lặp: {data.duplicated().sum()}")
```

Bước này giúp phát hiện:

- Cột có dữ liệu thiếu.
- Cột có ít giá trị khác nhau, có thể là biến nhị phân hoặc biến phân loại.
- Dòng dữ liệu bị trùng lặp.

## 6. EDA 4 và EDA 5: Phân tích phân bố

Các cell EDA tiếp theo trực quan hóa phân bố của:

- `burnout_level`.
- `gender`.
- `job_role`.
- Nhóm mức độ `phq9_score`.
- Nhóm mức độ `gad7_score`.
- `burnout_score`, `stress_score` và `deadline_pressure_score`.
- Nhóm tuổi.
- `seniority_level`.
- `work_hours_per_week`.
- `sleep_hours_per_night`.

Các biểu đồ được sử dụng gồm `countplot`, `histplot` và biểu đồ cột. Với các biến phân loại, thứ tự hiển thị được chỉ định trước để biểu đồ dễ đọc và có ý nghĩa hơn.

Ví dụ, `phq9_score` được chia thành các nhóm mức độ:

```python
phq9_bins = [0, 4, 9, 14, 19, 27]
phq9_labels = [
    "None (0-4)",
    "Mild (5-9)",
    "Moderate (10-14)",
    "Mod. Severe (15-19)",
    "Severe (20-27)",
]

data["phq9_group"] = pd.cut(
    data["phq9_score"],
    bins=phq9_bins,
    labels=phq9_labels,
)
```

Các biến `phq9_category` và `gad7_category` là biến phân loại dẫn xuất từ điểm số, nên không dùng đồng thời với điểm số trong ma trận tương quan.

## 7. EDA 6: Phát hiện outlier bằng IQR

EDA 6 chỉ tập trung vào sáu biến số sau:

```python
selected_columns = [
    "salary_usd",
    "sleep_hours_per_night",
    "work_hours_per_week",
    "deadline_pressure_score",
    "gad7_score",
    "phq9_score",
]
```

Với mỗi biến, các đại lượng được tính như sau:

$$
IQR = Q3 - Q1
$$

$$
	ext{Lower Bound} = Q1 - 1.5 \times IQR
$$

$$
	ext{Upper Bound} = Q3 + 1.5 \times IQR
$$

Một quan sát được xem là outlier nếu:

$$
value < \text{Lower Bound}
\quad\text{hoặc}\quad
value > \text{Upper Bound}
$$

Kết quả được lưu trong DataFrame `outlier_report`, gồm:

- Tên cột.
- Số lượng outlier.
- Tỷ lệ phần trăm outlier.
- Giá trị nhỏ nhất và lớn nhất.
- Ngưỡng dưới và ngưỡng trên.

Các outlier được trực quan hóa bằng boxplot ghép để quan sát vị trí và hướng lệch của chúng. Việc phát hiện outlier không đồng nghĩa với việc phải xóa dữ liệu; cần kiểm tra bối cảnh nghiệp vụ trước khi xử lý.

## 8. EDA 7: Phân tích tương quan với burnout_score

### 8.1. Nhóm biến được lựa chọn

`burnout_score` được chọn làm biến mục tiêu liên tục. Các biến phân tích gồm:

```python
correlation_columns = [
    "burnout_score",
    "age",
    "years_experience",
    "salary_usd",
    "work_hours_per_week",
    "sleep_hours_per_night",
    "uses_therapy",
    "ai_tools_daily",
    "deadline_pressure_score",
    "stress_score",
    "phq9_score",
    "gad7_score",
    "seeks_mental_health_support",
    "job_change_intention",
]
```

`employee_id` bị loại vì chỉ là mã định danh. Các biến `burnout_level`, `phq9_category` và `gad7_category` cũng không được đưa vào vì chúng là biến phân loại hoặc được tạo ra từ các điểm số liên quan.

### 8.2. Tính tương quan Spearman

```python
correlation_matrix = data[correlation_columns].corr(method="spearman")
```

Spearman được sử dụng vì phù hợp hơn khi dữ liệu có outlier, không phân phối chuẩn hoặc mối quan hệ có tính đơn điệu nhưng không hoàn toàn tuyến tính.

Ma trận tương quan được trực quan hóa bằng heatmap với thang màu từ `-1` đến `1`:

- Giá trị gần `1`: tương quan dương mạnh.
- Giá trị gần `-1`: tương quan âm mạnh.
- Giá trị gần `0`: tương quan yếu hoặc không rõ ràng.

### 8.3. Xếp hạng tương quan với biến mục tiêu

Notebook tạo thêm bảng `burnout_correlation` bằng cách lấy trị tuyệt đối của tương quan giữa từng biến và `burnout_score` rồi sắp xếp giảm dần.

```python
burnout_correlation = (
    correlation_matrix["burnout_score"]
    .drop("burnout_score")
    .abs()
    .sort_values(ascending=False)
    .to_frame("|Tương quan Spearman với burnout_score|")
)
```

Kết quả hiện tại cho thấy các biến có liên hệ mạnh nhất với `burnout_score` là:

1. `stress_score`.
2. `gad7_score`.
3. `phq9_score`.
4. `work_hours_per_week`.
5. `sleep_hours_per_night`.

Đây là mức độ liên hệ thống kê, không phải bằng chứng khẳng định quan hệ nhân quả. Ví dụ, tương quan cao giữa `stress_score` và `burnout_score` không chứng minh rằng stress là nguyên nhân duy nhất gây burnout.

## 9. Lưu ý khi diễn giải

- Tương quan không đồng nghĩa với ảnh hưởng nhân quả.
- `stress_score`, `phq9_score` và `gad7_score` có thể có nội dung đo lường gần nhau, vì vậy cần kiểm tra đa cộng tuyến trước khi xây dựng mô hình hồi quy.
- Các biến nhị phân như `uses_therapy`, `ai_tools_daily`, `seeks_mental_health_support` và `job_change_intention` có thể đưa vào tương quan, nhưng cần diễn giải thận trọng.
- Các biến dạng chữ như `gender`, `job_role`, `seniority_level` và `work_mode` nên được phân tích bằng boxplot, violin plot hoặc kiểm định so sánh nhóm; không nên đưa trực tiếp vào `corr()`.
- Không nên loại bỏ outlier chỉ dựa vào ngưỡng IQR. Cần phân biệt lỗi nhập liệu với những trường hợp thực tế nhưng hiếm.
- Nếu xây dựng mô hình dự đoán, cần chia train/test trước khi thực hiện các bước học tham số từ dữ liệu để tránh data leakage.

## 10. Tóm tắt pipeline

```text
Đọc dữ liệu
    -> Chuẩn hóa tên cột và lọc dữ liệu
    -> Kiểm tra kích thước, kiểu dữ liệu và chất lượng dữ liệu
    -> Thống kê mô tả
    -> Trực quan hóa các biến phân loại và biến số
    -> Phát hiện outlier bằng IQR và boxplot
    -> Chọn burnout_score làm mục tiêu
    -> Tính tương quan Spearman
    -> Xếp hạng các biến liên hệ với burnout_score
```
