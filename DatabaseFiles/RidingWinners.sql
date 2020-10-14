DECLARE @Year int = 2015

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

-- Output winners only
SELECT e.ECNumber,e.EcNameEn,a.CandidateLastName,a.PartyNameEn,a.Votes 
FROM (select ECNumber,CandidateLastName,PartyNameEn,Votes,ROW_NUMBER() OVER (PARTITION BY ECNumber ORDER BY votes DESC) as rn
FROM #Candidates) as a
INNER JOIN ED e ON a.ECNumber = e.ECNumber AND e.ElectionYear=@Year
WHERE rn=1

