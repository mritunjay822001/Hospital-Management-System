
-- Hospital Management System (Oracle SQL)
-- Full DDL (tables, sequences, triggers), sample data, and some helper procedures.
-- Run the entire file in Oracle SQL Developer (enable DBMS_OUTPUT).

-- ========== DROP (safe in dev) ==========
BEGIN
  FOR r IN (SELECT object_name, object_type FROM user_objects
            WHERE object_type IN ('TABLE','SEQUENCE','TRIGGER','PROCEDURE','FUNCTION','VIEW')
              AND object_name IN (
                'VW_PATIENT_SUMMARY','BILL_LINE','BILL','PRESCRIPTION_LINE','PRESCRIPTION','MEDICATION',
                'TREATMENT','ADMISSION','APPOINTMENT','ROOM','DEPARTMENT','DOCTOR','PATIENT','STAFF',
                'SEQ_PATIENT','SEQ_DOCTOR','SEQ_APPT','SEQ_ADM','SEQ_ROOM','SEQ_TREAT','SEQ_MED',
                'SEQ_PRESC','SEQ_BILL','SEQ_LINE','SEQ_STAFF',
                'TRG_PATIENT','TRG_DOCTOR','TRG_APPT','TRG_ADM','TRG_ROOM','TRG_TREAT','TRG_MED','TRG_PRESC','TRG_BILL','TRG_LINE','TRG_STAFF',
                'ADMIT_PATIENT','DISCHARGE_PATIENT'
              ))
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP ' || r.object_type || ' "' || r.object_name || '"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END;
/
COMMIT;

-- ========== TABLES ==========
CREATE TABLE department (
  dept_id    NUMBER PRIMARY KEY,
  name       VARCHAR2(100) NOT NULL,
  location   VARCHAR2(100)
);

CREATE TABLE doctor (
  doctor_id  NUMBER PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name  VARCHAR2(50),
  dept_id    NUMBER NOT NULL,
  phone      VARCHAR2(20),
  email      VARCHAR2(100),
  specialization VARCHAR2(100),
  CONSTRAINT fk_doc_dept FOREIGN KEY(dept_id) REFERENCES department(dept_id)
);

CREATE TABLE patient (
  patient_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name  VARCHAR2(50),
  dob        DATE,
  gender     VARCHAR2(10),
  phone      VARCHAR2(20),
  email      VARCHAR2(100),
  address    VARCHAR2(4000),
  created_on TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE room (
  room_id    NUMBER PRIMARY KEY,
  room_no    VARCHAR2(20) UNIQUE,
  room_type  VARCHAR2(30),
  charge_per_day NUMBER(10,2),
  is_available CHAR(1) DEFAULT 'Y' CHECK (is_available IN ('Y','N'))
);

CREATE TABLE appointment (
  appt_id    NUMBER PRIMARY KEY,
  patient_id NUMBER NOT NULL,
  doctor_id  NUMBER NOT NULL,
  appt_dt    TIMESTAMP NOT NULL,
  reason     VARCHAR2(4000),
  status     VARCHAR2(20) DEFAULT 'SCHEDULED',
  created_on TIMESTAMP DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_appt_patient FOREIGN KEY(patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_appt_doctor FOREIGN KEY(doctor_id) REFERENCES doctor(doctor_id)
);

CREATE TABLE admission (
  adm_id     NUMBER PRIMARY KEY,
  patient_id NUMBER NOT NULL,
  room_id    NUMBER NOT NULL,
  admit_dt   TIMESTAMP DEFAULT SYSTIMESTAMP,
  discharge_dt TIMESTAMP,
  admitted_by NUMBER,
  status     VARCHAR2(20) DEFAULT 'ADMITTED',
  remarks    VARCHAR2(4000),
  CONSTRAINT fk_adm_patient FOREIGN KEY(patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_adm_room FOREIGN KEY(room_id) REFERENCES room(room_id)
);

CREATE TABLE treatment (
  treatment_id NUMBER PRIMARY KEY,
  adm_id       NUMBER NOT NULL,
  doctor_id    NUMBER,
  treat_dt     TIMESTAMP DEFAULT SYSTIMESTAMP,
  description  VARCHAR2(4000),
  cost         NUMBER(10,2) DEFAULT 0,
  CONSTRAINT fk_treat_adm FOREIGN KEY(adm_id) REFERENCES admission(adm_id),
  CONSTRAINT fk_treat_doc FOREIGN KEY(doctor_id) REFERENCES doctor(doctor_id)
);

CREATE TABLE medication (
  med_id     NUMBER PRIMARY KEY,
  name       VARCHAR2(200) NOT NULL,
  unit_cost  NUMBER(10,2) DEFAULT 0
);

CREATE TABLE prescription (
  presc_id   NUMBER PRIMARY KEY,
  adm_id     NUMBER,
  patient_id NUMBER NOT NULL,
  doctor_id  NUMBER,
  presc_dt   TIMESTAMP DEFAULT SYSTIMESTAMP,
  notes      VARCHAR2(4000),
  CONSTRAINT fk_presc_adm FOREIGN KEY(adm_id) REFERENCES admission(adm_id),
  CONSTRAINT fk_presc_patient FOREIGN KEY(patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_presc_doc FOREIGN KEY(doctor_id) REFERENCES doctor(doctor_id)
);

CREATE TABLE prescription_line (
  presc_line_id NUMBER PRIMARY KEY,
  presc_id      NUMBER NOT NULL,
  med_id        NUMBER NOT NULL,
  dosage        VARCHAR2(100),
  quantity      NUMBER,
  CONSTRAINT fk_pl_presc FOREIGN KEY(presc_id) REFERENCES prescription(presc_id),
  CONSTRAINT fk_pl_med FOREIGN KEY(med_id) REFERENCES medication(med_id)
);

CREATE TABLE bill (
  bill_id     NUMBER PRIMARY KEY,
  patient_id  NUMBER NOT NULL,
  adm_id      NUMBER,
  bill_dt     TIMESTAMP DEFAULT SYSTIMESTAMP,
  total_amt   NUMBER(12,2) DEFAULT 0,
  paid_amt    NUMBER(12,2) DEFAULT 0,
  status      VARCHAR2(20) DEFAULT 'UNPAID',
  CONSTRAINT fk_bill_patient FOREIGN KEY(patient_id) REFERENCES patient(patient_id),
  CONSTRAINT fk_bill_adm FOREIGN KEY(adm_id) REFERENCES admission(adm_id)
);

CREATE TABLE bill_line (
  bill_line_id NUMBER PRIMARY KEY,
  bill_id      NUMBER NOT NULL,
  description  VARCHAR2(4000),
  amount       NUMBER(12,2) DEFAULT 0,
  CONSTRAINT fk_bl_bill FOREIGN KEY(bill_id) REFERENCES bill(bill_id)
);

CREATE TABLE staff (
  staff_id NUMBER PRIMARY KEY,
  name     VARCHAR2(100),
  role     VARCHAR2(50),
  phone    VARCHAR2(20),
  email    VARCHAR2(100)
);

-- ========== SEQUENCES ==========
CREATE SEQUENCE seq_patient START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_doctor  START WITH 201 INCREMENT BY 1;
CREATE SEQUENCE seq_appt    START WITH 5001 INCREMENT BY 1;
CREATE SEQUENCE seq_adm     START WITH 3001 INCREMENT BY 1;
CREATE SEQUENCE seq_room    START WITH 401 INCREMENT BY 1;
CREATE SEQUENCE seq_treat   START WITH 7001 INCREMENT BY 1;
CREATE SEQUENCE seq_med     START WITH 801 INCREMENT BY 1;
CREATE SEQUENCE seq_presc   START WITH 9001 INCREMENT BY 1;
CREATE SEQUENCE seq_bill    START WITH 11001 INCREMENT BY 1;
CREATE SEQUENCE seq_line    START WITH 15001 INCREMENT BY 1;
CREATE SEQUENCE seq_staff   START WITH 501 INCREMENT BY 1;

-- ========== TRIGGERS ==========
CREATE OR REPLACE TRIGGER trg_patient
BEFORE INSERT ON patient
FOR EACH ROW
WHEN (NEW.patient_id IS NULL)
BEGIN
  SELECT seq_patient.NEXTVAL INTO :NEW.patient_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_doctor
BEFORE INSERT ON doctor
FOR EACH ROW
WHEN (NEW.doctor_id IS NULL)
BEGIN
  SELECT seq_doctor.NEXTVAL INTO :NEW.doctor_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_appt
BEFORE INSERT ON appointment
FOR EACH ROW
WHEN (NEW.appt_id IS NULL)
BEGIN
  SELECT seq_appt.NEXTVAL INTO :NEW.appt_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_adm
BEFORE INSERT ON admission
FOR EACH ROW
WHEN (NEW.adm_id IS NULL)
BEGIN
  SELECT seq_adm.NEXTVAL INTO :NEW.adm_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_room
BEFORE INSERT ON room
FOR EACH ROW
WHEN (NEW.room_id IS NULL)
BEGIN
  SELECT seq_room.NEXTVAL INTO :NEW.room_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_treat
BEFORE INSERT ON treatment
FOR EACH ROW
WHEN (NEW.treatment_id IS NULL)
BEGIN
  SELECT seq_treat.NEXTVAL INTO :NEW.treatment_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_med
BEFORE INSERT ON medication
FOR EACH ROW
WHEN (NEW.med_id IS NULL)
BEGIN
  SELECT seq_med.NEXTVAL INTO :NEW.med_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_presc
BEFORE INSERT ON prescription
FOR EACH ROW
WHEN (NEW.presc_id IS NULL)
BEGIN
  SELECT seq_presc.NEXTVAL INTO :NEW.presc_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_bill
BEFORE INSERT ON bill
FOR EACH ROW
WHEN (NEW.bill_id IS NULL)
BEGIN
  SELECT seq_bill.NEXTVAL INTO :NEW.bill_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_line
BEFORE INSERT ON bill_line
FOR EACH ROW
WHEN (NEW.bill_line_id IS NULL)
BEGIN
  SELECT seq_line.NEXTVAL INTO :NEW.bill_line_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_staff
BEFORE INSERT ON staff
FOR EACH ROW
WHEN (NEW.staff_id IS NULL)
BEGIN
  SELECT seq_staff.NEXTVAL INTO :NEW.staff_id FROM dual;
END;
/

-- ========== SAMPLE DATA ==========
-- departments
INSERT INTO department(dept_id, name, location) VALUES (1,'General Medicine','Building A');
INSERT INTO department(dept_id, name, location) VALUES (2,'Cardiology','Building B');
INSERT INTO department(dept_id, name, location) VALUES (3,'Orthopedics','Building C');
INSERT INTO department(dept_id, name, location) VALUES (4,'Pediatrics','Building D');

-- doctors
INSERT INTO doctor(doctor_id, first_name, last_name, dept_id, phone, specialization)
VALUES (NULL,'Amit','Sharma',1,'+91-9876500001','General Physician');
INSERT INTO doctor(doctor_id, first_name, last_name, dept_id, phone, specialization)
VALUES (NULL,'Rhea','Kapur',2,'+91-9876500002','Cardiologist');
INSERT INTO doctor(doctor_id, first_name, last_name, dept_id, phone, specialization)
VALUES (NULL,'Sameer','Patel',3,'+91-9876500003','Orthopedic Surgeon');
INSERT INTO doctor(doctor_id, first_name, last_name, dept_id, phone, specialization)
VALUES (NULL,'Neha','Mehra',4,'+91-9876500004','Pediatrician');

-- rooms
INSERT INTO room(room_id, room_no, room_type, charge_per_day, is_available)
VALUES (NULL,'G-101','General',1500,'Y');
INSERT INTO room(room_id, room_no, room_type, charge_per_day, is_available)
VALUES (NULL,'G-102','General',1500,'Y');
INSERT INTO room(room_id, room_no, room_type, charge_per_day, is_available)
VALUES (NULL,'P-201','Private',5000,'Y');
INSERT INTO room(room_id, room_no, room_type, charge_per_day, is_available)
VALUES (NULL,'ICU-1','ICU',10000,'Y');

-- patients (10 sample)
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Vikram','Kashyap',TO_DATE('1998-05-12','YYYY-MM-DD'),'Male','+91-9999000001','Near Mall, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Sonia','Verma',TO_DATE('1975-11-02','YYYY-MM-DD'),'Female','+91-9999000002','Lake Road, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Rajan','Singh',TO_DATE('1985-07-23','YYYY-MM-DD'),'Male','+91-9999000003','North Street, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Anita','Kaur',TO_DATE('1992-03-15','YYYY-MM-DD'),'Female','+91-9999000004','South End, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Manish','Gupta',TO_DATE('2000-12-01','YYYY-MM-DD'),'Male','+91-9999000005','River Side, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Pooja','Shah',TO_DATE('1996-09-09','YYYY-MM-DD'),'Female','+91-9999000006','Hill View, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Harish','Bedi',TO_DATE('1970-01-20','YYYY-MM-DD'),'Male','+91-9999000007','Market Area, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Kavya','Rao',TO_DATE('2010-06-30','YYYY-MM-DD'),'Female','+91-9999000008','Green Park, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Tarun','Malhotra',TO_DATE('1988-08-18','YYYY-MM-DD'),'Male','+91-9999000009','Sector 5, City');
INSERT INTO patient(first_name,last_name,dob,gender,phone,address) VALUES ('Rekha','Bhardwaj',TO_DATE('1965-04-04','YYYY-MM-DD'),'Female','+91-9999000010','Old Town, City');

-- medications
INSERT INTO medication(name, unit_cost) VALUES ('Paracetamol 500mg', 2.5);
INSERT INTO medication(name, unit_cost) VALUES ('Atorvastatin 10mg', 12.0);
INSERT INTO medication(name, unit_cost) VALUES ('Amoxicillin 500mg', 8.0);

-- appointments (some scheduled)
INSERT INTO appointment(patient_id,doctor_id,appt_dt,reason) VALUES (1001,201,SYSTIMESTAMP + INTERVAL '1' DAY,'Fever and cough');
INSERT INTO appointment(patient_id,doctor_id,appt_dt,reason) VALUES (1002,202,SYSTIMESTAMP + INTERVAL '2' DAY,'Chest pain');
INSERT INTO appointment(patient_id,doctor_id,appt_dt,reason) VALUES (1003,203,SYSTIMESTAMP + INTERVAL '3' DAY,'Knee pain');
INSERT INTO appointment(patient_id,doctor_id,appt_dt,reason) VALUES (1008,204,SYSTIMESTAMP + INTERVAL '1' DAY,'Child vaccination');

-- a sample admission and treatment
INSERT INTO admission(patient_id, room_id, admit_dt, status, remarks) VALUES (1002,402,SYSTIMESTAMP - INTERVAL '2' DAY,'ADMITTED','Routine observation');
INSERT INTO treatment(adm_id, doctor_id, description, cost) VALUES (3001,201,'Initial observation and tests',2500);
INSERT INTO treatment(adm_id, doctor_id, description, cost) VALUES (3001,202,'Cardiac monitoring',5000);

COMMIT;

-- ========== VIEW & INDEX ==========
CREATE OR REPLACE VIEW vw_patient_summary AS
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name, p.phone, p.email,
       (SELECT COUNT(*) FROM appointment a WHERE a.patient_id = p.patient_id) num_appointments,
       (SELECT COUNT(*) FROM admission ad WHERE ad.patient_id = p.patient_id) num_admissions
FROM patient p;

CREATE INDEX idx_appt_dt ON appointment(appt_dt);

-- ========== PROCEDURES ==========
CREATE OR REPLACE PROCEDURE admit_patient(
  p_patient_id IN NUMBER,
  p_room_id    IN NUMBER,
  p_admitted_by IN NUMBER,
  p_remarks IN VARCHAR2
) AS
  v_adm_id NUMBER;
BEGIN
  INSERT INTO admission(adm_id, patient_id, room_id, admit_dt, admitted_by, status, remarks)
  VALUES (NULL, p_patient_id, p_room_id, SYSTIMESTAMP, p_admitted_by, 'ADMITTED', p_remarks)
  RETURNING adm_id INTO v_adm_id;

  UPDATE room SET is_available = 'N' WHERE room_id = p_room_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Patient admitted, admission id: ' || v_adm_id);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/

CREATE OR REPLACE PROCEDURE discharge_patient(
  p_adm_id IN NUMBER
) AS
  v_room_id NUMBER;
  v_patient_id NUMBER;
  v_days NUMBER;
  v_room_charge NUMBER(12,2);
  v_total NUMBER(12,2);
  CURSOR c_treat IS SELECT cost FROM treatment WHERE adm_id = p_adm_id;
BEGIN
  SELECT room_id, patient_id INTO v_room_id, v_patient_id FROM admission WHERE adm_id = p_adm_id;

  UPDATE admission SET discharge_dt = SYSTIMESTAMP, status = 'DISCHARGED' WHERE adm_id = p_adm_id;

  UPDATE room SET is_available = 'Y' WHERE room_id = v_room_id;

  SELECT NVL(CEIL(((NVL(discharge_dt, SYSTIMESTAMP) - admit_dt) * 24)/24),1)
    INTO v_days
    FROM admission WHERE adm_id = p_adm_id;

  SELECT charge_per_day INTO v_room_charge FROM room WHERE room_id = v_room_id;

  v_total := v_days * v_room_charge;

  FOR r IN c_treat LOOP
    v_total := v_total + NVL(r.cost,0);
  END LOOP;

  INSERT INTO bill(bill_id, patient_id, adm_id, bill_dt, total_amt, paid_amt, status)
  VALUES (NULL, v_patient_id, p_adm_id, SYSTIMESTAMP, v_total, 0, 'UNPAID');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Patient discharged. Bill generated. Total = ' || TO_CHAR(v_total));
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,'Admission not found: ' || p_adm_id);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
