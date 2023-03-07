-- list of all existing challenges with their functions and countdown

Challenges_list = {
    {
        ["name"] = "most_headshots",
        ["start"] = "StartHeadShotsChallenge",
        ["end"] = "EndHeadShotsChallenge",
        ["countdown"] = 180000
    },
    {
        ["name"] = "most_kills",
        ["start"] = "StartMostKillsChallenge",
        ["end"] = "EndMostKillsChallenge",
        ["countdown"] = 180000
    },
    {
        ["name"] = "longest_freefall_survived",
        ["start"] = "StartLongestFreefallSurvivedChallenge",
        ["end"] = "EndLongestFreefallSurvivedChallenge",
        ["countdown"] = 180000
    },
}

Config = {
    cooldown = 30000, -- time to wait before starting a new challenge when the previous one is over
}