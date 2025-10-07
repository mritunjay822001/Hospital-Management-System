-- HOSPITAL MANAGEMENT SYSTEM PROJECT
-- Author: MRITUNJAY KUMAR
-- Database: Oracle SQL

-- STEP 1: Create Tables
CREATE TABLE Department (
  Dept_ID NUMBER PRIMARY KEY,
  Dept_Name VARCHAR2(50) NOT NULL
);

CREATE TABLE Doctor (
  Doc_ID NUMBER PRIMARY KEY,
  Doc_Name VARCHAR2(50) NOT NULL,
  Dept_ID NUMBER REFERENCES Department(Dept_ID),
  Experience NUMBER,
  Fees NUMBER
);

CREATE TABLE Patient (
  Pat_ID NUMBER PRIMARY KEY,
  Pat_Name VARCHAR2(50) NOT NULL,
  Gender CHAR(1),
  Age NUMBER,
  Address VARCHAR2(100)
);

CREATE TABLE Appointment (
  App_ID NUMBER PRIMARY KEY,
  Pat_ID NUMBER REFERENCES Patient(Pat_ID),
  Doc_ID NUMBER REFERENCES Doctor(Doc_ID),
  App_Date DATE,
  Diagnosis VARCHAR2(100)
);

CREATE TABLE Billing (
  Bill_ID NUMBER PRIMARY KEY,
  Pat_ID NUMBER REFERENCES Patient(Pat_ID),
  Total_Amount NUMBER(10,2),
  Pay_Date DATE
);

-- STEP 2: Insert Sample Data
INSERT INTO Department VALUES (1, 'Cardiology');
INSERT INTO Department VALUES (2, 'Neurology');
INSERT INTO Department VALUES (3, 'Orthopedics');
INSERT INTO Department VALUES (4, 'Pediatrics');

INSERT INTO Doctor VALUES (101, 'Dr. Meena Sharma', 1, 10, 800);
INSERT INTO Doctor VALUES (102, 'Dr. Rajesh Patel', 2, 7, 700);
INSERT INTO Doctor VALUES (103, 'Dr. Kavita Rao', 3, 12, 900);
INSERT INTO Doctor VALUES (104, 'Dr. Aman Verma', 4, 5, 600);

INSERT INTO Patient VALUES (201, 'Rohit Kumar', 'M', 30, 'Delhi');
INSERT INTO Patient VALUES (202, 'Priya Singh', 'F', 25, 'Mumbai');
INSERT INTO Patient VALUES (203, 'Amit Joshi', 'M', 40, 'Pune');
INSERT INTO Patient VALUES (204, 'Neha Gupta', 'F', 35, 'Chennai');

INSERT INTO Appointment VALUES (301, 201, 101, TO_DATE('2025-09-28', 'YYYY-MM-DD'), 'High BP');
INSERT INTO Appointment VALUES (302, 202, 104, TO_DATE('2025-10-01', 'YYYY-MM-DD'), 'Flu & Fever');
INSERT INTO Appointment VALUES (303, 203, 103, TO_DATE('2025-10-03', 'YYYY-MM-DD'), 'Knee Pain');
INSERT INTO Appointment VALUES (304, 204, 102, TO_DATE('2025-10-05', 'YYYY-MM-DD'), 'Migraine');

INSERT INTO Billing VALUES (401, 201, 1200, TO_DATE('2025-09-28', 'YYYY-MM-DD'));
INSERT INTO Billing VALUES (402, 202, 600, TO_DATE('2025-10-01', 'YYYY-MM-DD'));
INSERT INTO Billing VALUES (403, 203, 900, TO_DATE('2025-10-03', 'YYYY-MM-DD'));
INSERT INTO Billing VALUES (404, 204, 700, TO_DATE('2025-10-05', 'YYYY-MM-DD'));

-- STEP 3: Useful Queries
SELECT p.Pat_Name, d.Doc_Name, dept.Dept_Name
FROM Patient p
JOIN Appointment a ON p.Pat_ID = a.Pat_ID
JOIN Doctor d ON a.Doc_ID = d.Doc_ID
JOIN Department dept ON d.Dept_ID = dept.Dept_ID;

SELECT p.Pat_Name, SUM(b.Total_Amount) AS Total_Bill
FROM Patient p
JOIN Billing b ON p.Pat_ID = b.Pat_ID
GROUP BY p.Pat_Name;

SELECT Doc_Name, Experience, Fees
FROM Doctor
WHERE Experience > 8;

SELECT dept.Dept_Name, COUNT(a.App_ID) AS Total_Appointments
FROM Appointment a
JOIN Doctor d ON a.Doc_ID = d.Doc_ID
JOIN Department dept ON d.Dept_ID = dept.Dept_ID
GROUP BY dept.Dept_Name;

SELECT p.Pat_Name, a.Diagnosis, b.Total_Amount
FROM Patient p
JOIN Appointment a ON p.Pat_ID = a.Pat_ID
JOIN Billing b ON p.Pat_ID = b.Pat_ID;

-- STEP 4: Trigger
CREATE OR REPLACE TRIGGER trg_auto_billing
AFTER INSERT ON Appointment
FOR EACH ROW
BEGIN
  INSERT INTO Billing (Bill_ID, Pat_ID, Total_Amount, Pay_Date)
  VALUES (
    (SELECT NVL(MAX(Bill_ID),400) + 1 FROM Billing),
    :NEW.Pat_ID,
    500,
    SYSDATE
  );
END;
/