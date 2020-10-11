drop table if exists #VotesCast

select 
		e.EcNameEn,
		sum(case when e.electionyear = 2015 then pr.votes else 0 end) as Votes2015,
		sum(case when e.electionyear = 2019 then pr.votes else 0 end) as Votes2019
into #VotesCast
from pollresult pr
inner join poll p on pr.pollid = p.pollid
inner join ed e on e.edid = p.edid
group by e.EcNameEn
--select * from #VotesCast

 select 
	pro.Province,
	pa.PartyNameEn,
	sum(CASE WHEN ed.ElectionYear = 2015 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2015) as 'Vote Share 2015',
	sum(CASE WHEN ed.ElectionYear = 2019 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2019) as 'Vote Share 2019',
	sum(CASE WHEN ed.ElectionYear = 2019 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2019) - sum(CASE WHEN ed.ElectionYear = 2015 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2015) as change
from PollResult pr 
 inner join poll p on pr.pollID = p.pollID
 inner join candidate c on c.CandidateID = pr.candidateID
 inner join party pa on c.partyID = pa.partyID
 inner join ed on ed.EDID = p.EDID
 inner join ED_province() pro on ED.EDID = pro.EDID
 inner join #VotesCast v on ed.ECNameEn = v.ECNameEn
where Pa.PartyNameEn in ('Conservative','Liberal','NDP-New Democratic Party','Bloc Québécois','Green Party')
group by pro.province,pa.PartyNameEn
order by sum(CASE WHEN ed.ElectionYear = 2019 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2019) - sum(CASE WHEN ed.ElectionYear = 2015 THEN cast(Votes as decimal(10,6)) ELSE 0 END) / max(v.Votes2015)
desc



