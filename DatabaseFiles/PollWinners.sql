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
FROM (SELECT pollid, candidateid, resultID, Votes, ROW_NUMBER() OVER (PARTITION BY pollid ORDER BY votes DESC, candidateid asc) AS rn
		FROM pollResult)  pr
inner join poll po ON po.pollid=pr.pollid
inner join ed e ON po.edid = e.edid
inner join candidate c ON pr.candidateid = c.candidateid
inner join party p ON c.partyid = p.partyid
WHERE e.ElectionYear=@Year 
--	AND ECNumber=@ECNumber 
	AND rn=1
ORDER BY pollID ASC

DROP TABLE IF EXISTS #PollsWon
-- Count polls won
SELECT ECNumber, CandidateLastName,PartyNameEn,count(*) as PollsWon,ROW_NUMBER() OVER (PARTITION BY ECNumber ORDER BY count(*) DESC) as place
INTO #PollsWon
FROM #PollWinners
GROUP By ECNumber, CandidateLastName,PartyNameEn

SELECT * FROM #PollsWon

DROP TABLE IF EXISTS #WonMostPolls
-- Who won the most polls in each riding?
SELECT pw.ECNumber,pw.CandidateLastName,pw.PartyNameEn as WonMostPolls,pw.PollsWon, NULL as Margin, rw.PartyNameEn as RidingWinner
INTO #WonMostPolls
FROM #PollsWon pw 
INNER JOIN #RidingWinners rw ON pw.ECNumber = rw.ECNumber
Where place = 1

update #WonMostPolls set margin = p1.PollsWon - p2.PollsWon
FROM (select * FROM #PollsWon where place = 1) p1
INNER JOIN (select * FROM #PollsWon where place = 2) p2 on p2.ECNumber = p1.ECNumber
WHERE p1.ECNumber = #WonMostPolls.ECNumber

select e.ECNameEn,wmp.* from #WonMostPolls wmp
inner join ED e on e.ElectionYear = @year and e.ECNumber = wmp.ECNumber
WHERE RidingWinner <> WonMostPolls


select * from #PollsWon where ECNumber = 24021


