##task 1
#for this task first i add the new column to the Member table with this statement
ALTER TABLE Member ADD FineFee DECIMAL(10,2)  DEFAULT 0;

#then i deciced to create a new table to store overdue fine fees, member ids so i can track the number of suspensions
#later using this table
CREATE TABLE SuspensionRecord (
    SuspensionID INT AUTO_INCREMENT,
    MemberID INT NOT NULL,
    FineFee DECIMAL(10,2) NOT NULL DEFAULT 0,
    SuspensionStartDate DATE NOT NULL,
    PRIMARY KEY (SuspensionID, MemberID),
    CONSTRAINT member_fk FOREIGN KEY (MemberID) REFERENCES Member (MemberID) ON DELETE RESTRICT
);

#then i use an update query inside the procedure that i created to calculate the finefees for each overdue item and 
#insert the suspension records into the SuspensionRecord table then i update the Member table based on the borrowedby rows
#if the member has not returned item before 3 weeks after borrowing it there will be a suspension record created for them 
#if a member has been fined for more than $30 their memberStatus will be changed to suspended, members will be fined $2/day
#if they havent still returned the book after the return due date. keep in mind it will only update the memberships that are
#not expired and expired memberships wont be modified, so i have inserted new data to the borrowedby and Member tables so 
#i can test the functionality of the procedure on the non-expired memberships however, the procedure will still insert the
#suspension records for all the memberships even if they are expired to the SuspensionRecord table. this way we can still
#keep track of all the fines, suspensions and the dates that suspensions started for later use in case the member renew
#their membership in the future.
DELIMITER //
DROP PROCEDURE IF EXISTS CalculateFineAndSuspend//
CREATE PROCEDURE CalculateFineAndSuspend()
BEGIN
#calculate fines for each overdue book and insert into the SuspensionRecord table
INSERT INTO SuspensionRecord (MemberID, FineFee, SuspensionStartDate)
SELECT 
    b.MemberID,
    CASE 
        WHEN b.DateReturned IS NULL AND b.ReturnDueDate IS NULL AND DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) > 0 THEN DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) * 2
        WHEN b.DateReturned IS NULL AND b.ReturnDueDate IS NOT NULL AND b.ReturnDueDate < CURDATE() THEN DATEDIFF(CURDATE(), b.ReturnDueDate) * 2
        WHEN b.DateReturned IS NOT NULL AND b.ReturnDueDate < b.DateReturned THEN DATEDIFF(b.DateReturned, b.ReturnDueDate) * 2 
        ELSE 0 
    END AS FineFee,
    DATE_ADD(b.ReturnDueDate, INTERVAL 1 DAY) AS SuspensionStartDate
FROM Borrowedby b
WHERE 
    (b.DateReturned IS NULL AND 
        (
            (b.ReturnDueDate IS NULL AND DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) > 0) 
            OR 
            (b.ReturnDueDate IS NOT NULL AND b.ReturnDueDate < CURDATE())
        ) 
    )
    OR 
    (b.DateReturned IS NOT NULL AND b.ReturnDueDate < b.DateReturned); 
#update the Member table's FineFee column with the accumulated fines
UPDATE Member m
LEFT JOIN 
(
 SELECT 
        b.MemberID, 
        SUM(
            CASE 
            WHEN b.DateReturned IS NULL AND b.ReturnDueDate IS NULL AND DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) > 0 
            THEN DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) * 2
        WHEN b.DateReturned IS NULL AND b.ReturnDueDate IS NOT NULL AND b.ReturnDueDate < CURDATE() THEN DATEDIFF(CURDATE(), b.ReturnDueDate) * 2
        WHEN b.DateReturned IS NOT NULL AND b.ReturnDueDate < b.DateReturned THEN DATEDIFF(b.DateReturned, b.ReturnDueDate) * 2 
        ELSE 0 
            END
        ) AS TotalFineFee
    FROM Borrowedby b
    GROUP BY b.MemberID
) AS FineTotals ON m.MemberID = FineTotals.MemberID AND m.MemberExpDate > curdate()
SET 
    m.FineFee = FineTotals.TotalFineFee,
    m.MemberStatus = CASE 
    WHEN FineTotals.TotalFineFee >= 30 AND m.MemberExpDate > curdate() THEN 'SUSPENDED' ELSE m.MemberStatus END
    WHERE m.MemberExpDate > curdate();
END //
DELIMITER ;

#now i call the procedure so the member table will be updated
CALL CalculateFineAndSuspend();
#now i check if the changes are applied to the Member table
SELECT * FROM Member;

#task2:
#for this taks i decide to use a before update trigger to change the member status to regular before updating the
#member table because the program would end up in an infinite loop if i used after update trigger, the exceptions are
#being handled with error handler. the trigger only works on the memberships that are not expired yet and if the user
#tries to pay the finefee for their membership that is expired they see an error message. there is also another error 
#handler with a custom message that will be raised if the member tries to pay more than their total FineFee.
DELIMITER //
DROP TRIGGER IF EXISTS MemberStatusAlternation //
CREATE TRIGGER MemberStatusAlternation BEFORE UPDATE ON Member
FOR EACH ROW
BEGIN
    DECLARE msg VARCHAR(255);
#if the membership is expired, raise an error
    IF NEW.MemberExpDate < CURDATE() THEN
        SET msg = 'Membership has expired.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
        #if the new finefee is negative, raise an error
	ELSEIF NEW.FineFee < 0 THEN
        SET msg = 'You cannot pay more than your total finefees';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
#if FineFee is 0 and there are no overdue items, set MemberStatus to REGULAR
	ELSEIF NEW.FineFee = 0 THEN
        SET NEW.MemberStatus = 'REGULAR';
    END IF;
END //
DELIMITER ;

#Task3:
#in this task i decided to use the suspensionRecord table that i created earlier, first i needed to declare a cursor in 
#this procedure the cursor is declared to fetch distinct MemberIDs of members who have borrowed items that are overdue
#and their membership hasnt expired and i have continue handler for when my cursor traversed through all the rows to set
#the conditions for stoping the loop i also have an error handler with a custom message for when there is no member with
#overdue items.
DELIMITER //
DROP PROCEDURE IF EXISTS TerminateRepeatOffenders //
CREATE PROCEDURE TerminateRepeatOffenders()
BEGIN
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_MemberID INT;
    DECLARE Msg VARCHAR(255);
#declare a cursor for members with overdue items whose membership hasn't expired
    DECLARE cur CURSOR FOR 
    SELECT DISTINCT b.MemberID
    FROM Borrowedby b
    JOIN Member m ON b.MemberID = m.MemberID
    WHERE m.MemberExpDate > CURDATE() # Check for non-expired membership
    AND b.DateReturned IS NULL 
    AND (b.ReturnDueDate < CURDATE() OR (b.ReturnDueDate IS NULL AND DATEDIFF(CURDATE(), DATE_ADD(b.DateBorrowed, INTERVAL 21 DAY)) > 0));
    #declare a not found handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    #declare a table to store the Member IDs, Names, and Statuses of repeat offenders
    CREATE TEMPORARY TABLE IF NOT EXISTS RepeatOffendersList (
        MemberID INT,
        Name VARCHAR(255),
        MemberStatus VARCHAR(50)
    );
    #clear the table in case it has old data
    DELETE FROM RepeatOffendersList;
    #open the cursor
    OPEN cur;
    # Use repeat until loop for processing the cursor
    REPEAT
        FETCH cur INTO v_MemberID;
        IF NOT v_finished THEN
            #insert qualifying members into the RepeatOffendersList table before updating their status
            INSERT INTO RepeatOffendersList (MemberID, Name, MemberStatus)
            SELECT m.MemberID, m.MemberName, 'TERMINATE'
            FROM Member m
            JOIN (
                SELECT sr.MemberID
                FROM SuspensionRecord sr
                WHERE sr.MemberID = v_MemberID AND DATE_SUB(CURDATE(), INTERVAL 3 YEAR) <= sr.SuspensionStartDate 
                GROUP BY sr.MemberID
                HAVING COUNT(sr.MemberID) >= 2
            ) AS Temp ON m.MemberID = Temp.MemberID
            WHERE m.MemberExpDate > CURDATE() AND FineFee > 0;
            #process each MemberID
            UPDATE Member m
            SET m.MemberStatus = 'TERMINATE'
            WHERE m.MemberID = v_MemberID AND m.MemberExpDate > CURDATE();
        END IF;
    UNTIL v_finished END REPEAT;
    #close the cursor
    CLOSE cur;
    #if no members are found, raise an error
    IF v_MemberID IS NULL THEN
        SET Msg = "No members currently have overdue items.";
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Msg;
    ELSE
        #select the repeat offenders' details
        SELECT MemberID, Name, MemberStatus FROM RepeatOffendersList;
    END IF;
END //
DELIMITER ;


##task4 test plans##:
##########################################################################################################################
#task2 test plan:
#i will use this stored procedure to test the functionality of my trigger, it will deduct the input deductAmount
#from the member finefee and SET the member new fine fees to the calculated result.
DELIMITER //
DROP PROCEDURE IF EXISTS PayFineFees //
CREATE PROCEDURE PayFineFees(IN deductAmount DECIMAL(10,2), IN inputMemberID INT)
BEGIN
    DECLARE newFineFee DECIMAL(10,2);
    DECLARE curFineFee DECIMAL(10,2);
    DECLARE msg VARCHAR(255);
    SELECT FineFee - deductAmount INTO newFineFee FROM Member WHERE MemberID = inputMemberID;
#deduct the amount from FineFee for the respective member in Member table
        UPDATE Member
        SET FineFee = newFineFee
        WHERE MemberID = inputMemberID;
END //
DELIMITER ;
#now i can use this procedure to test my trigger, i inserted new members to the member table and inserted some values to 
#the borrowedby table so i can test the trigger by calling the stored procedure and trying to clear the finefee of
#new members since the membership of all the existing members is expired i need to try this on the new members with a later 
#expirydate now i try to clear their fine and see if it is going to change their membership to regular
#call PayFineFees(796,7);
#call PayFineFees(40,8);
#call PayFineFees(27,8);
#call PayFineFees(29,1);
#call PayFineFees(26,8);
#SELECT * FROM Member;
#i also tested the trigger behaviour with the values that are more than the finefee and i tried to pay for memberships
#that are already expired and it raised the custom message i set in the error handler. so the trigger is working and also
#the exceptions are handled using error handler, the screen shot of the raised errors are in the report.
#call PayFineFees(784,1); - the member id 1 is an expired member so this would raise the custom error in the trigger
#call PayFineFees(784,7); - since member's finefee is less than the amount i try to deduct this is going to raise an error

#task3 test plan:
#to test this procedure i can manually insert new rows to the borrowedby table to generate some suspension record for 
#the new members i've added to the Member table since the procedure does not affect the expired memberships since i want
#to try different scenarios i added two records of suspension for one new member and one record for another and more than
#two records for the other member, now i am going to call the procedure and see if it does change the membership status
#call TerminateRepeatOffenders();

##Inseted data:
#INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
#VALUES ('7','REGULAR','Amir','23 Stan St','West','NSW','2025-09-30','0447854894');
#INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
#VALUES ('8','REGULAR','Joe','4 Lily St','Left','VIC','2024-09-30','0447854424');
#INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
#VALUES ('9','REGULAR','Leo','17 Rsp St','south','Far','2025-10-30','0447254834');
#INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
#VALUES ('10','REGULAR','Carl','6 WW St','Macquarie','NSW','2024-10-30','0417894464');
#INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
#VALUES ('11','REGULAR','Sam','6 Pendi St','Quakers','TEH','2026-10-30','0417594564');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('1', '1','7','2023-09-22',NULL,'2023-10-13');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('1', '2','7','2022-09-19',NULL,'2022-10-10');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('1', '1','8','2023-09-22',NULL,'2023-10-13');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('2', '1','8','2023-09-22',NULL,'2023-10-10');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('2', '4','9','2023-09-22',NULL,'2023-8-13');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('3', '5','9','2023-09-22',NULL,'2023-8-10');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('2', '4','10','2023-09-22','2023-8-26','2023-8-13');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('2', '4','11','2023-03-22',NULL,'2023-4-13');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('3', '5','11','2023-02-22',NULL,'2023-3-10');
#INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
#VALUES ('2', '4','11','2023-09-22','2023-8-28','2023-8-13');
