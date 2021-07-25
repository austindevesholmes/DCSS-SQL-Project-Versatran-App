--This script was created for the Versatrans Tyler Application. 

SELECT DISTINCT
cl.name AS CalendarName, 
i.lastname AS 'Last Name',
i.firstname AS 'First Name', 
e.grade AS 'Grade',  
sl.number AS 'School Building Code', 
CASE WHEN postofficebox = 1 THEN 'P.O. Box' + a.number ELSE 
ISNULL(a.number, ' ')  + ' ' + ISNULL(a.prefix, ' ') + ' ' + ISNULL(a.street, ' ') + ' ' + ISNULL(a.tag, ' ')  + ' ' + ISNULL(a.dir, ' ')  END AS 'Home Street',
a.apt AS 'Home Apartment Box', 
a.city AS 'Home City', 
a.[state] AS 'Home State',
dbo.fn_guardian1(p.personID) as 'Emergency Contact 1', 
i.gender AS 'Gender', 
e.disability1 AS 'INFO ESP Local Code', 
p.studentnumber AS 'Student ID', 
a.zip AS 'Home Zip Code', 
REPLACE(REPLACE(REPLACE(hh.phone,'(',''),')',''),'-','') AS 'Emergency Phone 1', 
hh.householdID AS 'Family ID', 
CONVERT(VARCHAR(10),i.birthdate,101) AS 'Birth Date', 
CASE WHEN pe.eligibility in ('F') THEN '1'
     WHEN pe.eligibility in ('R') THEN '5' ELSE '0' END AS 'INFO F/R',
	 raceEthnicityFed AS 'INFO Race' 

FROM p
JOIN i WITH(NOLOCK) ON i.identityID = p.currentidentityID
JOIN e WITH(NOLOCK) ON e.personID = p.personID
JOIN cl WITH(NOLOCK) ON cl.calendarID = e.calendarID
JOIN sl WITH(NOLOCK) ON sl.schoolid = cl.schoolid 
JOIN sy WITH(NOLOCK) ON sy.endyear = e.endyear 
LEFT JOIN ct WITH(NOLOCK) ON ct.personID = p.personID
LEFT JOIN r WITH(NOLOCK) ON r.personID = p.personID
LEFT JOIN se WITH(NOLOCK) ON se.sectionID = r.sectionID
LEFT JOIN c WITH(NOLOCK) ON c.courseID = se.courseID and c.calendarID = cl.calendarID
LEFT JOIN lep WITH(NOLOCK) ON lep.lepid = p.personid 
LEFT JOIN tco WITH(NOLOCK) ON tco.personid = p.personid 
LEFT JOIN tcr WITH(NOLOCK) ON tco.transcriptid = tcr.transcriptid 
JOIN hm ON hm.personid = p.personid 
JOIN hl ON hl.householdID = hm.householdID 
JOIN a ON a.addressid = hl.addressid 
JOIN hh ON hh.householdid = hm.householdid 
LEFT JOIN POSEligibility pe ON pe.eligibilityID = 
	(SELECT TOP 1 pe2.eligibilityID FROM pe2
		WHERE pe2.personID=e.personID 
		AND (pe2.endDate IS NULL OR (GETDATE() BETWEEN pe2.startDate AND pe2.endDate))
		ORDER BY endDate)

WHERE
sy.active = 1 
AND e.active = 1
AND ISNULL(e.noshow, 0) = 0
AND e.enddate is null
AND hm.enddate IS NULL 
AND hm.secondary = 0
AND hl.enddate IS NULL 
AND hl.secondary = 0 

ORDER BY sl.name 
