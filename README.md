# Student-Course-Registration-System-End-to-End-Data-Management-and-Analysis-Using-SQL-Server

Designed and implemented a SQL-based Student Course Registration System featuring data modeling, cleaning, GPA analysis, enrollment tracking, and prerequisite validation. Used advanced SQL techniques to ensure data integrity and generate insights through queries and views in a simulated academic environment.

**Title:**
Student Course Registration System – End-to-End Data Management and Analysis Using SQL Server

**SQL Code: **
(Student Course Registration System.SQL)[https://github.com/Osiwi/Student-Course-Registration-System-End-to-End-Data-Management-and-Analysis-Using-SQL-Server/blob/main/Student%20Course%20Registration%20System.SQL]

**SQL Skills Used:**
JOIN, LEFT JOIN, GROUP BY, HAVING, CASE, EXISTS, NOT IN
Window functions: ROW_NUMBER(), LAG()
Data cleaning: Deduplication, NULL handling, data standardization
Integrity checks: Orphan record detection, prerequisite validation
GPA & Transcript Calculation
View Creation: CREATE VIEW, DROP VIEW
Transaction Control: BEGIN TRANSACTION, ROLLBACK, COMMIT
Temporary tables: #EnrollmentsToKeep for duplicate resolution
Aggregate functions: AVG(), COUNT(), SUM(), ROUND()

**Project Description: **
This project simulates a real-world Student Course Registration System for a fictional university, developed as part of the DATAKIRK Work Experience Program. It involves:

Data Modeling & Table Relationships
Managed relational data between students, courses, instructors, enrollments, course offerings, and prerequisites.
Defined relationships with foreign keys, composite keys, and constraints.

Data Cleaning & Quality Control
Removed duplicate student and course records.
Replaced empty fields with NULLs and validated grades, student years, and credits.
Standardized department naming (e.g., capitalizing entries).
Detected and fixed orphaned references in Enrollments and Prerequisites.

Analytics & Reporting
GPA calculations by student and department.
Identification of students missing prerequisites.
Enrollment pattern analysis by department and semester.
Highlighted under-enrolled courses for administrative action.

Business Logic Implementation
Generated student transcripts and instructor schedules through SQL views.
Tracked changes in enrollment across semesters using trend analysis (LAG()).
Used CASE logic for detailed GPA calculations and performance insights.

Data Integrity Monitoring
Built detailed diagnostics to assess data quality across core tables (e.g., invalid grades, self-referencing prerequisites).
Verified consistency of enrollment records and tracked duplicate enrollments.

**Technology Used: ** 
Microsoft SQL Server Management Studio (SSMS)
T-SQL (Transact-SQL)
Temporary tables, CTEs (Common Table Expressions), and views


