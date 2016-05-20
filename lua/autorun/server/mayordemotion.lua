hook.Add ("PlayerDeath", "MayorDemotion", function (ply)
	if ply:Team () == TEAM_MAYOR then
		ply:ChangeTeam (TEAM_CITIZEN, true)
		NotifyAll (1, 5, ply.DarkRPVars.rpname .. " is no longer the mayor.")
	end
end)