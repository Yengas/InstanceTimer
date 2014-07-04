local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("InstanceTimer", "frFR")
if not L then return end
L["loadError"] = "Could not load the main window for some reason."
L["failedMessage"] = "You have failed the time requirement for ${instance}."
L["spentFormat"] = "${h} hours, ${m} minutes, ${s} seconds"
L["spentResponse"] = "You have been in ${instance} for ${timeSpent}."
L["notInInstance"] = "You're not in an instance."