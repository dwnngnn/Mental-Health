USE MentalHealth;
GO

-- 1. Xóa các bảng cũ theo thứ tự bảng con trước, bảng cha sau
DROP TABLE IF EXISTS Mental_Health_Records;
DROP TABLE IF EXISTS Work_Metrics;
DROP TABLE IF EXISTS Job_Profiles;
DROP TABLE IF EXISTS Employees;
GO

-- 2. Tạo lại cấu trúc các bảng khớp hoàn toàn với tên cột trong CSV
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(50)
);

CREATE TABLE Job_Profiles (
    job_profiles_id INT PRIMARY KEY,
    employee_id INT,
    job_role VARCHAR(100),
    seniority_level VARCHAR(50),
    years_experience INT,
    work_mode VARCHAR(50),
    salary_usd DECIMAL(18,2),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Work_Metrics (
    metric_id INT PRIMARY KEY,
    employee_id INT,
    work_hours_per_week DECIMAL(5,2),
    ai_tools_daily INT,
    deadline_pressure_score DECIMAL(5,2),
    job_change_intention INT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Mental_Health_Records (
    record_id INT PRIMARY KEY,
    employee_id INT,
    sleep_hours_per_night DECIMAL(4,2),
    uses_therapy INT,
    stress_score DECIMAL(5,2),
    burnout_score DECIMAL(5,2),
    phq9_score DECIMAL(5,2),
    phq9_category VARCHAR(100),
    gad7_score DECIMAL(5,2),
    gad7_category VARCHAR(100),
    burnout_level VARCHAR(100),
    seeks_mental_health_support INT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
GO

-- 3. Nạp dữ liệu bằng BULK INSERT (dùng FIELDTERMINATOR = ',' và ROWTERMINATOR = '\n')
BULK INSERT Employees
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\employees.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT Job_Profiles
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\job_profiles.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT Work_Metrics
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\work_metrics.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT Mental_Health_Records
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\mental_health_records.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK
);
GO