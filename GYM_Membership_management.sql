--GYM Membership Management System [PLSQL]

CREATE TABLE Members (
    MemberID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    PhoneNumber VARCHAR2(15),
    Email VARCHAR2(100),
    PlanID NUMBER,
    StartDate DATE,
    EndDate DATE,
    FeesPaid CHAR(1) CHECK (FeesPaid IN ('Y', 'N')) 
);


CREATE TABLE Plans (
    PlanID NUMBER PRIMARY KEY,
    PlanName VARCHAR2(50),
    DurationInDays NUMBER,
    Price NUMBER(10, 2)
);


CREATE TABLE Payments (
    PaymentID NUMBER PRIMARY KEY,
    MemberID NUMBER,
    Amount NUMBER(10, 2),
    PaymentDate DATE,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);


CREATE TABLE Attendance (
    AttendanceID NUMBER PRIMARY KEY,
    MemberID NUMBER,
    AttendanceDate DATE,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);


CREATE OR REPLACE PROCEDURE TrackAttendance(p_MemberID NUMBER) IS
    v_AttendanceID NUMBER;
BEGIN
   
    SELECT NVL(MAX(AttendanceID), 0) + 1 INTO v_AttendanceID FROM Attendance;

    INSERT INTO Attendance (AttendanceID, MemberID, AttendanceDate)
    VALUES (v_AttendanceID, p_MemberID, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Attendance recorded for MemberID: ' || p_MemberID);
END;
/


CREATE OR REPLACE TRIGGER UpdateMembership
AFTER INSERT OR UPDATE ON Attendance
FOR EACH ROW
DECLARE
    v_DaysRemaining NUMBER;
BEGIN
    SELECT (EndDate - SYSDATE) INTO v_DaysRemaining
    FROM Members
    WHERE MemberID = :NEW.MemberID;

    IF v_DaysRemaining <= 7 THEN
        DBMS_OUTPUT.PUT_LINE('Reminder: Membership for MemberID ' || :NEW.MemberID || ' is expiring in ' || v_DaysRemaining || ' days.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE DeleteMembership(p_MemberID NUMBER) IS
BEGIN
    DELETE FROM Payments WHERE MemberID = p_MemberID;
    DELETE FROM Attendance WHERE MemberID = p_MemberID;
    DELETE FROM Members WHERE MemberID = p_MemberID;

    DBMS_OUTPUT.PUT_LINE('Membership deleted for MemberID: ' || p_MemberID);
END;
/

INSERT INTO Members (MemberID, FirstName, LastName, PhoneNumber, Email, PlanID, StartDate, EndDate, FeesPaid)
VALUES (1, 'John', 'Doe', '123-456-7890', 'john.doe@example.com', 1, SYSDATE, SYSDATE + 30, 'Y'),
       (2, 'Jane', 'Smith', '234-567-8901', 'jane.smith@example.com', 1, SYSDATE, SYSDATE + 30, 'Y'),
       (3, 'Mike', 'Johnson', '345-678-9012', 'mike.johnson@example.com', 2, SYSDATE, SYSDATE + 60, 'N'),
       (4, 'Emily', 'Davis', '456-789-0123', 'emily.davis@example.com', 1, SYSDATE, SYSDATE + 30, 'Y'),
       (5, 'Chris', 'Brown', '567-890-1234', 'chris.brown@example.com', 3, SYSDATE, SYSDATE + 90, 'N'),
       (6, 'Laura', 'Wilson', '678-901-2345', 'laura.wilson@example.com', 2, SYSDATE, SYSDATE + 60, 'Y');

INSERT INTO Plans (PlanID, PlanName, DurationInDays, Price)
VALUES (1, 'Monthly Plan', 30, 50.00);

INSERT INTO Payments (PaymentID, MemberID, Amount, PaymentDate)
VALUES (1, 1, 50.00, SYSDATE),
       (2, 2, 50.00, SYSDATE),
       (3, 3, 100.00, SYSDATE),
       (4, 4, 50.00, SYSDATE),
       (5, 5, 150.00, SYSDATE),
       (6, 6, 100.00, SYSDATE);


BEGIN
    TrackAttendance(1);
    TrackAttendance(2);
    TrackAttendance(3);
    TrackAttendance(3);
    --DeleteMembership(1);
END;
