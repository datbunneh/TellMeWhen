﻿
local L = LibStub("AceLocale-3.0"):NewLocale("TellMeWhen", "deDE", false)
if not L then return end





L["ALPHAPANEL_TITLE"] = "Transparenz"
L["BleedDamageTaken"] = "Erhöhter Schaden durch Blutungseffekte"
L["Bleeding"] = "Butend"
L["BonusAgiStr"] = "Erhöhte Beweglichkeit/Stärke"
L["BonusArmor"] = "Erhöhte Rüstung"
L["BonusMana"] = "Erhöhter Manavorrat"
L["BonusStamina"] = "Erhöht Ausdauer"
L["BurstHaste"] = "Erhöht Tempo"
L["BurstManaRegen"] = "Erhöht Mana Regeneration"
L["CASTERFORM"] = "Zaubergestalt"
L["CHOOSENAME_DIALOG"] = [=[Geben Sie Namen oder ID von Zauber / Fähigkeit / Gegenstand / Buff / Debuff ein, die mit diesem Symbol überwacht werden soll. Sie können mehrere Buffs / Debuffs hinzufügen, indem Sie diese mit ';' trennen.
Begleiterfähigkeiten müssen per ID eingetragen werden!]=]
L["CHOOSENAME_DIALOG_DDDEFAULT"] = "Vordefinierte Zauber-Sätze"
L["CHOOSENAME_EQUIVS_TOOLTIP"] = "Du kannst einen vordefinierten Satz von Buffs/Debuffs in diesem Menü festlegen."
L["CMD_ERROR"] = "Kann TellMeWhen Konfiguration im Kampf nicht umschalten"
L["CMD_OPTIONS"] = "Optionen"
L["CMD_RESET"] = "Zurücksetzen"
L["CONDITIONPANEL_ALIVE"] = "Einheit ist lebendig"
L["CONDITIONPANEL_ALIVE_DESC"] = "Die Bedingung wird erfüllt, wenn die spezifizierte Einheit lebt."
L["CONDITIONPANEL_AND"] = "und"
L["CONDITIONPANEL_ANDOR"] = "und / oder"
-- L["CONDITIONPANEL_COMBAT"] = ""
L["CONDITIONPANEL_COMBO"] = "Kombo Punkte"
L["CONDITIONPANEL_ECLIPSE_DESC"] = [=[Finsternis hat eine Reichweite von -100 (Mondfinsternis) bis 100 (Sonnenfinsternis)
Gib -80 ein wenn du möchtest das das Symbol mit einem Wert von 80 Mond-Macht funktioniert. ]=]
L["CONDITIONPANEL_EQUALS"] = "gleich"
L["CONDITIONPANEL_EXISTS"] = "Einheit existiert"
L["CONDITIONPANEL_EXISTS_DESC"] = "Bedingung Wahr wenn angegebene Einheit existiert."
L["CONDITIONPANEL_GREATER"] = "größer als"
L["CONDITIONPANEL_GREATEREQUAL"] = "größer als oder gleich"
L["CONDITIONPANEL_ICON"] = "Zeige Symbol"
L["CONDITIONPANEL_ICON_DESC"] = "Die Bedingung wird erfüllt, wenn das Symbol derzeit mit einer Transparenz von über 0% angezeigt oder versteckt mit einer Transparenz von 0% wird."
L["CONDITIONPANEL_LESS"] = "kleiner als"
L["CONDITIONPANEL_LESSEQUAL"] = "kleiner als oder gleich"
L["CONDITIONPANEL_NOTEQUAL"] = "ungleich"
L["CONDITIONPANEL_OPERATOR"] = "Operator"
L["CONDITIONPANEL_OR"] = "oder"
L["CONDITIONPANEL_POWER"] = "Primäre Ressource"
L["CONDITIONPANEL_POWER_DESC"] = [=[Prüft auf Energie, falls die Einheit ein Druide in Katzengestalt ist,
auf Wut, wenn die Einheit ein Krieger ist, usw.]=]
L["CONDITIONPANEL_RESET"] = "Löschen"
L["CONDITIONPANEL_TITLE"] = "TellMeWhen Bedingungs-Editor"
L["CONDITIONPANEL_TYPE"] = "Typ"
L["CONDITIONPANEL_UNIT"] = "Einheit"
L["CONDITIONPANEL_VALUE"] = "Prozent"
L["CONDITIONPANEL_VALUEN"] = "Wert"
L["CONDTWARN"] = "Warnung! Du hast die Anzahl der im Editor gezeigten Abhängigkeiten unter die der höchten die ein Icon haben kann gesenkt. (%s) Dies kann die Abhängigkeiten davon abhalten richtig zu funktionieren. Bist du sicher das du dies tun willst?"
L["COPY"] = "Kopieren"
L["COPYPANEL_GROUP"] = "Gruppe:"
L["COPYPANEL_ICON"] = "Symbol:"
L["COPYPANEL_TITLE"] = "TellMeWhen Symbol-Kopieren"
L["COPYSETTINGS"] = "Von anderem Symbol kopieren"
L["CrowdControl"] = "Massen-Kontrolle"
L["Curse"] = "Fluch"
L["DURATIONPANEL_TITLE"] = "Wirkungszeit"
L["Disarmed"] = "Entwaffnet"
L["Disease"] = "Krankheit"
L["Disoriented"] = "Verwirrt"
L["ECLIPSE_DIRECTION"] = "Finsternis Richtung"
L["ECLIPSE_DIRECTION_DESC"] = [=['-1' wird als "Richtung Mondfinsternis (links)" interpretiert.
'1' wird als "Richtung Sonnenfinsternis (rechts)" interpretiert.]=]
L["EDITORPANEL_TITLE"] = "\"TelMeWhen\"-Symbol Bearbeiten"
L["FALSE"] = "Falsch"
L["FROM"] = "von:"
L["Feared"] = "Furcht"
L["GENABLEBUTTON"] = "Guppe %d ist deaktiviert. Klicken um vorübergehend zu aktivieren."
L["GROUP"] = "Gruppe"
L["GROUPICON"] = "Gruppe: %d, Symbol %d"
L["GROUPRESETMSG"] = "TellMeWhen Gruppe %d auf Ausgangsposition"
L["HPSSWARN"] = "Warnung! Alle Icon Abhängigkeiten die du für Heilige Macht und Seelensteine gemacht hast können falsch sein! Überprüfe sie um spätere Verwirrungen zu vermeiden."
-- L["Heals"] = ""
L["ICONALPHAPANEL_ALPHA"] = "Nutzbare / Vorhanden Transparenz"
L["ICONALPHAPANEL_ALPHA_DESC"] = "Schieben um die Transparenz für das Symbol setzten, wenn die Fähigkeit nutzbar / vorhanden ist."
L["ICONALPHAPANEL_CNDTALPHA"] = "Fehlgeschlagende Voraussetzung"
-- L["ICONALPHAPANEL_CNDTALPHA_DESC"] = ""
L["ICONALPHAPANEL_DURATIONALPHA"] = "Falsche Wirkungsdauer"
L["ICONALPHAPANEL_DURATIONALPHA_DESC"] = "Regler schieben um die Transparenz für das Symbol zusetzen, wenn die Wirkungsdauer-Vorraussetzungen fehlschlagen."
L["ICONALPHAPANEL_FAKEHIDDEN"] = "Versteckt"
L["ICONALPHAPANEL_FAKEHIDDEN_DESC"] = "Macht das Symbol unsichtbar, lässt es aber aktiv damit andere Symbole verknüpfte Bedingungen weiterhin prüfen können." -- Needs review
L["ICONALPHAPANEL_STACKALPHA"] = "Falsche Stapelung"
L["ICONALPHAPANEL_STACKALPHA_DESC"] = "Regler schieben um die Transparenz für das Symbol zusetzen, wenn die Stapel-Vorraussetzungen fehlschlagen."
L["ICONALPHAPANEL_THISISSET_DESC"] = "Dies wird auf 0 gesetzt, wenn \"Fake hidden\" aktiviert ist."
L["ICONALPHAPANEL_UNALPHA"] = "Nicht benutzbar / Nicht vorhanden Transparenz"
L["ICONALPHAPANEL_UNALPHA_DESC"] = "Schieben um die Transparenz für das Symbol setzten, wenn die Fähigkeit nicht benutzbar / nicht vorhanden ist."
L["ICONMENU_ABSENT"] = "Abwesend"
L["ICONMENU_ADDCONDITION"] = "Bedingung hinzufügen"
L["ICONMENU_ALPHA"] = "Transparenz"
L["ICONMENU_ALWAYS"] = "Immer"
L["ICONMENU_BARS"] = "Leisten"
L["ICONMENU_BOTH"] = "Entweder"
L["ICONMENU_BUFF"] = "Buff"
L["ICONMENU_BUFFDEBUFF"] = "Buff / Debuff"
L["ICONMENU_BUFFSHOWWHEN"] = "Zeige wenn Buff / Debuff"
L["ICONMENU_BUFFTYPE"] = "Buff oder Debuff?"
L["ICONMENU_CAST"] = "Zauber"
-- L["ICONMENU_CASTS"] = ""
-- L["ICONMENU_CASTSHOWWHEN"] = ""
-- L["ICONMENU_CAST_DESC"] = ""
L["ICONMENU_CHOOSENAME"] = "Wähle Zauber / Gegenstand / Buff / etc."
L["ICONMENU_CLEAR"] = "Einstellungen löschen"
L["ICONMENU_COOLDOWN"] = "Abklingzeit"
L["ICONMENU_COOLDOWNCHECK"] = "Abklingzeiten aktiviert?"
L["ICONMENU_COOLDOWNCHECK_DESC"] = "Aktivieren für Farbänderung des Symbols, wenn reaktive Fähigkeit auf Abklingzeit ist."
L["ICONMENU_COOLDOWNTYPE"] = "Abklingzeit Typ"
L["ICONMENU_DEBUFF"] = "Debuff"
L["ICONMENU_DISPEL"] = "Entfernen-Typ"
L["ICONMENU_DURATIONANDCD"] = "Dauer > Abklingzeit"
L["ICONMENU_DURATION_MAX_DESC"] = "Maximale Wirkungszeit erlaubt das Symbol anzuzeigen."
L["ICONMENU_DURATION_MIN_DESC"] = "Minimum Wirkungszeit benötigt um das Symbol anzuzeigen"
L["ICONMENU_EDIT"] = "Bearbeiten"
L["ICONMENU_EDITCONDITION"] = "Bearbeite Bedingung"
L["ICONMENU_EITHER"] = "Alle Einheiten"
L["ICONMENU_ENABLE"] = "Symbol aktivieren"
L["ICONMENU_FOCUSTARGET"] = "Fokusziel"
L["ICONMENU_FRIEND"] = "freundliche Einheiten"
L["ICONMENU_HIDEUNEQUIPPED"] = "Verstecken wenn der Platz leer ist."
L["ICONMENU_HOSTILE"] = "feindliche Einheiten"
L["ICONMENU_ICONS"] = "Symbole"
L["ICONMENU_INVERTBARS"] = "Leisten auffüllen"
L["ICONMENU_ITEM"] = "Gegenstand"
L["ICONMENU_MANACHECK"] = "Ressourcen Prüfung?"
L["ICONMENU_MANACHECK_DESC"] = "Aktivieren für Farbänderung des Symbols, wenn kein/e Mana/Wut/Runenmacht/etc. vorhanden ist."
L["ICONMENU_META"] = "Meta Symbol"
L["ICONMENU_META_DESC"] = [=[Dieser Symbol Typ kann mehrere Symbole miteinander kombinieren.
Icons that have fake hidden enabled will still be shown if they would otherwise be shown.]=] -- Needs review
L["ICONMENU_MOUSEOVER"] = "Mausover"
L["ICONMENU_MOUSEOVERTARGET"] = "Mausover des Ziels"
-- L["ICONMENU_MULTISTATECD"] = ""
L["ICONMENU_MULTISTATECD_DESC"] = [=[Dieses Symbol sollte verwendet werden, wenn du dir mehrere Status / Texturen / etc. von einer Abklingzeit anzeigen lassen willst.
Einige Beispiele sind: Segenswort: Züchtigung, Dunkles Simulakrum, Verstohlenheit und Aspekte / Auren / Gestaltveränderungen.
WICHTIG: Der Zauber MUSS auf einer deiner Aktionsleisten liegen!
Du solltest außerdem sicherstellen, dass die Fähigkeit in ihrem Standard Zustand ist beim Verlassen der TMW Config.]=]
L["ICONMENU_ONLYINTERRUPTIBLE"] = "Nur unterbrechbare Zauber"
L["ICONMENU_ONLYMINE"] = "Nur zeigen, wenn selbst gezaubert"
L["ICONMENU_OPTIONS"] = "Weitere Optionen"
L["ICONMENU_PETTARGET"] = "Begleiterziel"
L["ICONMENU_PRESENT"] = "Vorhanden"
L["ICONMENU_RANGECHECK"] = "Reichweiten Prüfung"
L["ICONMENU_RANGECHECK_DESC"] = "Aktivieren für Farbänderung des Symbols wenn ausser Reichweite."
L["ICONMENU_REACT"] = "Einheit Reaktion"
L["ICONMENU_REACTIVE"] = "Reaktiver Zauber oder Fähigkeit"
L["ICONMENU_SETALPHA"] = "Setze Transparenz"
L["ICONMENU_SETALPHAMOD"] = "Setez Alpha Level aufl |cFFFF5959(Modified)|r"
L["ICONMENU_SHOWCBAR"] = "Zeige Abklingzeit/Timer Leiste"
L["ICONMENU_SHOWPBAR"] = "Zeige Ressourcen-Leiste"
L["ICONMENU_SHOWTIMER"] = "Zeige Timer"
L["ICONMENU_SHOWTIMERTEXT"] = "Zeige Nummer des Zeitgebers"
L["ICONMENU_SHOWTIMERTEXT_DESC"] = "Nur wirksam wenn \"Zeige Zeitgeber\" aktiviert ist"
L["ICONMENU_SHOWWHEN"] = "Zeige Symbol, wenn"
L["ICONMENU_SPELL"] = "Zauber oder Fähigkeit"
L["ICONMENU_STACKS_MAX_DESC"] = "Maximale Anzahl der Stapel von der Aura benötigt, um das Symbol anzuzeigen"
L["ICONMENU_STACKS_MIN_DESC"] = "Minimal Anzahl der Stapel von der Aura benötigt, um das Symbol anzuzeigen"
L["ICONMENU_TARGET_OR_FOCUS"] = "Ziel oder Fokus"
L["ICONMENU_TARGETTARGET"] = "Ziel des Ziels"
L["ICONMENU_TOTEM"] = "Totem / non-MoG Ghoul"
L["ICONMENU_TOTEM_DESC"] = "Der eingegebene Name sollte \"Auferstandener Ghul\" sein, um Nicht-Spieler-Begleiter-Ghule aufzuspüren."
L["ICONMENU_TYPE"] = "Icon Typ"
L["ICONMENU_UNIT"] = "zu überwachende Einheit"
L["ICONMENU_UNUSABLE"] = "unbenutzbar"
L["ICONMENU_USABLE"] = "Benutzbar"
L["ICONMENU_VEHICLE"] = "Fahrzeug"
L["ICONMENU_WPNENCHANT"] = "Temporäre Waffenverzauberung"
L["ICONMENU_WPNENCHANTTYPE"] = "zu überwachender Waffenplatz"
L["ICONTOCHECK"] = "Zu prüfendes Symbol"
L["ICON_TOOLTIP1"] = "TellMeWhen"
L["ICON_TOOLTIP2"] = "Rechtsklick für Symbol-optionen. Weitere Optionen sind in den Blizzard Interface-Optionen, Typ /tmw zu sperren und zu aktivieren Addon..."
L["ImmuneToMagicCC"] = "Immun gegen magische Beherrschung"
L["ImmuneToStun"] = "Immun gegen Effekte die Betäuben"
L["Incapacitated"] = "Bewegungsunfähig"
L["IncreasedAP"] = "Erhöht Angriffskraft"
L["IncreasedCrit"] = "Erhöht Chance Kritisch zu treffen"
L["IncreasedDamage"] = "Erhöhter verursachter Schaden"
L["IncreasedPhysHaste"] = "Erhöhte Nahkampfgeschwindigkeit"
L["IncreasedSPsix"] = "Erhöhte Zaubermacht (6%)"
L["IncreasedSPten"] = "Erhöhte Zaubermacht (10%)"
L["IncreasedSpellHaste"] = "Erhöhtes Zaubertempo"
L["IncreasedStats"] = "Erhöhte Attribute"
L["LDB_TOOLTIP1"] = "|cff7fffffLinks-Klick|r um die Gruppen umzuschalten."
L["LDB_TOOLTIP2"] = "|cff7fffffRechts klick|r um spezielle Gruppen ein/auszublenden."
-- L["METAPANEL_TITLE"] = ""
L["MOON"] = "Mond"
L["Magic"] = "Magie"
L["ManaRegen"] = "Erhöhte Manaregeneration"
L["NONE"] = "Nichts vom folgenden"
L["OUTLINE_NO"] = "Keine Umrandung"
L["OUTLINE_THICK"] = "Dicke Umrandung"
L["OUTLINE_THIN"] = "Dünne Umrandung"
L["PhysicalDmgTaken"] = "Erhöhter Nahkampfschaden"
L["Poison"] = "Gift"
L["PushbackResistance"] = "Erhöhter Rückstoßwiderstand "
-- L["PvPSpells"] = ""
L["RESIZE"] = "Größe ändern"
L["RESIZE_TOOLTIP"] = "Klicken und ziehen um die größe zu ändern"
L["RLWARN"] = "Warnung! Das UI muss neu geladen werden wenn die Anzahl der Gruppen geändert wurde, um TMW komplett zurück zu setzen. Nun neu laden?"
L["ReducedArmor"] = "Verringerte Rüstungswertung"
L["ReducedAttackSpeed"] = "Verringerte Angriffsgeschwindigkeit"
L["ReducedCastingSpeed"] = "Verringertes Zaubertempo"
L["ReducedHealing"] = "Verringerte Heilung"
L["ReducedPhysicalDone"] = "Verringerter verursachter Schaden"
L["Resistances"] = "Erhöhter Zauberwiderstand"
L["Rooted"] = "Gewurzelt"
L["STACKSPANEL_TITLE"] = "Stapel"
L["SUN"] = "Sonne"
L["Silenced"] = "Zum Schweigen gebracht"
L["SpellCritTaken"] = "Erhöhte kritische Zaubertrefferchance"
L["SpellDamageTaken"] = "Erhöhter Zauberschaden erhalten"
L["Stunned"] = "Betäubt"
L["TO"] = "Nach:"
L["TRUE"] = "Wahr"
-- L["Tier11Interrupts"] = ""
L["UIPANEL_ALLRESET"] = "Alles zurücksetzen"
L["UIPANEL_BARIGNOREGCD"] = "Leiste ignoriert GCD"
L["UIPANEL_BARIGNOREGCD_DESC"] = "Wenn ausgewählt, werden die Abklingzeiten Leisten die Werte nicht ändern wenn die Abklingzeit eine Globale Abklingzeit ist."
L["UIPANEL_BARTEXTURE"] = "Leistentextur"
L["UIPANEL_CLOCKIGNOREGCD"] = "Timer ignoriert Globale Abklingzeiten."
L["UIPANEL_CLOCKIGNOREGCD_DESC"] = "Wenn ausgewählt, werden Timer und Aklingzeiten nicht von der Globalen Abklingzeit ausgelöst."
L["UIPANEL_COLOR"] = "Abklingzeit/Wirkungsdauer Leisten-Farbe"
L["UIPANEL_COLORS"] = "Farben"
L["UIPANEL_COLOR_ABSENT"] = "Farbe für Abwesenheit"
L["UIPANEL_COLOR_ABSENT_DESC"] = "Färbung des Symbols wenn Buff / Debuff / Verzauberung / Totem fehlt und \"immer zeigen\" aktiviert ist."
L["UIPANEL_COLOR_COMPLETE"] = "Abklingzeit/Wirkungsdauer abgeschlossen"
L["UIPANEL_COLOR_COMPLETE_DESC"] = "Farbüberlagerung der Leiste, wenn die Abklingzeit / Wirkungsdauer abgeschlossen ist"
L["UIPANEL_COLOR_DESC"] = "Nachfolgende Optionen beeinflussen nur die Farben der Symbole die auf \"immer zeigen\" stehen."
L["UIPANEL_COLOR_OOM"] = "Ende der Ressourcen-Farbe"
L["UIPANEL_COLOR_OOM_DESC"] = "Färbung und Transparenz des Symbols, bei zu wenig Mana / Wut / Energie / Fokus / Runenmacht für den Zauberspruch"
L["UIPANEL_COLOR_OOR"] = "Außer Reichweite-Farbe"
L["UIPANEL_COLOR_OOR_DESC"] = "Färbung und Transparenz des Symbols, wenn nicht in Reichweite zum Ziels um den Zauberspruch zu wirken."
L["UIPANEL_COLOR_PRESENT"] = "Derzeitige Farbe"
L["UIPANEL_COLOR_PRESENT_DESC"] = "Färbung des Symbols wenn Buff / Debuff / Verzauberung / Totem vorhanden und \"immer zeigen\" aktiviert ist."
L["UIPANEL_COLOR_STARTED"] = "Abklingkeit/Wirkungsdauer-Beginn"
L["UIPANEL_COLOR_STARTED_DESC"] = "Färbung der Leiste, wenn die Abklingzeit /Wirkungsdauer gerade erst begonnen hat"
L["UIPANEL_COLUMNS"] = "Spalten"
L["UIPANEL_CONDENSE"] = "Übereinstimmende Einstellungen"
L["UIPANEL_DRAWEDGE"] = "Blinkender Rand-Zeit"
L["UIPANEL_DRAWEDGE_DESC"] = "Blinkender Rand um die Abklingzeit (Uhr-Animation), um die Sichtbarkeit zu erhöhen"
L["UIPANEL_ENABLEGROUP"] = "Gruppe freigeben"
L["UIPANEL_FONT"] = "Zeichensatz"
L["UIPANEL_FONT_DESC"] = "Wähle die Schriftart für den Text von gestapelten Symbolen."
L["UIPANEL_FONT_OUTLINE"] = "Schriftart-Kontur"
L["UIPANEL_FONT_OUTLINE_DESC"] = "Setzt die Kontur-Art für Text bei gestapelten Symbolen." -- Needs review
L["UIPANEL_FONT_SIZE"] = "Zeichengröße"
L["UIPANEL_FONT_SIZE_DESC"] = "Ändert die Größe für die benutzt Schriftart bei gestapelten Symbolen. Wenn ButtonFacade benuzt wird und der ButtonFacade Skin eine vordefinierte Schriftgröße hat, wird diese Einstellung ignoriert."
L["UIPANEL_GROUPRESET"] = "Position zurücksetzen"
L["UIPANEL_GROUPRESETHEADER"] = "Position zurücksetzen"
L["UIPANEL_GROUPS"] = "Gruppen"
L["UIPANEL_ICONGROUP"] = "Symbolgruppe "
L["UIPANEL_ICONSPACING"] = "Abstand der Icon's."
L["UIPANEL_ICONSPACING_DESC"] = "Abstand der Icons' in einer Gruppe."
L["UIPANEL_LOCK"] = "sperre AddOn"
L["UIPANEL_LOCKUNLOCK"] = "Sperren / Entsperren AddOn"
L["UIPANEL_MAINOPT"] = "Grundeinstellungen"
L["UIPANEL_NOCOUNT"] = "Timer Text umschalten"
L["UIPANEL_NOCOUNT_DESC"] = "Akiviert/Deaktiviert die auf Icons angezeigten Abklingzeiten. Dies wird nur angezeigt wenn der Icon Timer aktiviert ist, diese Option ist aktiviert und OMNICC IST INSTALLIERT."
L["UIPANEL_NOTINVEHICLE"] = "Im Fahrzeug verstecken"
L["UIPANEL_NUMGROUPS"] = "Anzahl der Gruppen"
L["UIPANEL_NUMGROUPS_DESC"] = "Ändert die Anzal der verfügbaren Gruppen. Benötigt UI Neustart."
L["UIPANEL_ONLYINCOMBAT"] = "Nur im Kampf zeigen"
L["UIPANEL_PRIMARYSPEC"] = "Erste Talentspezialisierung"
L["UIPANEL_RELOAD"] = "UI Neustart"
L["UIPANEL_ROWS"] = "Zeilen"
L["UIPANEL_SECONDARYSPEC"] = "Zweite Talentspezialisierung"
L["UIPANEL_SPEC"] = "Talent Spezialisierung"
L["UIPANEL_STANCE"] = "Zeige, während in"
L["UIPANEL_SUBTEXT1"] = "Diese Optionen ermöglichen es dir, die Anzahl, Anordnung und Verhalten der Erinnerungssymbole zu ändern."
L["UIPANEL_SUBTEXT2"] = "Symbole funktionieren im gesperrten Zustand, im entsperrten Zustand kannst du die Symbolgruppen bewegen, die größe ändern und mit einem rechtsklick einzelne Symbole anklicken, für weitere Optionen. Du kannst auch '/tellmewhen' oder /tmw zum sperren / entsperren tippen."
L["UIPANEL_TOOLTIP_ALLRESET"] = "DATEN und POSITIONEN aller Symbole und Gruppen zurücksetzen"
L["UIPANEL_TOOLTIP_COLUMNS"] = "Setzt die Anzahl der Symbolspalten in dieser Gruppe"
L["UIPANEL_TOOLTIP_CONDENSE"] = "Über die Zeit, deinw \"TMW\" Einstellungen werden mit vielen Voreinstellungs-Werten gefüllt, welche in deinen Einstellung nicht benötigt werden. Drück diesen Button, um die überflüssigen Einstellungen entfernen zulassen."
L["UIPANEL_TOOLTIP_ENABLEGROUP"] = "Zeige und aktivieren diese Gruppe von Symbolen"
L["UIPANEL_TOOLTIP_GROUPRESET"] = "Position dieser Gruppe zurücksetzen"
L["UIPANEL_TOOLTIP_NOTINVEHICLE"] = "Auswählen um diese Gruppe zu verstecken wenn du dich in einem Fahrzeug befindest."
L["UIPANEL_TOOLTIP_ONLYINCOMBAT"] = "Aktivieren um nur diese Gruppe von Symbolen im Kampf zu zeigen"
L["UIPANEL_TOOLTIP_PRIMARYSPEC"] = "Aktivieren damit diese Gruppe von Symbolen angezeigt wird, während deine erste Talentspezialisierung aktiv ist"
L["UIPANEL_TOOLTIP_ROWS"] = "Setzt die Anzahl der Symbolreihen in dieser Gruppe"
L["UIPANEL_TOOLTIP_SECONDARYSPEC"] = "Aktivieren damit diese Gruppe von Symbolen angezeigt wird, während deine zweite Talentspezialisierung aktiv ist"
L["UIPANEL_TOOLTIP_UPDATEINTERVAL"] = "Legt fest wie oft (in Sekunden) Symbole auf zeigen/verstecken, alpha, Bedingungen usw. überprüft werden. Beeinträchtigt keine Leisten. Null ist so schnell wie möglich. Niedrigere Werte können erheblichen Einfluss auf die Framerate für Low-End-Rechner haben"
L["UIPANEL_UNLOCK"] = "entsperre AddOn"
L["UIPANEL_UPDATEINTERVAL"] = "Aktualisierungs-Interval"
