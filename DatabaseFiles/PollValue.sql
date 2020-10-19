DECLARE @Year int = 2019
DECLARE @ECNumber varchar(20) = '35117'


-- Create table of all candidates in @Year with their votes
DROP TABLE IF EXISTS #Candidates
SELECT
	e.ECNumber,
	c.CandidateLastName,
	p.PartyNameEn,
	sum(pr.Votes) as Votes

INTO #Candidates
from PollResult pr
inner join poll po on po.pollid=pr.pollid
inner join ed e on po.edid = e.edid
inner join candidate c on pr.candidateid = c.candidateid
inner join party p on c.partyid = p.partyid
WHERE e.ElectionYear=@Year
GROUP BY e.ECNumber,p.PartyNameEn,c.candidatelastname,pr.CandidateID
ORDER BY e.ECNumber ASC,sum(pr.votes) desc


DROP TABLE IF EXISTS #RidingWinners
-- Output winners only
SELECT e.ECNumber,e.EcNameEn,a.CandidateLastName,a.PartyNameEn,a.Votes
INTO #RidingWinners
FROM	(select 
			ECNumber,
			CandidateLastName,
			PartyNameEn,
			Votes,
			ROW_NUMBER() OVER (PARTITION BY ECNumber ORDER BY votes DESC) as rn
		FROM #Candidates) as a
INNER JOIN ED e ON a.ECNumber = e.ECNumber AND e.ElectionYear=@Year
WHERE rn=1

DROP TABLE IF EXISTS #PollValue
SELECT 
	po.pollID,
	e.ECNumber,
	p.PartyNameEn,
	CASE 
		WHEN po.Electors > 0 THEN (cast(pr.Votes as decimal(9,4)) / cast(po.Electors as decimal(9,4))) 
		 ELSE 0 
	END as [Value]
INTO #PollValue
FROM PollResult pr
inner join poll po ON po.pollid=pr.pollid
inner join ed e ON po.edid = e.edid
inner join candidate c ON pr.candidateid = c.candidateid
inner join party p ON c.partyid = p.partyid
WHERE e.ElectionYear=@Year 

select e.ECNameEn,po.PollName,pv.* from #PollValue pv
inner join ed e on pv.ECNumber = e.ECNumber AND e.ElectionYear=@Year
inner join Poll po on pv.PollID = po.PollID
WHERE po.PollID NOT IN 
-- Eliminate anomalous poll elector counts
(
SELECT 
	p.pollID
FROM 
	poll p
INNER JOIN pollresult pr ON pr.pollid = p.pollid
INNER JOIN ED e ON e.EDID = p.EDID 

GROUP BY 
	e.ECNameEn,
	p.PollName,
	p.pollid
HAVING 
	SUM(pr.Votes) > MAX(p.Electors)
)
ORDER BY pv.Value DESC

-- Get the details on Pinsent Arm
select * from pollresult where pollid = 78527
select * from poll where pollid = 78527