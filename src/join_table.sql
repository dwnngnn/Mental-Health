USE MentalHealth;
GO

SELECT 
    -- Bảng Employees
    e.employee_id,
    e.age,
    e.gender,
    
    -- Bảng Job_Profiles 
    j.job_role,
    j.seniority_level,
    j.years_experience,
    j.work_mode,
    j.salary_usd,
    
    -- Bảng Work_Metrics
    w.work_hours_per_week,
    w.ai_tools_daily,
    w.deadline_pressure_score,
    w.job_change_intention,
    
    -- Bảng Mental_Health_Records
    m.sleep_hours_per_night,
    m.uses_therapy,
    m.stress_score,
    m.burnout_score,
    m.phq9_score,
    m.phq9_category,
    m.gad7_score,
    m.gad7_category,
    m.burnout_level,
    m.seeks_mental_health_support

FROM Employees e
INNER JOIN Job_Profiles j ON e.employee_id = j.employee_id
INNER JOIN Work_Metrics w ON e.employee_id = w.employee_id
INNER JOIN Mental_Health_Records m ON e.employee_id = m.employee_id;
GO