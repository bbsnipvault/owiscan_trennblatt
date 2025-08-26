@echo off
setlocal
:: Das Script soll dabei helfen nochmals durch eine Sichtung alle Trennblätter umzuwandeln. Damit diese später beim Import in Owiscan 100% erkannt werden und keine Datein sich miteiander vermischen.
:: Zusätzlich soll bei der Sichtung im Verzeichniss durch die Unterstzung von Windows Miniaturansicht (Ansicht-Extra große Symbole) überprüft werden ob Dokumente nicht Fehlerhaft gescannt wurden. 
:: In der Anscicht lässt sich überprüfen ob: Dokumente richtig herum gescannt wurden, kleinere Dokoumente nicht mit großen gleichzeitig gescannt wurden, Farbbilder nicht fäschlicherweiße als S/W Bilder gescannt wurden, Dokumente gerade gescannt wurden. Mitunter das wichtigste: Hier lässt sich schnell überprüfen ob alle Seiten wirklich gescannt wurden. 
:: Dieser Ansicht Modus lässt sich sonst durch die Windows Skalierung größer machen. Möchte man in der 100% Skalierung arbeiten ist es auch möglich durch einen regedit Befehl: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer. Dort den DWORD-Wert verändern: ThumbnailSize 
:: Erstellen Sie hier einen neuen Wert mit dem Namen "ThumbnailSize" als Datentyp REG_DWORD. Geben Sie hier die Größe in Pixel an. Der Wert kann zwischen 32 und 256 verändert werden und liegt Standardmäßig bei 100 Pixel.
:: Weiterhin gibt es noch den einen Wert mit den Namen "Thumbnailquality" als Datentyp REG_DWORD. Geben Sie hier die Qualität in Prozent an. Der Wert kann zwischen 50 und 100 liegen und steht Standardmäßig auf 90 Prozent. Beides funktioniert nur mit passenden Zugriffsrechten.
 
:: Aktuellen Arbeitsordner ermitteln
set currentDir=%~dp0
set currentDir=%currentDir:~0,-1%

:: Quelle Datei im Unterordner _grunddaten suchen
set sourceFile=%currentDir%\_grunddaten\1000.tif
set targetDir=%currentDir%
set destDir=%currentDir%\..
set logFile=%currentDir%\process_log.csv
set backupDir=%currentDir%\BackupTrennblatt

:: Aktuelles Datum und Uhrzeit für Zeitstempel im gewünschten Format (inkl. Minuten)
set day=%date:~0,2%
set month=%date:~3,2%
set year=%date:~6,2%
set hour=%time:~0,2%
set minute=%time:~3,2%

:: Falls die Stunde nur einstellig ist (z. B. 08 anstatt 08:00), korrigiere sie
if "%hour:~0,1%"==" " set hour=0%hour:~1,1%

:: Zeitstempel für das Log und Ordner im Format [YYYY-MM-DD-HHMM] erstellen
set timestamp=%year%-%month%-%day%,%hour%%minute%

:: Log-Datei im CSV-Format mit Header erstellen
if not exist "%logFile%" (
    echo Timestamp,Action,FilePath > "%logFile%"
)

:: Backup-Verzeichnis erstellen, falls es nicht existiert
if not exist "%backupDir%" (
    echo Erstelle Backup-Verzeichnis: %backupDir%
    mkdir "%backupDir%"
)

:: Neues Verzeichnis für das Backup mit Datum und Uhrzeit erstellen
set backupSubDir=%backupDir%\%timestamp%

:: Backup-Verzeichnis für den aktuellen Zeitstempel erstellen
mkdir "%backupSubDir%"

:: Überprüfen, ob die Quelldatei existiert
if not exist "%sourceFile%" (
    echo [%timestamp%],Error,Die Quelldatei %sourceFile% existiert nicht. >> "%logFile%"
    goto end
)

:: Überprüfen, ob das Zielverzeichnis existiert
if not exist "%destDir%" (
    echo [%timestamp%],Error,Das Zielverzeichnis %destDir% existiert nicht. >> "%logFile%"
    goto end
)

:: Schleife durch alle .tif Dateien im aktuellen Verzeichnis und ersetze sie
for %%f in ("%targetDir%\*.tif") do (
    :: Sichern der Datei im Backup-Ordner mit Zeitstempel im Unterverzeichnis
    echo [%timestamp%],Backup,%%f >> "%logFile%"
    copy "%%f" "%backupSubDir%\%%~nxf"
    
    :: Überprüfen, ob die Datei schon existiert und identisch ist
    fc /b "%sourceFile%" "%%f" > nul
    if errorlevel 1 (
        copy /Y "%sourceFile%" "%%f"
        echo [%timestamp%],Copy,%%f >> "%logFile%"
    ) else (
        echo [%timestamp%],NoChange,%%f >> "%logFile%"
    )
)

:: Verschiebe die ersetzten .tif Dateien ins Zielverzeichnis eine Ebene höher
for %%f in ("%targetDir%\*.tif") do (
    move "%%f" "%destDir%"
    echo [%timestamp%],Move,%%f >> "%logFile%"
)

echo [%timestamp%],Success,Alle .tif Dateien im Verzeichnis %targetDir% wurden erfolgreich ersetzt und verschoben. >> "%logFile%"

:end
endlocal
