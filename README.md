# owiscan_trennblatt


Ich habe dieses Skript erstellt, um gescannte Dokumente für den Import in Owiscan vorzubereiten. Das Skript macht vieles automatisch, aber ich finde es wichtig, die Dokumente vorher noch einmal von Hand zu prüfen. Der beste Weg dafür ist die Miniaturansicht von Windows (Ansicht -> Extra große Symbole). 
So kann man schnell sehen, ob die Scans korrekt sind. Man erkennt leicht Fehler, zum Beispiel wenn Seiten falsch herum oder schief gescannt wurden, wenn die Farben nicht stimmen oder wenn Seiten in einem Stapel fehlen.
Das Motto ist: Manuelle Sichtung und Überprüfung, um wirklich sicherzustellen, ob alles korrekt verarbeitet wird. Owiscan bietet diese Funktion leider nicht. Insbesondere die schnelle Ansicht von Dokumenten. 

Hauptfunktion

Das Skript dient dazu, Trennblätter durch manuelle Auswahl zu standardisieren. Dazu wird das Ursprungsblatt aus dem Ordner _grunddaten verwendet, um die bestehenden Dateien zu ersetzen und dabei ihre ursprünglichen Dateinamen zu übernehmen.

Backup und Protokollierung
Um die Daten zu sichern, habe ich das Skript so konzipiert, dass es ein Backup erstellt und alle Schritte genau protokolliert.
Backup-Erstellung: Vor jeder Verarbeitung wird ein Backup mit einem Zeitstempel als Ordnername im Format JJ-MM-TT-HHMM erstellt. Ich habe es so programmiert, dass jede .tif-Datei, die nochmals als Trennblatt neu konvertiert wird, in diesen Backup-Ordner kopiert wird, bevor die Ursprungsdateien mit der Grund-TIF-Datei im Ordner _grunddaten ersetzt werden.
Protokollierung: Ich habe eine CSV-Protokolldatei namens process_log.csv erstellt. Das Skript wird sie aktualisieren und jede Aktion (Backup, Kopie, keine Änderung, Verschiebung) zusammen mit einem Zeitstempel und dem Dateipfad erfassen. Dies bietet eine kurze Übersicht über die geschehenen Aktionen.

Manuelle Sichtung und Überprüfung

In den Kommentaren, die ich geschrieben habe, lege ich großen Wert auf die manuelle Überprüfung der gescannten Dokumente, bevor das Skript ausgeführt wird. Die Hauptidee ist, die Windows-Miniaturansicht zu verwenden (Ansicht -> Extra große Symbole), um visuell zu bestätigen, dass die gescannten Dokumente von hoher Qualität sind. Die visuelle Überprüfung hilft, häufige Scanfehler zu identifizieren, wie z.B. falsch gescannte Seiten, falsche Farbmodi (z.B. Schwarzweiß statt Farbe) oder schiefe Scans. Auch kann man direkt sehen, ob in einem Stapel zwischen zwei Trennseiten alle Seiten gescannt wurden.

Qualitätskontrolle: Die visuelle Überprüfung hilft, häufige Scanfehler zu identifizieren, wie z.B. falsch gescannte Seiten, falsche Farbmodi (z.B. Schwarzweiß statt Farbe) oder schiefe Scans. Auch kann man direkt sehen, ob in einem Stapel zwischen zwei Trennseiten alle Seiten gescannt wurden.

Tipp für die Miniaturansicht: Ich habe sogar erklärt, wie die Größe und Qualität der Miniaturansichten durch Änderungen in der Windows-Registrierung angepasst werden können, um eine bessere Sichtung zu ermöglichen.





@echo off
:: Dieses Skript soll dabei helfen, durch eine Sichtung alle Trennblätter umzuwandeln. So können diese später beim Import in Owiscan 100% erkannt werden, und es vermischen sich keine Dateien miteinander.
:: Zusätzlich soll bei der Sichtung im Verzeichnis durch die Unterstützung der Windows-Miniaturansicht (Ansicht: Extra große Symbole) überprüft werden, ob Dokumente fehlerhaft gescannt wurden.
:: In der Ansicht lässt sich überprüfen, ob Dokumente richtig herum gescannt wurden, ob kleinere Dokumente nicht gleichzeitig mit großen gescannt wurden, ob Farbbilder nicht fälschlicherweise als S/W-Bilder gescannt wurden oder ob Dokumente gerade gescannt sind. Das Wichtigste ist jedoch: Hier lässt sich schnell überprüfen, ob wirklich alle Seiten gescannt wurden.
:: Der Ansichtsmodus lässt sich sonst auch durch die Windows-Skalierung vergrößern. Möchte man in der 100%-Skalierung arbeiten, ist es auch möglich, mit einem Regedit-Befehl den DWORD-Wert zu ändern: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer. Dort können Sie den DWORD-Wert "ThumbnailSize" ändern. Geben Sie hier die Größe in Pixeln an. Der Wert kann zwischen 32 und 256 liegen und beträgt standardmäßig 100 Pixel.
:: Weiterhin gibt es den Wert "Thumbnailquality" als Datentyp REG_DWORD. Geben Sie hier die Qualität in Prozent an. Der Wert kann zwischen 50 und 100 liegen und steht standardmäßig auf 90 Prozent. Beide Änderungen funktionieren nur mit passenden Zugriffsrechten.


setlocal
:: Begrenzt die Gültigkeit der Variablen auf dieses Skript, um die Umgebung nicht zu beeinträchtigen.

:: ################### Pfade und Dateinamen definieren ###################

:: Ermittelt den aktuellen Arbeitsordner, in dem sich das Skript befindet.
set currentDir=%~dp0
:: Entfernt den abschließenden Backslash, um den Pfad später sauber kombinieren zu können.
set currentDir=%currentDir:~0,-1%

:: Definiert den Pfad zur Standard-Trennblattdatei.
set sourceFile=%currentDir%\_grunddaten\1000.tif
:: Definiert das Verzeichnis, in dem die Verarbeitung stattfindet (das ist das aktuelle Skript-Verzeichnis).
set targetDir=%currentDir%
:: Definiert das Zielverzeichnis für die verarbeiteten Dateien (eine Ebene höher).
set destDir=%currentDir%\..
:: Definiert den Pfad für die Protokolldatei im CSV-Format.
set logFile=%currentDir%\process_log.csv
:: Definiert das Verzeichnis für alle Backups.
set backupDir=%currentDir%\BackupTrennblatt

:: ################### Zeitstempel erstellen ###################

:: Ermittelt das aktuelle Datum und die aktuelle Uhrzeit aus den Systemvariablen.
set day=%date:~0,2%
set month=%date:~3,2%
set year=%date:~6,2%
set hour=%time:~0,2%
set minute=%time:~3,2%

:: Korrigiert die Stunden-Variable, falls sie nur eine Ziffer hat (z. B. " 8" wird zu "08").
if "%hour:~0,1%"==" " set hour=0%hour:~1,1%

:: Kombiniert die Datumsteile zu einem einheitlichen Zeitstempel im Format JJ-MM-TT-HHMM.
set timestamp=%year%-%month%-%day%-%hour%%minute%

:: ################### Verzeichnisse und Log vorbereiten ###################

:: Überprüft, ob die Log-Datei bereits existiert.
if not exist "%logFile%" (
    :: Wenn sie nicht existiert, wird eine neue Datei erstellt und eine Kopfzeile hinzugefügt.
    echo Timestamp,Action,FilePath > "%logFile%"
)

:: Überprüft, ob das Haupt-Backup-Verzeichnis existiert.
if not exist "%backupDir%" (
    echo Erstelle Backup-Verzeichnis: %backupDir%
    :: Erstellt das Verzeichnis, falls es fehlt.
    mkdir "%backupDir%"
)

:: Definiert den vollständigen Pfad für das aktuelle Backup-Verzeichnis mit Zeitstempel.
set backupSubDir=%backupDir%\%timestamp%

:: Erstellt das Backup-Verzeichnis für den aktuellen Durchlauf.
mkdir "%backupSubDir%"

:: ################### Fehlerprüfung ###################

:: Überprüft, ob die Quelldatei existiert. Wenn nicht, wird eine Fehlermeldung ins Log geschrieben und das Skript beendet.
if not exist "%sourceFile%" (
    echo [%timestamp%],Error,Die Quelldatei %sourceFile% existiert nicht. >> "%logFile%"
    goto end
)

:: Überprüft, ob das Zielverzeichnis existiert. Wenn nicht, wird eine Fehlermeldung ins Log geschrieben und das Skript beendet.
if not exist "%destDir%" (
    echo [%timestamp%],Error,Das Zielverzeichnis %destDir% existiert nicht. >> "%logFile%"
    goto end
)

:: ################### Haupt-Verarbeitungsschleife ###################

:: Durchläuft alle .tif-Dateien im aktuellen Verzeichnis (%targetDir%).
for %%f in ("%targetDir%\*.tif") do (
    :: Fügt einen Eintrag für die Sicherung ins Protokoll hinzu.
    echo [%timestamp%],Backup,%%f >> "%logFile%"
    :: Sichert die aktuelle Datei im zeitgestempelten Backup-Ordner.
    copy "%%f" "%backupSubDir%\%%~nxf"
    
    :: Führt einen binären Vergleich zwischen der Quelldatei und der aktuellen Datei durch.
    :: Die Ausgabe wird auf "nul" umgeleitet, sodass sie nicht in der Konsole angezeigt wird.
    fc /b "%sourceFile%" "%%f" > nul
    
    :: Der Befehl "if errorlevel 1" prüft, ob der vorherige Befehl (fc) mit einem Fehlercode 1 beendet wurde.
    :: Das bedeutet, die Dateien sind NICHT identisch.
    if errorlevel 1 (
        :: Kopiert die Quelldatei über die aktuelle Datei. "/Y" unterdrückt die Überschreib-Warnung.
        copy /Y "%sourceFile%" "%%f"
        :: Fügt einen Eintrag für die Kopie ins Protokoll hinzu.
        echo [%timestamp%],Copy,%%f >> "%logFile%"
    ) else (
        :: Wenn die Dateien identisch sind, wird das in das Protokoll geschrieben.
        echo [%timestamp%],NoChange,%%f >> "%logFile%"
    )
)

:: ################### Verschieben der Dateien ###################

:: Startet eine zweite Schleife, um alle verarbeiteten .tif-Dateien zu verschieben.
for %%f in ("%targetDir%\*.tif") do (
    :: Verschiebt die aktuelle Datei ins Zielverzeichnis (eine Ebene höher).
    move "%%f" "%destDir%"
    :: Fügt einen Eintrag für die Verschiebung ins Protokoll hinzu.
    echo [%timestamp%],Move,%%f >> "%logFile%"
)

:: ################### Abschluss ###################

:: Fügt eine Erfolgsmeldung in die Protokolldatei hinzu.
echo [%timestamp%],Success,Alle .tif Dateien im Verzeichnis %targetDir% wurden erfolgreich ersetzt und verschoben. >> "%logFile%"

:end
:: Das Ende-Label, zu dem das Skript springt, wenn ein kritischer Fehler auftritt.
endlocal
:: Beendet die Gültigkeit von "setlocal" und stellt die ursprüngliche Umgebung wieder her.
