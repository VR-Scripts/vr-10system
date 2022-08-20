VRConfig = {}

VRConfig.NewCore = true -- if you are using the exports versin set true
VRConfig.Core = "WPCore" -- Your core name
VRConfig.Exports = "wp-core" -- Your core script name

VRConfig.WhitelistedJobs = { --add job for adding an employee list for the current job and pick how to sort it
    -- Example:
    --[[
        ['jobname'] = {
            ['SortBy'] = 'tag' / 'job' -> how to sort players on the list.
        },
    ]]

    ['police'] = {
        ['SortBy'] = 'tag'--how to sort players on the list.
    },
    ['vu'] = {
        ['SortBy'] = 'job'--how to sort players on the list.
    }
} -- example: 

VRConfig.ShowOnOffDuty = false -- true = show the list when a player is off duty.

VRConfig.ShowJob = true -- shows the player job grade in the list

VRConfig.UpdateChannelEvent = 'srp-10system:server:updateChannel' -- your uptade channel event for updating the chanel in the list

VRConfig.UpdateTalkingEvent = 'srp-10system:server:updateTalking' -- your uptade talking event for updating if you are talking

VRConfig.DefaultCodename = "None" -- Default code if the player didn't define one yet