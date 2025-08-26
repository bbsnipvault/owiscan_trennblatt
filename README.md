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


