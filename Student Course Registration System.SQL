
----DATAKIRK WORK EXPERIENCE PROGRAM
----------------------------------------------------------------------------------------------------------
---DATA CLEANING & QUALITY CONTROL

-- Remove duplicate Students by Email (keep the one with lowest StudentID)
DELETE FROM Students
WHERE StudentID NOT IN (
    SELECT MIN(StudentID)
    FROM Students
    GROUP BY Email
);

-- Replace empty strings with NULLs in Students table
UPDATE Students
SET Email = NULL
WHERE TRIM(Email) = '';

-- Enrollments with invalid StudentID
SELECT * FROM Enrollments
WHERE StudentID NOT IN (SELECT StudentID FROM Students);

-- Enrollments with invalid OfferingID
SELECT * FROM Enrollments
WHERE OfferingID NOT IN (SELECT OfferingID FROM CourseOfferings);

-- Uppercase all Department names
UPDATE Courses
SET Department = UPPER(Department);
UPDATE Instructors
SET Department = UPPER(Department);

-- Fix invalid Year values in Students
UPDATE Students
SET Year = 'Year 1'
WHERE Year NOT IN ('Year 1', 'Year 2', 'Year 3', 'Year 4');

-- Fix invalid Grades
UPDATE Enrollments
SET Grade = NULL
WHERE Grade NOT IN ('A', 'B', 'C', 'D', 'F', NULL);

-- Ensure Credits are positive
UPDATE Courses
SET Credits = 3
WHERE Credits <= 0;

-- Find students enrolled in the same course offering more than once
SELECT StudentID, OfferingID, COUNT(*)
FROM Enrollments
GROUP BY StudentID, OfferingID
HAVING COUNT(*) > 1;

--Remove duplicates
DELETE FROM Enrollments
WHERE EnrollmentID NOT IN (
    SELECT MIN(EnrollmentID)
    FROM Enrollments
    GROUP BY StudentID, OfferingID
);


-- Find courses listed as prerequisites but don't exist in Courses table
SELECT *
FROM Prerequisites
WHERE PrerequisiteID NOT IN (SELECT CourseID FROM Courses);


-- Find courses listed as prerequisites but don't exist in Courses table
SELECT *
FROM Prerequisites
WHERE PrerequisiteID NOT IN (SELECT CourseID FROM Courses);
WITH DuplicateCourses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CourseCode ORDER BY CourseID) AS rn
    FROM Courses
)
DELETE FROM DuplicateCourses
WHERE rn > 1;


----Preview Duplicates First (Before Deleting):
WITH DuplicateCourses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CourseCode ORDER BY CourseID) AS rn
    FROM Courses
)
SELECT *
FROM DuplicateCourses
WHERE rn > 1;

---Working SQL Server Script to Remove Duplicates from Courses
WITH CTE_Duplicates AS (
    SELECT CourseID,
           ROW_NUMBER() OVER (PARTITION BY CourseCode ORDER BY CourseID) AS rn
    FROM Courses
)
DELETE FROM Courses
WHERE CourseID IN (
    SELECT CourseID FROM CTE_Duplicates WHERE rn > 1
);

----Preview Duplicates Before Deleting (Safe Step):
WITH CTE_Duplicates AS (
    SELECT CourseID, CourseCode,
           ROW_NUMBER() OVER (PARTITION BY CourseCode ORDER BY CourseID) AS rn
    FROM Courses
)
SELECT * FROM Courses
WHERE CourseID IN (
    SELECT CourseID FROM CTE_Duplicates WHERE rn > 1
);

----Capitalize First Letter of First and Last Name (Simple Case)
SELECT
  UPPER(LEFT(FirstName, 1)) + LOWER(SUBSTRING(FirstName, 2, LEN(FirstName))) AS CapitalizedFirstName,
  UPPER(LEFT(LastName, 1)) + LOWER(SUBSTRING(LastName, 2, LEN(LastName))) AS CapitalizedLastName
FROM Students;

----Check if Student with ID 2000 Exists
SELECT * FROM Students WHERE StudentID = 2000;

-- List all courses with their offerings information
SELECT 
    c.CourseID,
    c.CourseCode,
    c.Title AS 'Course Title',
    c.Department,
    c.Credits,
    co.OfferingID,
    co.Semester,
    co.Schedule,
    i.FirstName + ' ' + i.LastName AS 'Instructor',
    COUNT(e.StudentID) AS 'EnrollmentCount'
FROM 
    Courses c
LEFT JOIN 
    CourseOfferings co ON c.CourseID = co.CourseID
LEFT JOIN 
    Instructors i ON co.InstructorID = i.InstructorID
LEFT JOIN 
    Enrollments e ON co.OfferingID = e.OfferingID
GROUP BY
    c.CourseID,
    c.CourseCode,
    c.Title,
    c.Department,
    c.Credits,
    co.OfferingID,
    co.Semester,
    co.Schedule,
    i.FirstName,
    i.LastName
ORDER BY 
    c.Department,
    c.CourseCode,
    co.Semester;

-- Courses a student is enrolled in for a given semester
SELECT s.FirstName, s.LastName, c.Title, co.Semester
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
WHERE s.StudentID = 1033 AND co.Semester = 'Fall 2024';

-- Student transcript with GPA
SELECT s.FirstName, s.LastName, c.Title, co.Semester, e.Grade
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
WHERE s.StudentID = 1033;

-- Courses in a Computer Science department for a semester
SELECT c.CourseCode, c.Title, co.Semester
FROM CourseOfferings co
JOIN Courses c ON co.CourseID = c.CourseID
WHERE c.Department = 'Computer Science' AND co.Semester = 'Fall 2024';

-- Courses in a Biology department for a semester
SELECT c.CourseCode, c.Title, co.Semester
FROM CourseOfferings co
JOIN Courses c ON co.CourseID = c.CourseID
WHERE c.Department = 'Biology' AND co.Semester = 'Fall 2024';

-- Courses in a Physics department for a semester
SELECT c.CourseCode, c.Title, co.Semester
FROM CourseOfferings co
JOIN Courses c ON co.CourseID = c.CourseID
WHERE c.Department = 'Physics' AND co.Semester = 'Fall 2024';

-- Instructor-wise course loads
SELECT i.FirstName, i.LastName, COUNT(*) AS TotalCourses
FROM CourseOfferings co
JOIN Instructors i ON co.InstructorID = i.InstructorID
GROUP BY i.FirstName, i.LastName;

-- Under-enrolled offerings (less than 5 students)
SELECT co.OfferingID, COUNT(e.StudentID) AS NumEnrolled
FROM Enrollments e
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
GROUP BY co.OfferingID
HAVING COUNT(e.StudentID) < 1;

---Question 1
SELECT s.FirstName, s.LastName, cf.Semester, c.Title
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
WHERE cf.Semester IN ('Spring 2025', 'Fall 2024', 'Summer 2025');

---Question 2
SELECT s.FirstName, s.LastName, cf.Semester, c.Title, e.Grade, c.Credits, (CASE
        WHEN e.Grade = 'A' THEN 5.0
        WHEN e.Grade = 'B' THEN 4.0
        WHEN e.Grade = 'C' THEN 3.0
        WHEN e.Grade = 'D' THEN 2.0
        WHEN e.Grade = 'F' THEN 1.0
        ELSE 0
     END * c.Credits) AS GPA
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID;

---Question 2Cont'd

SELECT s.StudentID, s.FirstName, s.LastName, cf.Semester, c.Title, e.Grade, c.Credits, SUM(CASE
        WHEN e.Grade = 'A' THEN 5.0
        WHEN e.Grade = 'B' THEN 4.0
        WHEN e.Grade = 'C' THEN 3.0
        WHEN e.Grade = 'D' THEN 2.0
        WHEN e.Grade = 'F' THEN 1.0
        ELSE 0
     END * c.Credits)/ SUM(c.Credits) AS GPA
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
group by s.StudentID, s.FirstName, s.LastName, cf.Semester, c.Title, e.Grade, c.Credits;

-----GPA Calculation

SELECT s.StudentID, s.FirstName, s.LastName, 
       SUM(CASE
           WHEN e.Grade = 'A' THEN 5.0
           WHEN e.Grade = 'B' THEN 4.0
           WHEN e.Grade = 'C' THEN 3.0
           WHEN e.Grade = 'D' THEN 2.0
           WHEN e.Grade = 'F' THEN 1.0
           ELSE 0 END * c.Credits) / 
       SUM(c.Credits) AS GPA
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
JOIN Courses c ON cf.CourseID = c.CourseID
GROUP BY s.StudentID, s.FirstName, s.LastName;

-----Student Missing Prerequisites

SELECT DISTINCT s.StudentID, s.FirstName, s.LastName, c.Title AS CurrentCourse, cp.Title AS MissingPrerequisite
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Prerequisites p ON c.CourseID = p.CourseID
JOIN Courses cp ON p.PrerequisiteID = cp.CourseID
WHERE NOT EXISTS (
    SELECT 1
    FROM Enrollments e2
    JOIN CourseOfferings co2 ON e2.OfferingID = co2.OfferingID
    WHERE e2.StudentID = s.StudentID
      AND co2.CourseID = p.PrerequisiteID
      AND (e2.Grade IS NULL OR e2.Grade <> 'F')
)
ORDER BY s.StudentID;

------POST MEETING CODES
SELECT 
    e.OfferingID AS CourseID,
    e.EnrollmentDate,
    e.Grade,
    s.FirstName,
    s.LastName,
    s.StudentID,
    c.CourseCode,
    cf.Semester
FROM Enrollments e
INNER JOIN Students s ON e.StudentID = s.StudentID
INNER JOIN CourseOfferings cf ON e.OfferingID = cf.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
WHERE cf.Semester = 'Spring 2025';

--- Student Services Queries
--- Retrieve all courses a student is enrolled in for a given semester.
SELECT s.FirstName, s.LastName, cf.Semester, c.Title
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
WHERE cf.Semester IN ('Spring 2025', 'Fall 2024', 'Summer 2025');

--- Display a student's transcript (course titles, semesters, grades, GPA).
SELECT s.StudentID, s.FirstName, s.LastName, cf.Semester, c.Title, e.Grade, c.Credits, SUM(CASE
        WHEN e.Grade = 'A' THEN 5.0
        WHEN e.Grade = 'B' THEN 4.0
        WHEN e.Grade = 'C' THEN 3.0
        WHEN e.Grade = 'D' THEN 2.0
        WHEN e.Grade = 'F' THEN 1.0
        ELSE 0
     END * c.Credits)/ SUM(c.Credits) AS GPA
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN CourseOfferings cf ON cf.OfferingID = e.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
group by s.StudentID, s.FirstName, s.LastName, cf.Semester, c.Title, e.Grade, c.Credits;

--- Find students who haven't completed prerequisites for a course.
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName, c.Title AS CurrentCourse, cp.Title AS MissingPrerequisite
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Prerequisites p ON c.CourseID = p.CourseID
JOIN Courses cp ON p.PrerequisiteID = cp.CourseID
WHERE NOT EXISTS (
    SELECT 1
    FROM Enrollments e2
    JOIN CourseOfferings co2 ON e2.OfferingID = co2.OfferingID
    WHERE e2.StudentID = s.StudentID
      AND co2.CourseID = p.PrerequisiteID
      AND (e2.Grade IS NULL OR e2.Grade <> 'F')
)
ORDER BY s.StudentID;

--- Find students who haven't completed prerequisites for a course.
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName, c.CourseID, c.CourseCode, c.Title AS CurrentCourse,
p.PrerequisiteID, cp.CourseCode AS PrerequisiteCode,cp.Title AS PrerequisiteTitle
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Prerequisites p ON c.CourseID = p.CourseID
JOIN Courses cp ON p.PrerequisiteID = cp.CourseID
WHERE NOT EXISTS (
    SELECT 1
    FROM Enrollments e2
    JOIN CourseOfferings co2 ON e2.OfferingID = co2.OfferingID
    WHERE e2.StudentID = s.StudentID
      AND co2.CourseID = p.PrerequisiteID
      AND (e2.Grade IS NULL OR e2.Grade IN ('A', 'B', 'C', 'D', 'E'))
)
ORDER BY s.StudentID;

--- Administrative Queries
--- List all courses offered in a department in a given semester.
select c.Title, i.Department, cf.Semester
from courseofferings cf
inner join courses c on cf. CourseID = c.CourseID
inner join instructors i on cf.InstructorID = i.InstructorID
order by Department;

--- Generate instructor-wise course loads per semester.
select c.Title, c.CourseCode, i.Department, cf.Semester
from courseofferings cf
inner join courses c on cf.CourseID = c.CourseID
inner join instructors i on cf.InstructorID = i.InstructorID
order by Department;

-- Find under-enrolled offerings (less than 5 students).
SELECT 
    e.OfferingID, 
    COUNT(DISTINCT e.StudentID) AS StudentCount, 
    c.Title
FROM Enrollments e
INNER JOIN CourseOfferings cf ON e.OfferingID = cf.OfferingID
INNER JOIN Courses c ON cf.CourseID = c.CourseID
GROUP BY e.OfferingID, c.Title
HAVING COUNT(DISTINCT e.StudentID) < 5;

--  Update and Maintain Data
-- Update a student’s major.
-- View all students ordered by first name
SELECT * 
FROM Students
ORDER BY FirstName;

-- Update the major for student with ID 22
UPDATE Students
SET Major = 'Physics'
WHERE StudentID = 22;

--- Assign grades to students post-semester.
select * from enrollments;
UPDATE Enrollments
SET Grade = 'B'
WHERE StudentID = 50
  AND OfferingID = 3;

  --- Drop a student from a course.
select * from students
order by studentID;
DELETE FROM students
WHERE StudentID = 22;

--- Create Views (Optional)
---  StudentTranscriptView: Combines student, course, and grade info with GPA.
DROP VIEW IF EXISTS StudentTranscriptView;
GO

CREATE VIEW StudentTranscriptView AS
SELECT 
    s.StudentID, 
    s.FirstName, 
    s.LastName, 
    c.CourseCode, 
    c.Title AS CourseTitle,
    cf.Semester, 
    e.Grade, 
    c.Credits,
    (
        CASE
            WHEN e.Grade = 'A' THEN 5.0
            WHEN e.Grade = 'B' THEN 4.0
            WHEN e.Grade = 'C' THEN 3.0
            WHEN e.Grade = 'D' THEN 2.0
            WHEN e.Grade = 'F' THEN 1.0
            ELSE 0
        END * c.Credits
    ) AS GradePoints
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN CourseOfferings cf ON e.OfferingID = cf.OfferingID
JOIN Courses c ON cf.CourseID = c.CourseID;


SELECT StudentID, FirstName, LastName,
    ROUND(SUM(GradePoints) / SUM(Credits), 2) AS GPA
FROM StudentTranscriptView
GROUP BY StudentID, FirstName, LastName;


SELECT StudentID, FirstName, LastName, Semester,
    ROUND(SUM(GradePoints) / SUM(Credits), 2) AS GPA
FROM StudentTranscriptView
WHERE Semester = 'Spring 2025'
GROUP BY StudentID, FirstName, LastName, Semester
ORDER BY GPA DESC;


SELECT * FROM StudentTranscriptView;

--- InstructorScheduleView: Lists courses and schedule for each instructor.
DROP VIEW IF EXISTS InstructorScheduleView;
GO

CREATE VIEW InstructorScheduleView AS
SELECT 
    i.InstructorID, 
    i.FirstName, 
    i.LastName, 
    c.CourseCode, 
    c.Title AS CourseTitle,
    co.Semester, 
    co.Schedule
FROM CourseOfferings co
JOIN Instructors i ON co.InstructorID = i.InstructorID
JOIN Courses c ON co.CourseID = c.CourseID;

SELECT * FROM InstructorScheduleView;


-- Find duplicate records in StudentTranscriptView
WITH DuplicateCheck AS (
    SELECT 
        StudentID,
        FirstName,
        LastName,
        CourseCode,
        CourseTitle,
        Semester,
        Grade,
        Credits,
        GradePoints,
        COUNT(*) AS RecordCount
    FROM StudentTranscriptView
    GROUP BY 
        StudentID,
        FirstName,
        LastName,
        CourseCode,
        CourseTitle,
        Semester,
        Grade,
        Credits,
        GradePoints
    HAVING COUNT(*) > 1
)

SELECT 
    st.*,
    dc.RecordCount
FROM StudentTranscriptView st
JOIN DuplicateCheck dc ON 
    st.StudentID = dc.StudentID AND
    st.FirstName = dc.FirstName AND
    st.LastName = dc.LastName AND
    st.CourseCode = dc.CourseCode AND
    st.CourseTitle = dc.CourseTitle AND
    st.Semester = dc.Semester AND
    ISNULL(st.Grade, '') = ISNULL(dc.Grade, '') AND
    st.Credits = dc.Credits AND
    st.GradePoints = dc.GradePoints
ORDER BY 
    st.StudentID,
    st.Semester,
    st.CourseCode;


---- Verify duplicates in Enrollments table (same student in same offering)
WITH DuplicateEnrollments AS (
    SELECT 
        StudentID,
        OfferingID,
        COUNT(*) AS RecordCount
    FROM Enrollments
    GROUP BY StudentID, OfferingID
    HAVING COUNT(*) > 1
)
SELECT * FROM DuplicateEnrollments;

---- A temporary table to preserve one copy of each duplicate
---- (keeping the earliest enrollment or the one with better grade)
WITH RankedEnrollments AS (
    SELECT 
        EnrollmentID,
        StudentID,
        OfferingID,
        EnrollmentDate,
        Grade,
        ROW_NUMBER() OVER (
            PARTITION BY StudentID, OfferingID 
            ORDER BY 
                CASE WHEN Grade IN ('A', 'B', 'C', 'D') THEN 0 ELSE 1 END, -- Prefer passing grades
                EnrollmentDate -- Then earliest enrollment
        ) AS RowRank
    FROM Enrollments
)
SELECT * 
INTO #EnrollmentsToKeep
FROM RankedEnrollments
WHERE RowRank = 1;

----Delete duplicate records (optional - verify results first)
BEGIN TRANSACTION;

----First delete the records that are duplicates
DELETE FROM Enrollments
WHERE EnrollmentID NOT IN (
    SELECT EnrollmentID FROM #EnrollmentsToKeep
);

---Verify the deletion count before committing
---ROLLBACK; -- To undo
COMMIT TRANSACTION;

---Clean up
DROP TABLE #EnrollmentsToKeep;


--------------------------------------------------------------------

------Insight From Script
-----------------------------------------------------------------
-- Script to analyze the Student Course Registration System database
-- Produces key findings about data quality, enrollment patterns, and academic performance
--------------------------------------------------
-- 1. Data Quality Analysis
--------------------------------------------------
-- Calculate percentage of enrollments with data quality issues
SELECT
    ROUND(
        (COUNT(CASE WHEN
            e.StudentID IS NULL OR
            e.OfferingID IS NULL OR
            e.Grade NOT IN ('A','B','C','D','F',NULL) OR
            s.StudentID IS NULL OR
            co.OfferingID IS NULL
        THEN 1 END) * 100.0 /
        COUNT(*)), 0) AS PercentProblemEnrollments
FROM Enrollments e
LEFT JOIN Students s ON e.StudentID = s.StudentID
LEFT JOIN CourseOfferings co ON e.OfferingID = co.OfferingID;
-- Find courses with missing prerequisite references
SELECT
    p.CourseID,
    c1.Title AS CourseTitle,
    p.PrerequisiteID,
    CASE WHEN c2.CourseID IS NULL THEN 'MISSING' ELSE 'VALID' END AS PrerequisiteStatus
FROM Prerequisites p
JOIN Courses c1 ON p.CourseID = c1.CourseID
LEFT JOIN Courses c2 ON p.PrerequisiteID = c2.CourseID
WHERE c2.CourseID IS NULL;
--------------------------------------------------
-- 2. Academic Performance Metrics
--------------------------------------------------
-- Calculate average GPA across all students
SELECT
    ROUND(AVG(
        CASE
            WHEN e.Grade = 'A' THEN 4.0
            WHEN e.Grade = 'B' THEN 3.0
            WHEN e.Grade = 'C' THEN 2.0
            WHEN e.Grade = 'D' THEN 1.0
            WHEN e.Grade = 'F' THEN 0.0
            ELSE NULL
        END), 2) AS AverageGPA
FROM Enrollments e
WHERE e.Grade IS NOT NULL;

-- GPA distribution by department
SELECT
    c.Department,
    ROUND(AVG(
        CASE
            WHEN e.Grade = 'A' THEN 4.0
            WHEN e.Grade = 'B' THEN 3.0
            WHEN e.Grade = 'C' THEN 2.0
            WHEN e.Grade = 'D' THEN 1.0
            WHEN e.Grade = 'F' THEN 0.0
            ELSE NULL
        END), 2) AS DepartmentGPA,
    COUNT(*) AS EnrollmentCount
FROM Enrollments e
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
WHERE e.Grade IS NOT NULL
GROUP BY c.Department
ORDER BY DepartmentGPA DESC;

--------------------------------------------------
-- 3. Enrollment Patterns Analysis
--------------------------------------------------
-- Enrollment by department (identify highest enrollment)
SELECT
    c.Department,
    COUNT(*) AS TotalEnrollments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Enrollments), 1) AS PercentOfTotal
FROM Enrollments e
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
GROUP BY c.Department
ORDER BY TotalEnrollments DESC;
-- Semester comparison (identify summer enrollment dip)
WITH SemesterEnrollments AS (
    SELECT
        co.Semester,
        SUBSTRING(co.Semester, LEN(co.Semester)-3, 4) AS Year,
        CASE
            WHEN co.Semester LIKE 'Fall%' THEN 1
            WHEN co.Semester LIKE 'Spring%' THEN 2
            ELSE 3
        END AS SeasonOrder,
        COUNT(*) AS TotalEnrollments
    FROM Enrollments e
    JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
    GROUP BY co.Semester
)
SELECT
    Semester,
    TotalEnrollments,
    ROUND(
        (TotalEnrollments - LAG(TotalEnrollments) OVER (ORDER BY Year, SeasonOrder)) * 100.0 /
        LAG(TotalEnrollments) OVER (ORDER BY Year, SeasonOrder),
    1) AS PercentChange
FROM SemesterEnrollments
ORDER BY Year, SeasonOrder;
--------------------------------------------------
-- 4. Detailed Data Quality Report
--------------------------------------------------
-- Comprehensive data quality check
-- Students table analysis
SELECT
    'Students' AS TableName,
    COUNT(*) AS TotalRecords,
    SUM(CASE WHEN Email IS NULL OR Email = '' THEN 1 ELSE 0 END) AS MissingEmails,
    SUM(CASE WHEN Year NOT IN ('Year 1','Year 2','Year 3','Year 4') THEN 1 ELSE 0 END) AS InvalidYearValues
FROM Students;
-- Enrollments table analysis (using LEFT JOIN instead of subquery)
SELECT
    'Enrollments' AS TableName,
    COUNT(*) AS TotalRecords,
    SUM(CASE
            WHEN Grade NOT IN ('A','B','C','D','F') OR Grade IS NULL THEN 1
            ELSE 0
        END) AS InvalidGrades,
    SUM(CASE
            WHEN s.StudentID IS NULL THEN 1
            ELSE 0
        END) AS OrphanedStudentReferences
FROM Enrollments e
LEFT JOIN Students s ON e.StudentID = s.StudentID;
-- Prerequisites table analysis (using LEFT JOIN instead of subquery)
SELECT
    'Prerequisites' AS TableName,
    COUNT(*) AS TotalRecords,
    SUM(CASE
            WHEN c.CourseID IS NULL THEN 1
            ELSE 0
        END) AS InvalidPrerequisiteReferences,
    SUM(CASE
            WHEN p.CourseID = p.PrerequisiteID THEN 1
            ELSE 0
        END) AS SelfReferencingPrerequisites
FROM Prerequisites p
LEFT JOIN Courses c ON p.PrerequisiteID = c.CourseID;
