-- task 3:
select NurseName, NursePhoneNumber, NurseExperience from Nurse where NurseExperience>15 order by NurseName desc;

-- task 4:
select concat(p.PatientID, ' has an appointment on the ', AppointmentDate)
from Patient p, Appointment a
where p.PatientID = a.PatientID and month(AppointmentDate) like 03;

-- task 5:
select distinct p.PatientID, p.PatientName, p.PatientSuburb 
from Patient p, Appointment a 
where p.PatientID = a.PatientID 
and hour(a.AppointmentTime) > 11;

-- task 6:
select distinct PatientID, PatientName, PatientSuburb 
from Patient p
where  p.PatientID in(select PatientID from Appointment where hour(AppointmentTime) >11);

-- task 7: 
select n.NurseID, n.NurseName, n.NurseExperience, s.ShotTime, s.DoseNumber
from Nurse n, Shot s
where n.NurseID = s.NurseID and n.NursePhoneNumber like '1%' and n.NurseExperience <= 16 order by NurseName asc;

-- task 8:
select p.PatientID, p.PatientName, s.doseNumber as 'number of shots'
from Patient p, Shot s
where p.PatientID = s.PatientID and s.DoseNumber >=2;


-- i have assumed that the  duplicated patients are not counted ->
-- as two so the final output should show no suburb and number of patients, since there is ->
-- no suburb with more than 1 patient who had the vaccine administered by nurse named ' WASIM AKRAM'.
-- task 9: 
select  p.PatientSuburb, count( p.PatientID) as "number of patients"
from Patient p, Nurse n , Shot s
where p.PatientID = s.PatientID and n.NurseID = s.NurseID and s.NurseID = 'N001' 
group by PatientSuburb
having count( p.PatientID) > 1;
-- task 9 final answer:
select  p.PatientSuburb, count(distinct p.PatientID) as "number of patients"
from Patient p, Nurse n , Shot s
where p.PatientID = s.PatientID and n.NurseID = s.NurseID and s.NurseID = 'N001' 
group by PatientSuburb
having count(distinct p.PatientID) > 1;


-- task 10:
CREATE VIEW Medium_Importance AS
select p.PatientID , p.PatientName, p.PatientOccupation
from Shot s , Patient p
where s.PatientID = p.PatientID && s.DoseNumber = 2  && p.PatientAge between 30 and 40    && p.PatientOccupation like 'Health' or 'Aged Care';

