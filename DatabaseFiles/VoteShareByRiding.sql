DROP TABLE IF EXISTS #VotesCast

SELECT 
		e.ECNumber,
		e.EcNameEn,
		SUM(CASE WHEN e.electionyear = 2015 THEN pr.votes ELSE 0 END) AS Votes2015,
		SUM(CASE WHEN e.electionyear = 2019 THEN pr.votes ELSE 0 END) AS Votes2019
INTO #VotesCast
FROM pollresult pr
INNER JOIN poll p ON pr.pollid = p.pollid
INNER JOIN ed e ON e.edid = p.edid
GROUP BY e.EcNumber,e.EcNameEn
--select * from #VotesCast

 SELECT 
	pro.Province,
	ed.ECNumber,
	ed.ECNameEn,
	pa.PartyNameEn,
	SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2015) AS 'Vote Share 2015',
	SUM(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2019) AS 'Vote Share 2019',
	sum(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2019) - SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2015) AS change
FROM PollResult pr 
 INNER JOIN poll p ON pr.pollID = p.pollID
 INNER JOIN candidate c ON c.CandidateID = pr.candidateID
 INNER JOIN party pa ON c.partyID = pa.partyID
 INNER JOIN ed ON ed.EDID = p.EDID
 INNER JOIN ED_province() pro ON ED.EDID = pro.EDID
 INNER JOIN #VotesCast v ON ed.ECNameEn = v.ECNameEn
WHERE Pa.PartyNameEn IN ('Conservative','Liberal','NDP-New Democratic Party','Bloc Québécois','Green Party')
GROUP BY pro.province,ed.ECNumber,ed.ECNameEn,pa.PartyNameEn
ORDER BY SUM(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2019) - SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS DECIMAL(10,6)) ELSE 0 END) / MAX(v.Votes2015)
DESC



