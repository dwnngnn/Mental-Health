USE MentalHealth;
GO

DROP TABLE IF EXISTS Employee_Behavior_Attrition;
DROP TABLE IF EXISTS Mental_Health_Metrics;
DROP TABLE IF EXISTS Workload_Lifestyle;
DROP TABLE IF EXISTS Work_Context;
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    age INT,
    survey_year INT,
    country VARCHAR(100),
    gender VARCHAR(50)
);

CREATE TABLE Work_Context (
    work_context_id INT PRIMARY KEY,
    employee_id INT CONSTRAINT UQ_WorkContext_Employee UNIQUE,
    job_role VARCHAR(100),
    seniority_level VARCHAR(50),
    years_experience INT,
    work_mode VARCHAR(50),
    salary_usd DECIMAL(18,2),
    CONSTRAINT FK_WorkContext_Employees FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Workload_Lifestyle (
    workload_id INT PRIMARY KEY,
    employee_id INT CONSTRAINT UQ_WorkloadLifestyle_Employee UNIQUE,
    work_hours_per_week DECIMAL(5,2),
    sleep_hours_per_night DECIMAL(4,2),
    ai_tools_daily INT,
    hourly_wage_usd DECIMAL(18,2),
    work_life_balance_ratio DECIMAL(10,8),
    deadline_pressure_score DECIMAL(5,2),
    CONSTRAINT FK_WorkloadLifestyle_Employees FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Mental_Health_Metrics (
    metric_id INT PRIMARY KEY,
    employee_id INT CONSTRAINT UQ_MentalHealthMetrics_Employee UNIQUE,
    stress_score DECIMAL(5,2),
    burnout_score DECIMAL(5,2),
    burnout_level VARCHAR(100),
    phq9_score DECIMAL(5,2),
    phq9_category VARCHAR(100),
    gad7_score DECIMAL(5,2),
    gad7_category VARCHAR(100),
    total_score DECIMAL(5,2),
    CONSTRAINT FK_MentalHealthMetrics_Employees FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Employee_Behavior_Attrition (
    behavior_id INT PRIMARY KEY,
    employee_id INT CONSTRAINT UQ_EmployeeBehavior_Employee UNIQUE,
    uses_therapy INT,
    seeks_mental_health_support INT,
    job_change_intention INT,
    CONSTRAINT FK_EmployeeBehavior_Employees FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
GO

BULK INSERT Employees
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\employees.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK);

BULK INSERT Work_Context
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\work_context.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK);

BULK INSERT Workload_Lifestyle
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\workload_lifestyle.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK);

BULK INSERT Mental_Health_Metrics
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\mental_health_metrics.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK);

BULK INSERT Employee_Behavior_Attrition
FROM 'C:\TaiLieuHocTap\InteractiveDataVisualization\Mental-Health\data\emplyees_behavior_attrition.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n', 
    CODEPAGE = '65001',
    TABLOCK);
GO

SELECT 
    e.employee_id,
    e.age,
    e.survey_year,
    e.country,
    e.gender,
    c.job_role,
    c.seniority_level,
    c.years_experience,
    c.work_mode,
    c.salary_usd,
    w.work_hours_per_week,
    w.hourly_wage_usd,
    w.sleep_hours_per_night,
    w.work_life_balance_ratio,
    b.uses_therapy,
    w.ai_tools_daily,
    w.deadline_pressure_score,
    m.stress_score,
    m.burnout_score,
    m.phq9_score,
    m.phq9_category,
    m.gad7_score,
    m.gad7_category,
    m.total_score,
    m.burnout_level,
    b.seeks_mental_health_support,
    b.job_change_intention
FROM Employees e
INNER JOIN Work_Context c 
    ON e.employee_id = c.employee_id
INNER JOIN Workload_Lifestyle w 
    ON e.employee_id = w.employee_id
INNER JOIN Mental_Health_Metrics m 
    ON e.employee_id = m.employee_id
INNER JOIN Employee_Behavior_Attrition b 
    ON e.employee_id = b.employee_id;
GO