DROP TABLE IF EXISTS #VotesCast

SELECT 
		e.EcNameEn,
		SUM(CASE WHEN e.electionyear = 2015 THEN pr.votes ELSE 0 END) AS Votes2015,
		SUM(CASE WHEN e.electionyear = 2019 THEN pr.votes ELSE 0 END) AS Votes2019
INTO #VotesCast
FROM pollresult pr
inner join poll p on pr.pollid = p.pollid
inner join ed e on e.edid = p.edid
GROUP by e.EcNameEn
--select * FROM #VotesCAST

 select 
	pro.Province,
	pa.PartyNameEn,
	SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2015) AS 'Vote Share 2015',
	SUM(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2019) AS 'Vote Share 2019',
	SUM(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2019) - SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2015) AS change
FROM PollResult pr 
 inner join poll p on pr.pollID = p.pollID
 inner join candidate c on c.CandidateID = pr.candidateID
 inner join party pa on c.partyID = pa.partyID
 inner join ed on ed.EDID = p.EDID
 inner join ED_province() pro on ED.EDID = pro.EDID
 inner join #VotesCast v on ed.ECNameEn = v.ECNameEn
WHERE Pa.PartyNameEn in ('Conservative','Liberal','NDP-New Democratic Party','Bloc Québécois','Green Party')
GROUP by pro.province,pa.PartyNameEn
ORDER by SUM(CASE WHEN ed.ElectionYear = 2019 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2019) - SUM(CASE WHEN ed.ElectionYear = 2015 THEN CAST(Votes AS decimal(10,6)) ELSE 0 END) / MAX(v.Votes2015)
desc



