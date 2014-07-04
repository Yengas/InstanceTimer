local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("InstanceTimer", "deDE")
if not L then return end
L["loadError"] = "Das Hauptfenster konnte nicht geladen werden."
L["failedMessage"] = "Zeitlimit für %s überschritten."
L["spentFormat"] = "%i Stunden, %i Minuten, %i Sekunden"
L["spentResponse"] = "Du befindest dich seit %s in %s." -- first %s = time second %s = location
L["notInInstance"] = "Du befindest dich nicht in einer Instanz."
