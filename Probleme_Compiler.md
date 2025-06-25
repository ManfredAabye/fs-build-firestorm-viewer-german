# Der Fehler hier ist ziemlich klar

```bat
error MSB4126: Die angegebene Projektmappenkonfiguration "%CONFIG%|x64" ist ungültig.
```

Das bedeutet, dass in deinem Build-Befehl die Variable `%CONFIG%` **nicht ersetzt** wurde und deshalb MSBuild versucht, mit der Konfiguration **wörtlich** `%CONFIG%` zu bauen, was natürlich nicht existiert.

---

## Was ist zu tun?

Du musst beim Aufruf von MSBuild oder deinem Build-Skript sicherstellen, dass `%CONFIG%` durch einen gültigen Konfigurationsnamen ersetzt wird, z.B. `Release` oder `Debug`.

Zum Beispiel:

Funktionierte nicht.

```bat
msbuild Firestorm.sln /p:Configuration=Release /p:Platform=x64
```

oder

Das hatte ich verwendet und es funktionierte.

```bat
msbuild Firestorm.sln /p:Configuration=Debug /p:Platform=x64
```

---

### Warum passiert das?

Wenn du den Build-Aufruf mit

```bat
msbuild Firestorm.sln /p:Configuration=%CONFIG% /p:Platform=x64
```

startest, aber die Umgebungsvariable `%CONFIG%` nicht gesetzt ist, bleibt `%CONFIG%` genau so stehen — MSBuild kennt das nicht und gibt den Fehler.

---

### Lösungsschritte

1.**Prüfe deine Build-Umgebung:**

* Wie setzt du `%CONFIG%`?
* Ist das in der aktuellen Shell/Batch-Skript tatsächlich definiert?

2.**Direkt harte Werte testen:**

Starte mal explizit (im Command Prompt oder PowerShell):

```bat
msbuild Firestorm.sln /p:Configuration=Release /p:Platform=x64 /verbosity:detailed
```

Damit kannst du sehen, ob der Build prinzipiell klappt.

3.**Build-Skript anpassen:**

Falls du ein Batch- oder Shell-Skript verwendest, das `%CONFIG%` nutzen soll, setze vorher:

```bat
set CONFIG=Release
```

oder gib den Wert direkt in den Befehl ein.

---

### Zusammenfassung

Der Build bricht ab, weil `%CONFIG%` nicht gesetzt wurde. Setze die Konfiguration explizit auf `Release` oder `Debug` — dann sollte MSBuild die Projektmappenkonfiguration finden und bauen können.

---

Wenn du möchtest, helfe ich dir gern beim Erstellen eines passenden Build-Befehls oder Skripts!
