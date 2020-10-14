DECLARE @Year int = 2019
DECLARE @ECNumber varchar(20) = '35117'


-- get winner of every poll
DROP TABLE IF EXISTS #PollWinners
SELECT
	po.pollID,
	e.ECNumber,
	c.CandidateLastName,
	p.PartyNameEn,
	po.Electors,
	pr.Votes as Votes
INTO #PollWinners
FROM (SELECT pollid, candidateid, resultID, Votes, ROW_NUMBER() OVER (PARTITION BY pollid ORDER BY votes DESC) AS rn
		FROM pollResult)  pr
inner join poll po ON po.pollid=pr.pollid
inner join ed e ON po.edid = e.edid
inner join candidate c ON pr.candidateid = c.candidateid
inner join party p ON c.partyid = p.partyid
WHERE e.ElectionYear=@Year 
	AND ECNumber=@ECNumber 
	AND rn=1
ORDER BY pollID ASC

-- SELECT * FROM PollWinners

-- Count polls won
SELECT ECNumber, CandidateLastName,PartyNameEn,count(*) 
FROM #PollWinners
GROUP By ECNumber, CandidateLastName,PartyNameEn
