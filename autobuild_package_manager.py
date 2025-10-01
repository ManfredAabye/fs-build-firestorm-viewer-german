#!/usr/bin/env python3
"""
Autobuild Package Manager
Ein GUI-Tool zum Verwalten von Paketen in autobuild XML-Dateien
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import xml.etree.ElementTree as ET
import os
import shutil
import json
from datetime import datetime

class Internationalization:
    """Klasse für Mehrsprachigkeit"""
    
    def __init__(self):
        self.current_language = "de"  # Standard: Deutsch
        self.translations = {
            "de": {
                # Fenster und Basis
                "window_title": "Autobuild Package Manager",
                "ready": "Bereit",
                
                # Datei-Bereich
                "xml_file": "XML-Datei:",
                "no_file_loaded": "Keine Datei geladen",
                "open_file": "Datei öffnen",
                "save_file": "Datei speichern",
                "export_overview": "Übersicht exportieren",
                "create_backup": "Backup erstellen",
                
                # Spaltenüberschriften
                "package_id": "Paket-ID",
                "name": "Name",
                "version": "Version",
                "platforms": "Plattformen",
                "license": "Lizenz",
                
                # Buttons
                "remove_selected": "Ausgewählte Pakete entfernen",
                "remove_linux": "Alle Linux-Plattformen entfernen",
                "remove_darwin": "Alle Darwin-Plattformen entfernen",
                "refresh": "Aktualisieren",
                "language": "Sprache:",
                
                # Dialoge und Nachrichten
                "warning": "Warnung",
                "error": "Fehler",
                "success": "Erfolg",
                "information": "Information",
                "file_saved": "Datei gespeichert",
                "backup_created": "Backup erstellt",
                "overview_exported": "Übersicht exportiert",
                
                # Fehlermeldungen
                "no_packages_selected": "Keine Pakete ausgewählt. Bitte wählen Sie mindestens ein Paket aus.",
                "no_xml_loaded": "Keine XML-Datei geladen.",
                "no_package_selected_remove": "Bitte wählen Sie ein Paket zum Entfernen aus.",
                "no_file_to_save": "Keine Datei zum Speichern geladen.",
                
                # Bestätigungen
                "confirm_remove_package": "Möchten Sie das Paket '{0}' wirklich entfernen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.",
                "confirm_remove_linux": "Möchten Sie alle Linux-Plattformen (linux64 und linux) aus allen Paketen entfernen?\n\nDies entfernt sowohl 64-bit als auch veraltete 32-bit Linux-Einträge.\nDiese Aktion kann nicht rückgängig gemacht werden.",
                "confirm_remove_darwin": "Möchten Sie alle Darwin-Plattformen (darwin64 und darwin) aus allen Paketen entfernen?\n\nDies entfernt sowohl 64-bit als auch veraltete 32-bit Darwin-Einträge.\nDiese Aktion kann nicht rückgängig gemacht werden.",
                
                # Export-Texte
                "overview_title": "AUTOBUILD PACKAGE OVERVIEW",
                "source_xml": "Quell-XML",
                "selected_packages_count": "Anzahl ausgewählter Pakete",
                "package": "PAKET",
                "description": "Beschreibung",
                "copyright": "Copyright",
                "platform_details": "Plattform-Details",
                "archive_path": "Archive-Pfad",
                "hash": "Hash",
                "url": "URL",
                "not_available": "Nicht verfügbar",
                
                # Status-Nachrichten
                "packages_removed": "{0} Linux-Plattformen entfernt",
                "darwin_removed": "{0} Darwin-Plattformen entfernt",
                "no_linux_found": "Keine Linux-Plattformen gefunden",
                "no_darwin_found": "Keine Darwin-Plattformen gefunden",
                "package_removed": "Paket '{0}' entfernt",
                "selection_status_none": "Keine Pakete ausgewählt ({0} verfügbar)",
                "selection_status_all": "Alle {0} Pakete ausgewählt",
                "selection_status_partial": "{0} von {1} Paketen ausgewählt"
            },
            "en": {
                # Window and basics
                "window_title": "Autobuild Package Manager",
                "ready": "Ready",
                
                # File area
                "xml_file": "XML File:",
                "no_file_loaded": "No file loaded",
                "open_file": "Open File",
                "save_file": "Save File",
                "export_overview": "Export Overview",
                "create_backup": "Create Backup",
                
                # Column headers
                "package_id": "Package ID",
                "name": "Name",
                "version": "Version",
                "platforms": "Platforms",
                "license": "License",
                
                # Buttons
                "remove_selected": "Remove Selected Packages",
                "remove_linux": "Remove All Linux Platforms",
                "remove_darwin": "Remove All Darwin Platforms",
                "refresh": "Refresh",
                "language": "Language:",
                
                # Dialogs and messages
                "warning": "Warning",
                "error": "Error",
                "success": "Success",
                "information": "Information",
                "file_saved": "File saved",
                "backup_created": "Backup created",
                "overview_exported": "Overview exported",
                
                # Error messages
                "no_packages_selected": "No packages selected. Please select at least one package.",
                "no_xml_loaded": "No XML file loaded.",
                "no_package_selected_remove": "Please select a package to remove.",
                "no_file_to_save": "No file loaded to save.",
                
                # Confirmations
                "confirm_remove_package": "Do you really want to remove package '{0}'?\n\nThis action cannot be undone.",
                "confirm_remove_linux": "Do you want to remove all Linux platforms (linux64 and linux) from all packages?\n\nThis removes both 64-bit and legacy 32-bit Linux entries.\nThis action cannot be undone.",
                "confirm_remove_darwin": "Do you want to remove all Darwin platforms (darwin64 and darwin) from all packages?\n\nThis removes both 64-bit and legacy 32-bit Darwin entries.\nThis action cannot be undone.",
                
                # Export texts
                "overview_title": "AUTOBUILD PACKAGE OVERVIEW",
                "source_xml": "Source XML",
                "selected_packages_count": "Number of selected packages",
                "package": "PACKAGE",
                "description": "Description",
                "copyright": "Copyright",
                "platform_details": "Platform Details",
                "archive_path": "Archive Path",
                "hash": "Hash",
                "url": "URL",
                "not_available": "Not available",
                
                # Status messages
                "packages_removed": "{0} Linux platforms removed",
                "darwin_removed": "{0} Darwin platforms removed",
                "no_linux_found": "No Linux platforms found",
                "no_darwin_found": "No Darwin platforms found",
                "package_removed": "Package '{0}' removed",
                "selection_status_none": "No packages selected ({0} available)",
                "selection_status_all": "All {0} packages selected",
                "selection_status_partial": "{0} of {1} packages selected"
            },
            "fr": {
                # Fenêtre et éléments de base
                "window_title": "Gestionnaire de Packages Autobuild",
                "ready": "Prêt",
                
                # Zone de fichier
                "xml_file": "Fichier XML:",
                "no_file_loaded": "Aucun fichier chargé",
                "open_file": "Ouvrir Fichier",
                "save_file": "Sauvegarder Fichier",
                "export_overview": "Exporter Aperçu",
                "create_backup": "Créer Sauvegarde",
                
                # En-têtes de colonnes
                "package_id": "ID Package",
                "name": "Nom",
                "version": "Version",
                "platforms": "Plateformes",
                "license": "Licence",
                
                # Boutons
                "remove_selected": "Supprimer Packages Sélectionnés",
                "remove_linux": "Supprimer Toutes Plateformes Linux",
                "remove_darwin": "Supprimer Toutes Plateformes Darwin",
                "refresh": "Actualiser",
                "language": "Langue:",
                
                # Dialogues et messages
                "warning": "Avertissement",
                "error": "Erreur",
                "success": "Succès",
                "information": "Information",
                "file_saved": "Fichier sauvegardé",
                "backup_created": "Sauvegarde créée",
                "overview_exported": "Aperçu exporté",
                
                # Messages d'erreur
                "no_packages_selected": "Aucun package sélectionné. Veuillez sélectionner au moins un package.",
                "no_xml_loaded": "Aucun fichier XML chargé.",
                "no_package_selected_remove": "Veuillez sélectionner un package à supprimer.",
                "no_file_to_save": "Aucun fichier chargé à sauvegarder.",
                
                # Confirmations
                "confirm_remove_package": "Voulez-vous vraiment supprimer le package '{0}'?\n\nCette action ne peut pas être annulée.",
                "confirm_remove_linux": "Voulez-vous supprimer toutes les plateformes Linux (linux64 et linux) de tous les packages?\n\nCela supprime les entrées Linux 64-bit et 32-bit obsolètes.\nCette action ne peut pas être annulée.",
                "confirm_remove_darwin": "Voulez-vous supprimer toutes les plateformes Darwin (darwin64 et darwin) de tous les packages?\n\nCela supprime les entrées Darwin 64-bit et 32-bit obsolètes.\nCette action ne peut pas être annulée.",
                
                # Textes d'export
                "overview_title": "APERÇU DES PACKAGES AUTOBUILD",
                "source_xml": "XML Source",
                "selected_packages_count": "Nombre de packages sélectionnés",
                "package": "PACKAGE",
                "description": "Description",
                "copyright": "Copyright",
                "platform_details": "Détails de Plateforme",
                "archive_path": "Chemin d'Archive",
                "hash": "Hash",
                "url": "URL",
                "not_available": "Non disponible",
                
                # Messages de statut
                "packages_removed": "{0} plateformes Linux supprimées",
                "darwin_removed": "{0} plateformes Darwin supprimées",
                "no_linux_found": "Aucune plateforme Linux trouvée",
                "no_darwin_found": "Aucune plateforme Darwin trouvée",
                "package_removed": "Package '{0}' supprimé",
                "selection_status_none": "Aucun package sélectionné ({0} disponibles)",
                "selection_status_all": "Tous les {0} packages sélectionnés",
                "selection_status_partial": "{0} sur {1} packages sélectionnés"
            },
            "es": {
                # Ventana y elementos básicos
                "window_title": "Gestor de Paquetes Autobuild",
                "ready": "Listo",
                
                # Área de archivo
                "xml_file": "Archivo XML:",
                "no_file_loaded": "Ningún archivo cargado",
                "open_file": "Abrir Archivo",
                "save_file": "Guardar Archivo",
                "export_overview": "Exportar Vista General",
                "create_backup": "Crear Respaldo",
                
                # Encabezados de columna
                "package_id": "ID Paquete",
                "name": "Nombre",
                "version": "Versión",
                "platforms": "Plataformas",
                "license": "Licencia",
                
                # Botones
                "remove_selected": "Eliminar Paquetes Seleccionados",
                "remove_linux": "Eliminar Todas Plataformas Linux",
                "remove_darwin": "Eliminar Todas Plataformas Darwin",
                "refresh": "Actualizar",
                "language": "Idioma:",
                
                # Diálogos y mensajes
                "warning": "Advertencia",
                "error": "Error",
                "success": "Éxito",
                "information": "Información",
                "file_saved": "Archivo guardado",
                "backup_created": "Respaldo creado",
                "overview_exported": "Vista general exportada",
                
                # Mensajes de error
                "no_packages_selected": "Ningún paquete seleccionado. Por favor seleccione al menos un paquete.",
                "no_xml_loaded": "Ningún archivo XML cargado.",
                "no_package_selected_remove": "Por favor seleccione un paquete para eliminar.",
                "no_file_to_save": "Ningún archivo cargado para guardar.",
                
                # Confirmaciones
                "confirm_remove_package": "¿Realmente desea eliminar el paquete '{0}'?\n\nEsta acción no se puede deshacer.",
                "confirm_remove_linux": "¿Desea eliminar todas las plataformas Linux (linux64 y linux) de todos los paquetes?\n\nEsto elimina entradas Linux de 64-bit y 32-bit obsoletas.\nEsta acción no se puede deshacer.",
                "confirm_remove_darwin": "¿Desea eliminar todas las plataformas Darwin (darwin64 y darwin) de todos los paquetes?\n\nEsto elimina entradas Darwin de 64-bit y 32-bit obsoletas.\nEsta acción no se puede deshacer.",
                
                # Textos de exportación
                "overview_title": "VISTA GENERAL DE PAQUETES AUTOBUILD",
                "source_xml": "XML Fuente",
                "selected_packages_count": "Número de paquetes seleccionados",
                "package": "PAQUETE",
                "description": "Descripción",
                "copyright": "Copyright",
                "platform_details": "Detalles de Plataforma",
                "archive_path": "Ruta de Archivo",
                "hash": "Hash",
                "url": "URL",
                "not_available": "No disponible",
                
                # Mensajes de estado
                "packages_removed": "{0} plataformas Linux eliminadas",
                "darwin_removed": "{0} plataformas Darwin eliminadas",
                "no_linux_found": "No se encontraron plataformas Linux",
                "no_darwin_found": "No se encontraron plataformas Darwin",
                "package_removed": "Paquete '{0}' eliminado",
                "selection_status_none": "Ningún paquete seleccionado ({0} disponibles)",
                "selection_status_all": "Todos los {0} paquetes seleccionados",
                "selection_status_partial": "{0} de {1} paquetes seleccionados"
            }
        }
    
    def set_language(self, language_code):
        """Sprache ändern"""
        if language_code in self.translations:
            self.current_language = language_code
    
    def get_text(self, key, *args):
        """Lokalisierten Text abrufen"""
        text = self.translations.get(self.current_language, {}).get(key, key)
        if not text:
            text = key  # Fallback zum Schlüssel
        if args and text:
            try:
                text = text.format(*args)
            except Exception:
                pass
        return text
    
    def get_languages(self):
        """Verfügbare Sprachen zurückgeben"""
        return {
            "de": "Deutsch",
            "en": "English", 
            "fr": "Français",
            "es": "Español"
        }

class AutobuildPackageManager:
    def __init__(self, root):
        self.root = root
        
        # Internationalisierung initialisieren
        self.i18n = Internationalization()
        
        self.root.title(self.i18n.get_text("window_title"))
        self.root.geometry("850x700")
        
        # Icon setzen
        self.setup_icon()
        
        # Stil und Farben konfigurieren
        self.setup_styles()
        
        # Aktueller XML-Pfad
        self.xml_file = None
        self.xml_tree = None
        self.packages = {}
        self.selected_packages = set()  # Set für ausgewählte Pakete
        
        self.setup_ui()
        
        # Automatisch die lokale XML-Datei laden
        default_xml = os.path.join(os.path.dirname(__file__), "autobuild.xml")
        if os.path.exists(default_xml):
            self.load_xml_file(default_xml)
    
    def setup_icon(self):
        """Setzt das Fenster-Icon"""
        try:
            # Icon-Pfad im gleichen Verzeichnis wie das Skript
            icon_path = os.path.join(os.path.dirname(__file__), "icon.png")
            
            if os.path.exists(icon_path):
                # PNG in PhotoImage konvertieren (tkinter unterstützt nur GIF, PPM/PGM und einige andere)
                # Für PNG brauchen wir PIL, falls nicht verfügbar verwenden wir das Standard-Icon
                try:
                    from PIL import Image, ImageTk
                    # PNG laden und skalieren falls nötig
                    pil_image = Image.open(icon_path)
                    # Für Fenster-Icon auf kleinere Größe skalieren (typisch 32x32 oder 48x48)
                    pil_image = pil_image.resize((48, 48), Image.Resampling.LANCZOS)
                    photo = ImageTk.PhotoImage(pil_image)
                    self.root.iconphoto(True, photo)
                    # Referenz behalten damit das Bild nicht von Garbage Collector gelöscht wird
                    self.icon_photo = photo
                except ImportError:
                    # PIL nicht verfügbar, versuche direktes Laden (funktioniert nur bei unterstützten Formaten)
                    try:
                        photo = tk.PhotoImage(file=icon_path)
                        self.root.iconphoto(True, photo)
                        self.icon_photo = photo
                    except tk.TclError:
                        # PNG wird ohne PIL nicht unterstützt, verwende Standard-Icon
                        pass
            
        except Exception as e:
            # Bei Fehlern einfach das Standard-Icon verwenden
            print(f"Warnung: Icon konnte nicht geladen werden: {e}")
    
    def setup_styles(self):
        """Konfiguriert Stil und Farben der Anwendung"""
        # Hintergrundfarbe für das Hauptfenster
        self.root.configure(bg='#f0f0f0')  # Leicht grauer Hintergrund
        
        # TTK Style konfigurieren
        self.style = ttk.Style()
        
        # Theme explizit setzen für bessere Kontrolle
        try:
            # Verwende ein Theme das wir gut kontrollieren können
            if "clam" in self.style.theme_names():
                self.style.theme_use("clam")
            else:
                self.style.theme_use("default")
        except Exception:
            pass
        
        # Benutzerdefinierte Stile für blaue Buttons
        self.style.configure('Blue.TButton',
                           background='#0078d4',  # Microsoft Blue
                           foreground='white',
                           borderwidth=1,
                           relief='flat',
                           focuscolor='none',
                           font=('Segoe UI', 9))
        
        self.style.map('Blue.TButton',
                     background=[('active', '#106ebe'),    # Dunkleres Blau beim Hover
                               ('pressed', '#005a9e'),     # Noch dunkler beim Klick
                               ('disabled', '#cccccc')],   # Grau wenn deaktiviert
                     foreground=[('active', 'white'),
                               ('pressed', 'white'),
                               ('disabled', '#666666')],
                     relief=[('pressed', 'sunken'),
                           ('!pressed', 'flat')])
        
        # Accent Button (für wichtige Aktionen)
        self.style.configure('Accent.TButton',
                           background='#d83b01',  # Orange-Rot für Warnung/Wichtig
                           foreground='white',
                           borderwidth=1,
                           relief='flat',
                           focuscolor='none',
                           font=('Segoe UI', 9, 'bold'))
        
        self.style.map('Accent.TButton',
                     background=[('active', '#c73a00'),
                               ('pressed', '#a73000'),
                               ('disabled', '#cccccc')],
                     foreground=[('active', 'white'),
                               ('pressed', 'white'),
                               ('disabled', '#666666')],
                     relief=[('pressed', 'sunken'),
                           ('!pressed', 'flat')])
        
        # Frame-Hintergrund anpassen
        self.style.configure('TFrame', background='#f0f0f0')
        self.style.configure('TLabel', background='#f0f0f0', font=('Segoe UI', 9))
        
        # Treeview-Stil anpassen
        self.style.configure('Treeview', background='#f8f8f8',  # Hellgrau als Standard
                           fieldbackground='#f8f8f8', font=('Segoe UI', 9),
                           rowheight=22)  # Etwas höhere Zeilen für bessere Lesbarkeit
        self.style.configure('Treeview.Heading', background='#d4d4d4', 
                           font=('Segoe UI', 9, 'bold'), relief='flat')
        
        # Alternierende Zeilenhintergründe (Zebra-Streifen)
        self.style.map('Treeview', 
                     background=[('selected', '#0078d4'), ('focus', '#0078d4')],
                     foreground=[('selected', 'white'), ('focus', 'white')])
        
        # Tags für alternierende Zeilen konfigurieren
        # Diese werden in refresh_packages() verwendet
    
    def setup_ui(self):
        """Benutzeroberfläche erstellen"""
        
        # Hauptframe
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky="nsew")
        
        # Sprach-Auswahl Frame (oben)
        language_frame = ttk.Frame(main_frame)
        language_frame.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 10))
        
        ttk.Label(language_frame, text=self.i18n.get_text("language")).grid(row=0, column=0, sticky=tk.W)
        
        self.language_var = tk.StringVar()
        language_combo = ttk.Combobox(language_frame, textvariable=self.language_var, 
                                     values=list(self.i18n.get_languages().values()),
                                     state="readonly", width=15)
        language_combo.grid(row=0, column=1, sticky=tk.W, padx=(5, 0))
        language_combo.bind("<<ComboboxSelected>>", self.on_language_change)
        
        # Standardsprache setzen
        current_lang_name = self.i18n.get_languages()[self.i18n.current_language]
        self.language_var.set(current_lang_name)
        
        # Datei-Auswahl Frame
        file_frame = ttk.Frame(main_frame)
        file_frame.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(0, 10))
        
        self.xml_label = ttk.Label(file_frame, text=self.i18n.get_text("xml_file"))
        self.xml_label.grid(row=0, column=0, sticky=tk.W)
        
        self.file_label = ttk.Label(file_frame, text=self.i18n.get_text("no_file_loaded"), foreground="red")
        self.file_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        self.open_button = ttk.Button(file_frame, text=self.i18n.get_text("open_file"), 
                                     command=self.open_file, style="Blue.TButton")
        self.open_button.grid(row=0, column=2, padx=(10, 0))
        
        self.save_button = ttk.Button(file_frame, text=self.i18n.get_text("save_file"), 
                                     command=self.save_file, style="Blue.TButton")
        self.save_button.grid(row=0, column=3, padx=(5, 0))
        
        self.export_button = ttk.Button(file_frame, text=self.i18n.get_text("export_overview"), 
                                       command=self.export_package_overview, style="Blue.TButton")
        self.export_button.grid(row=0, column=4, padx=(5, 0))
        
        self.backup_button = ttk.Button(file_frame, text=self.i18n.get_text("create_backup"), 
                                       command=self.create_backup, style="Blue.TButton")
        self.backup_button.grid(row=0, column=5, padx=(5, 0))
        
        # Paket-Liste Frame
        list_frame = ttk.Frame(main_frame)
        list_frame.grid(row=2, column=0, columnspan=2, sticky="nsew", pady=(0, 10))
        
        # Treeview für Paketliste mit Checkboxen
        columns = ("Selected", "Name", "Version", "Plattformen", "Lizenz")
        self.tree = ttk.Treeview(list_frame, columns=columns, show="tree headings", height=15)
        
        # Spaltenüberschriften
        self.tree.heading("#0", text=self.i18n.get_text("package_id"))
        self.tree.heading("Selected", text="☐", command=self.toggle_all_selection)
        self.tree.heading("Name", text=self.i18n.get_text("name"))
        self.tree.heading("Version", text=self.i18n.get_text("version"))
        self.tree.heading("Plattformen", text=self.i18n.get_text("platforms"))
        self.tree.heading("Lizenz", text=self.i18n.get_text("license"))
        
        # Spaltenbreiten
        self.tree.column("#0", width=180, minwidth=120)
        self.tree.column("Selected", width=40, minwidth=40, anchor="center")
        self.tree.column("Name", width=130, minwidth=80)
        self.tree.column("Version", width=90, minwidth=70)
        self.tree.column("Plattformen", width=180, minwidth=120)
        self.tree.column("Lizenz", width=120, minwidth=80)
        
        # Event-Bindings für Checkbox-Klicks
        self.tree.bind("<Button-1>", self.on_item_click)
        self.tree.bind("<Double-1>", self.on_item_double_click)
        
        # Scrollbar für Treeview
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscrollcommand=scrollbar.set)
        
        self.tree.grid(row=0, column=0, sticky="nsew")
        scrollbar.grid(row=0, column=1, sticky="ns")
        
        # Button Frame
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=3, column=0, columnspan=2, sticky="ew")
        
        self.remove_button = ttk.Button(button_frame, text=self.i18n.get_text("remove_selected"), 
                  command=self.remove_selected_package, style="Accent.TButton")
        self.remove_button.grid(row=0, column=0, padx=(0, 10))
        
        self.linux_button = ttk.Button(button_frame, text=self.i18n.get_text("remove_linux"), 
                  command=self.remove_all_linux64, style="Blue.TButton")
        self.linux_button.grid(row=0, column=1, padx=(0, 10))
        
        self.darwin_button = ttk.Button(button_frame, text=self.i18n.get_text("remove_darwin"), 
                  command=self.remove_all_darwin64, style="Blue.TButton")
        self.darwin_button.grid(row=0, column=2, padx=(0, 10))
        
        self.refresh_button = ttk.Button(button_frame, text=self.i18n.get_text("refresh"), 
                  command=self.refresh_packages, style="Blue.TButton")
        self.refresh_button.grid(row=0, column=3)
        
        # Status Frame
        status_frame = ttk.Frame(main_frame)
        status_frame.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(10, 0))
        
        self.status_label = ttk.Label(status_frame, text=self.i18n.get_text("ready"))
        self.status_label.grid(row=0, column=0, sticky=tk.W)
        
        # Grid-Gewichtung für Responsive Design
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(2, weight=1)
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
    
    def on_language_change(self, event=None):
        """Sprache ändern"""
        # Finde den Sprachcode basierend auf dem ausgewählten Namen
        selected_name = self.language_var.get()
        for code, name in self.i18n.get_languages().items():
            if name == selected_name:
                self.i18n.set_language(code)
                break
        
        # UI aktualisieren
        self.update_ui_language()
        
        # Fenster-Titel aktualisieren
        self.root.title(self.i18n.get_text("window_title"))
    
    def update_ui_language(self):
        """UI-Elemente mit neuer Sprache aktualisieren"""
        # Labels aktualisieren
        self.xml_label.config(text=self.i18n.get_text("xml_file"))
        if hasattr(self, 'file_label') and self.xml_file is None:
            self.file_label.config(text=self.i18n.get_text("no_file_loaded"))
        
        # Buttons aktualisieren
        self.open_button.config(text=self.i18n.get_text("open_file"))
        self.save_button.config(text=self.i18n.get_text("save_file"))
        self.export_button.config(text=self.i18n.get_text("export_overview"))
        self.backup_button.config(text=self.i18n.get_text("create_backup"))
        self.remove_button.config(text=self.i18n.get_text("remove_selected"))
        self.linux_button.config(text=self.i18n.get_text("remove_linux"))
        self.darwin_button.config(text=self.i18n.get_text("remove_darwin"))
        self.refresh_button.config(text=self.i18n.get_text("refresh"))
        
        # Treeview-Überschriften aktualisieren
        self.tree.heading("#0", text=self.i18n.get_text("package_id"))
        self.tree.heading("Name", text=self.i18n.get_text("name"))
        self.tree.heading("Version", text=self.i18n.get_text("version"))
        self.tree.heading("Plattformen", text=self.i18n.get_text("platforms"))
        self.tree.heading("Lizenz", text=self.i18n.get_text("license"))
        
        # Status aktualisieren
        if hasattr(self, 'status_label'):
            self.update_selection_count()
    
    
    def open_file(self):
        """XML-Datei öffnen"""
        filename = filedialog.askopenfilename(
            title="Autobuild XML-Datei auswählen",
            filetypes=[("XML Dateien", "*.xml"), ("Alle Dateien", "*.*")]
        )
        if filename:
            self.load_xml_file(filename)
    
    def load_xml_file(self, filename):
        """XML-Datei laden und parsen"""
        try:
            self.xml_tree = ET.parse(filename)
            self.xml_file = filename
            self.file_label.config(text=os.path.basename(filename), foreground="green")
            self.selected_packages.clear()  # Auswahl zurücksetzen
            self.parse_packages()
            self.refresh_packages()
            self.update_selection_count()
        except ET.ParseError as e:
            messagebox.showerror("XML-Fehler", f"Fehler beim Parsen der XML-Datei:\n{str(e)}")
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Laden der Datei:\n{str(e)}")
    
    def parse_packages(self):
        """Pakete aus XML extrahieren"""
        self.packages = {}
        
        if not self.xml_tree:
            return
        
        root = self.xml_tree.getroot()
        
        # Robuste Suche nach installables
        installables_map = self.find_installables_map(root)
        if installables_map is None:
            return
        
        # Durchlaufe alle Installables
        current_key = None
        for child in installables_map:
            if child.tag == "key":
                current_key = child.text
            elif child.tag == "map" and current_key:
                package_info = self.parse_package_info(child)
                package_info["xml_element"] = child
                self.packages[current_key] = package_info
                current_key = None
    
    def find_installables_map(self, root):
        """Robuste Suche nach der installables-Map in der XML-Struktur"""
        # Methode 1: Direkte Suche in der Hauptmap
        if root.tag == 'llsd':
            main_map = root.find('map')
            if main_map is not None:
                current_key = None
                for child in main_map:
                    if child.tag == 'key':
                        current_key = child.text
                    elif child.tag == 'map' and current_key == 'installables':
                        return child
                    elif child.tag != 'map':
                        current_key = None
        
        # Methode 2: Rekursive Suche in allen Maps
        def search_recursive(element):
            if element.tag == 'map':
                current_key = None
                for child in element:
                    if child.tag == 'key':
                        current_key = child.text
                    elif child.tag == 'map' and current_key == 'installables':
                        return child
                    elif child.tag == 'map':
                        result = search_recursive(child)
                        if result is not None:
                            return result
                    else:
                        current_key = None
            return None
        
        return search_recursive(root)
    
    def parse_package_info(self, package_map):
        """Informationen eines einzelnen Pakets extrahieren"""
        info = {
            "name": "",
            "version": "",
            "license": "",
            "platforms": [],
            "description": "",
            "copyright": "",
            "platform_details": {}  # Für Hash und Archive-Pfad pro Plattform
        }
        
        current_key = None
        for child in package_map:
            if child.tag == "key":
                current_key = child.text
            elif child.tag == "string" and current_key:
                if current_key in info:
                    info[current_key] = child.text
                current_key = None
            elif child.tag == "map" and current_key == "platforms":
                # Plattformen und deren Details extrahieren
                self.parse_platform_details(child, info)
                current_key = None
        
        return info
    
    def parse_platform_details(self, platforms_map, info):
        """Extrahiert detaillierte Plattform-Informationen inkl. Hash und Archive-Pfad"""
        current_platform = None
        
        for platform_child in platforms_map:
            if platform_child.tag == "key":
                current_platform = platform_child.text
                if current_platform not in info["platforms"]:
                    info["platforms"].append(current_platform)
                info["platform_details"][current_platform] = {
                    "hash": "",
                    "archive_path": "",
                    "url": ""
                }
            elif platform_child.tag == "map" and current_platform:
                # Details dieser Plattform parsen
                detail_key = None
                for detail_child in platform_child:
                    if detail_child.tag == "key":
                        detail_key = detail_child.text
                    elif detail_child.tag == "string" and detail_key:
                        if detail_key == "name":
                            # Name der Plattform - bereits verarbeitet
                            pass
                        detail_key = None
                    elif detail_child.tag == "map" and detail_key == "archive":
                        # Archive-Details sind in einem verschachtelten Map
                        archive_key = None
                        for archive_child in detail_child:
                            if archive_child.tag == "key":
                                archive_key = archive_child.text
                            elif archive_child.tag == "string" and archive_key:
                                if archive_key == "hash":
                                    info["platform_details"][current_platform]["hash"] = archive_child.text
                                elif archive_key == "url":
                                    info["platform_details"][current_platform]["url"] = archive_child.text
                                    # URL als Archive-Pfad verwenden (oder Dateiname extrahieren)
                                    if archive_child.text:
                                        # Dateiname aus URL extrahieren
                                        archive_filename = archive_child.text.split('/')[-1]
                                        info["platform_details"][current_platform]["archive_path"] = archive_filename
                                archive_key = None
                        detail_key = None
    
    def refresh_packages(self):
        """Paketliste in der GUI aktualisieren"""
        # Alle vorhandenen Items löschen
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        # Alternierende Zeilen-Tags konfigurieren
        self.tree.tag_configure('odd', background='#f8f8f8')   # Hellgrau
        self.tree.tag_configure('even', background='#e8e8e8')  # Mittelgrau
        
        # Pakete zur Treeview hinzufügen
        row_count = 0
        for package_id, package_info in self.packages.items():
            platforms_str = ", ".join(package_info["platforms"])
            checkbox = "☑" if package_id in self.selected_packages else "☐"
            
            # Alternierende Tags für Zebra-Streifen
            tag = 'even' if row_count % 2 == 0 else 'odd'
            
            self.tree.insert("", "end", iid=package_id, text=package_id,
                           values=(
                               checkbox,
                               package_info["name"],
                               package_info["version"],
                               platforms_str,
                               package_info["license"]
                           ), tags=(tag,))
            row_count += 1
    

    
    def on_item_click(self, event):
        """Behandelt Klicks auf Treeview-Items"""
        region = self.tree.identify_region(event.x, event.y)
        if region == "cell":
            column = self.tree.identify_column(event.x)
            if column == "#1":  # Selected-Spalte (Checkbox)
                item = self.tree.identify_row(event.y)
                if item:
                    self.toggle_package_selection(item)
    
    def on_item_double_click(self, event):
        """Behandelt Doppelklicks - togglet Checkbox"""
        item = self.tree.identify_row(event.y)
        if item:
            self.toggle_package_selection(item)
    
    def toggle_package_selection(self, package_id):
        """Schaltet die Auswahl eines Pakets um"""
        if package_id in self.selected_packages:
            self.selected_packages.remove(package_id)
        else:
            self.selected_packages.add(package_id)
        
        # GUI aktualisieren
        self.refresh_packages()
        self.update_selection_count()
    
    def toggle_all_selection(self):
        """Schaltet die Auswahl aller Pakete um"""
        if len(self.selected_packages) == len(self.packages):
            # Alle abwählen
            self.selected_packages.clear()
            self.tree.heading("Selected", text="☐")
        else:
            # Alle auswählen
            self.selected_packages = set(self.packages.keys())
            self.tree.heading("Selected", text="☑")
        
        self.refresh_packages()
        self.update_selection_count()
    
    def update_selection_count(self):
        """Aktualisiert die Statuszeile mit Auswahlanzahl"""
        selected_count = len(self.selected_packages)
        total_count = len(self.packages)
        
        if selected_count == 0:
            status_text = self.i18n.get_text("selection_status_none", total_count)
        elif selected_count == total_count:
            status_text = self.i18n.get_text("selection_status_all", total_count)
        else:
            status_text = self.i18n.get_text("selection_status_partial", selected_count, total_count)
        
        self.status_label.config(text=status_text)
    
    def remove_selected_package(self):
        """Ausgewähltes Paket entfernen"""
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning(self.i18n.get_text("warning"), 
                                 self.i18n.get_text("no_package_selected_remove"))
            return
        
        package_id = selection[0]
        
        # Bestätigung
        result = messagebox.askyesno(
            self.i18n.get_text("warning"), 
            self.i18n.get_text("confirm_remove_package", package_id)
        )
        
        if result:
            self.remove_package(package_id)
    
    def remove_package(self, package_id):
        """Paket aus XML entfernen"""
        if package_id not in self.packages:
            return
        
        try:
            # Überprüfung ob XML-Baum geladen ist
            if not self.xml_tree:
                messagebox.showerror("Fehler", "Keine XML-Datei geladen!")
                return
            
            # Installables-Map finden
            installables_map = self.find_installables_map(self.xml_tree.getroot())
            if installables_map is None:
                messagebox.showerror("Fehler", "Installables-Sektion nicht gefunden!")
                return
            
            # Finde Key und Map zum Entfernen
            elements_to_remove = []
            for i, child in enumerate(installables_map):
                if child.tag == "key" and child.text == package_id:
                    elements_to_remove.append(child)
                    # Das nachfolgende map-Element auch entfernen
                    if i + 1 < len(installables_map) and installables_map[i + 1].tag == "map":
                        elements_to_remove.append(installables_map[i + 1])
                    break
            
            # Elemente entfernen
            for element in elements_to_remove:
                installables_map.remove(element)
            
            # Aus lokaler Liste entfernen
            del self.packages[package_id]
            
            # GUI aktualisieren
            self.refresh_packages()
            self.status_label.config(text=f"Paket '{package_id}' entfernt")
            
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Entfernen des Pakets:\n{str(e)}")
    
    def remove_all_linux64(self):
        """Alle Linux-Plattformen (64-bit und 32-bit) aus allen Paketen entfernen"""
        result = messagebox.askyesno(
            "Linux-Plattformen entfernen",
            "Möchten Sie alle Linux-Plattformen (linux64 und linux) aus allen Paketen entfernen?\n\n"
            "Dies entfernt sowohl 64-bit als auch veraltete 32-bit Linux-Einträge.\n"
            "Diese Aktion kann nicht rückgängig gemacht werden."
        )
        
        if not result:
            return
        
        try:
            removed_count = 0
            linux_platforms = ["linux64", "linux"]  # Beide Varianten entfernen
            
            for package_id, package_info in self.packages.items():
                package_element = package_info["xml_element"]
                
                # Suche nach platforms map
                platforms_map = None
                
                for i, child in enumerate(package_element):
                    if child.tag == "key" and child.text == "platforms":
                        if i + 1 < len(package_element) and package_element[i + 1].tag == "map":
                            platforms_map = package_element[i + 1]
                        break
                
                if platforms_map is not None:
                    # Finde und entferne alle Linux-Einträge (64-bit und 32-bit)
                    to_remove = []
                    current_key = None
                    
                    for child in platforms_map:
                        if child.tag == "key":
                            current_key = child
                        elif child.tag == "map" and current_key is not None and current_key.text in linux_platforms:
                            to_remove.extend([current_key, child])
                            current_key = None
                            removed_count += 1
                        else:
                            current_key = None
                    
                    # Entferne gefundene Elemente
                    for element in to_remove:
                        platforms_map.remove(element)
            
            # Pakete neu parsen und GUI aktualisieren
            self.parse_packages()
            self.refresh_packages()
            
            if removed_count > 0:
                self.status_label.config(text=f"{removed_count} Linux-Plattformen entfernt")
                messagebox.showinfo("Erfolg", f"{removed_count} Linux-Plattformen (64-bit und 32-bit) erfolgreich entfernt!")
            else:
                self.status_label.config(text="Keine Linux-Plattformen gefunden")
                messagebox.showinfo("Information", "Keine Linux-Plattformen zum Entfernen gefunden.")
            
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Entfernen der Linux-Plattformen:\n{str(e)}")
    
    def remove_all_darwin64(self):
        """Alle Darwin-Plattformen (64-bit und 32-bit) aus allen Paketen entfernen"""
        result = messagebox.askyesno(
            "Darwin-Plattformen entfernen",
            "Möchten Sie alle Darwin-Plattformen (darwin64 und darwin) aus allen Paketen entfernen?\n\n"
            "Dies entfernt sowohl 64-bit als auch veraltete 32-bit Darwin-Einträge.\n"
            "Diese Aktion kann nicht rückgängig gemacht werden."
        )
        
        if not result:
            return
        
        try:
            removed_count = 0
            darwin_platforms = ["darwin64", "darwin"]  # Beide Varianten entfernen
            
            for package_id, package_info in self.packages.items():
                package_element = package_info["xml_element"]
                
                # Suche nach platforms map
                platforms_map = None
                
                for i, child in enumerate(package_element):
                    if child.tag == "key" and child.text == "platforms":
                        if i + 1 < len(package_element) and package_element[i + 1].tag == "map":
                            platforms_map = package_element[i + 1]
                        break
                
                if platforms_map is not None:
                    # Finde und entferne alle Darwin-Einträge (64-bit und 32-bit)
                    to_remove = []
                    current_key = None
                    
                    for child in platforms_map:
                        if child.tag == "key":
                            current_key = child
                        elif child.tag == "map" and current_key is not None and current_key.text in darwin_platforms:
                            to_remove.extend([current_key, child])
                            current_key = None
                            removed_count += 1
                        else:
                            current_key = None
                    
                    # Entferne gefundene Elemente
                    for element in to_remove:
                        platforms_map.remove(element)
            
            # Pakete neu parsen und GUI aktualisieren
            self.parse_packages()
            self.refresh_packages()
            
            if removed_count > 0:
                self.status_label.config(text=f"{removed_count} Darwin-Plattformen entfernt")
                messagebox.showinfo("Erfolg", f"{removed_count} Darwin-Plattformen (64-bit und 32-bit) erfolgreich entfernt!")
            else:
                self.status_label.config(text="Keine Darwin-Plattformen gefunden")
                messagebox.showinfo("Information", "Keine Darwin-Plattformen zum Entfernen gefunden.")
            
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Entfernen der Darwin-Plattformen:\n{str(e)}")
    
    def save_file(self):
        """XML-Datei speichern"""
        if not self.xml_tree or not self.xml_file:
            messagebox.showwarning("Warnung", "Keine Datei zum Speichern geladen.")
            return
        
        try:
            self.xml_tree.write(self.xml_file, encoding="utf-8", xml_declaration=True)
            self.status_label.config(text="Datei gespeichert")
            messagebox.showinfo("Erfolg", "Datei erfolgreich gespeichert.")
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Speichern:\n{str(e)}")
    
    def export_package_overview(self):
        """Übersichtsdatei der ausgewählten Pakete erstellen"""
        if not self.selected_packages:
            messagebox.showwarning("Warnung", "Keine Pakete ausgewählt. Bitte wählen Sie mindestens ein Paket aus.")
            return
        
        if not self.xml_file:
            messagebox.showwarning("Warnung", "Keine XML-Datei geladen.")
            return
        
        try:
            # Erstelle Textdatei mit gleichem Namen wie XML aber .txt Endung
            base_name = os.path.splitext(self.xml_file)[0]
            txt_file = f"{base_name}.txt"
            
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            with open(txt_file, 'w', encoding='utf-8') as f:
                f.write("="*80 + "\n")
                f.write(f"AUTOBUILD PACKAGE OVERVIEW - {timestamp}\n")
                f.write(f"Quell-XML: {os.path.basename(self.xml_file)}\n")
                f.write(f"Anzahl ausgewählter Pakete: {len(self.selected_packages)}\n")
                f.write("="*80 + "\n\n")
                
                for package_id in sorted(self.selected_packages):
                    if package_id in self.packages:
                        package_info = self.packages[package_id]
                        
                        f.write(f"PAKET: {package_id}\n")
                        f.write("-" * 50 + "\n")
                        f.write(f"Name: {package_info['name']}\n")
                        f.write(f"Version: {package_info['version']}\n")
                        f.write(f"Lizenz: {package_info['license']}\n")
                        f.write(f"Beschreibung: {package_info['description']}\n")
                        f.write(f"Copyright: {package_info['copyright']}\n")
                        f.write(f"Plattformen: {', '.join(package_info['platforms'])}\n")
                        f.write("\nPlattform-Details:\n")
                        
                        for platform in package_info['platforms']:
                            if platform in package_info['platform_details']:
                                details = package_info['platform_details'][platform]
                                f.write(f"  {platform}:\n")
                                f.write(f"    Archive-Pfad: {details.get('archive_path', 'Nicht verfügbar')}\n")
                                f.write(f"    Hash: {details.get('hash', 'Nicht verfügbar')}\n")
                                f.write(f"    URL: {details.get('url', 'Nicht verfügbar')}\n")
                            else:
                                f.write(f"  {platform}:\n")
                                f.write("    Archive-Pfad: Nicht verfügbar\n")
                                f.write("    Hash: Nicht verfügbar\n")
                                f.write("    URL: Nicht verfügbar\n")
                        
                        f.write("\n" + "="*80 + "\n\n")
            
            self.status_label.config(text=f"Übersicht exportiert: {os.path.basename(txt_file)}")
            messagebox.showinfo("Export erfolgreich", 
                              f"Paket-Übersicht wurde erfolgreich exportiert:\n{txt_file}\n\n"
                              f"Anzahl exportierter Pakete: {len(self.selected_packages)}")
            
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Exportieren der Übersicht:\n{str(e)}")
    
    def create_backup(self):
        """Backup der aktuellen Datei erstellen"""
        if not self.xml_file:
            messagebox.showwarning("Warnung", "Keine Datei geladen.")
            return
        
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_file = f"{self.xml_file}.backup_{timestamp}"
            shutil.copy2(self.xml_file, backup_file)
            self.status_label.config(text=f"Backup erstellt: {os.path.basename(backup_file)}")
            messagebox.showinfo("Backup erstellt", f"Backup erstellt:\n{backup_file}")
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Erstellen des Backups:\n{str(e)}")

def main():
    """Hauptfunktion"""
    root = tk.Tk()
    AutobuildPackageManager(root)
    root.mainloop()

if __name__ == "__main__":
    main()