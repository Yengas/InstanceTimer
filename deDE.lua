local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("InstanceTimer", "deDE")
if not L then return end
L["loadError"] = "Das Hauptfenster konnte nicht geladen werden."
L["failedMessage"] = "Zeitlimit für ${instance} überschritten."
L["spentFormat"] = "${h} Stunden, ${m} Minuten, ${s} Sekunden"
L["spentResponse"] = "Du befindest dich seit ${timeSpent} in ${instance}."
L["notInInstance"] = "Du befindest dich nicht in einer Instanz."
