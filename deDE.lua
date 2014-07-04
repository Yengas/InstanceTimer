local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("InstanceTimer", "deDE")
if not L then return end
L["loadError"] = "Could not load the main window for some reason."
L["failedMessage"] = "You have failed the time requirement for %s."
L["spentFormat"] = "%i hours, %i minutes, %i seconds"
L["spentResponse"] = "You have been in %s for %s."
L["notInInstance"] = "You're not in an instance."