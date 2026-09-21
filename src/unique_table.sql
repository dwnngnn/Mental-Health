USE MentalHealth;
GO

ALTER TABLE Job_Profiles 
ADD CONSTRAINT UQ_JobProfiles_Employee UNIQUE (employee_id);

ALTER TABLE Work_Metrics 
ADD CONSTRAINT UQ_WorkMetrics_Employee UNIQUE (employee_id);

ALTER TABLE Mental_Health_Records 
ADD CONSTRAINT UQ_MentalHealth_Employee UNIQUE (employee_id);
GO