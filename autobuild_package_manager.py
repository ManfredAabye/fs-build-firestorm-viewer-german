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
from datetime import datetime

class AutobuildPackageManager:
    def __init__(self, root):
        self.root = root
        self.root.title("Autobuild Package Manager")
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
        
        # Datei-Auswahl Frame
        file_frame = ttk.Frame(main_frame)
        file_frame.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 10))
        
        ttk.Label(file_frame, text="XML-Datei:").grid(row=0, column=0, sticky=tk.W)
        self.file_label = ttk.Label(file_frame, text="Keine Datei geladen", foreground="red")
        self.file_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Button(file_frame, text="Datei öffnen", command=self.open_file, style="Blue.TButton").grid(row=0, column=2, padx=(10, 0))
        ttk.Button(file_frame, text="Datei speichern", command=self.save_file, style="Blue.TButton").grid(row=0, column=3, padx=(5, 0))
        ttk.Button(file_frame, text="Übersicht exportieren", command=self.export_package_overview, style="Blue.TButton").grid(row=0, column=4, padx=(5, 0))
        ttk.Button(file_frame, text="Backup erstellen", command=self.create_backup, style="Blue.TButton").grid(row=0, column=5, padx=(5, 0))
        
        # Paket-Liste Frame
        list_frame = ttk.Frame(main_frame)
        list_frame.grid(row=1, column=0, columnspan=2, sticky="nsew", pady=(0, 10))
        
        # Treeview für Paketliste mit Checkboxen
        columns = ("Selected", "Name", "Version", "Plattformen", "Lizenz")
        self.tree = ttk.Treeview(list_frame, columns=columns, show="tree headings", height=15)
        
        # Spaltenüberschriften
        self.tree.heading("#0", text="Paket-ID")
        self.tree.heading("Selected", text="☐", command=self.toggle_all_selection)
        self.tree.heading("Name", text="Name")
        self.tree.heading("Version", text="Version")
        self.tree.heading("Plattformen", text="Plattformen")
        self.tree.heading("Lizenz", text="Lizenz")
        
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
        button_frame.grid(row=2, column=0, columnspan=2, sticky="ew")
        
        ttk.Button(button_frame, text="Ausgewählte Pakete entfernen", 
                  command=self.remove_selected_package, style="Accent.TButton").grid(row=0, column=0, padx=(0, 10))
        ttk.Button(button_frame, text="Alle Linux-Plattformen entfernen", 
                  command=self.remove_all_linux64, style="Blue.TButton").grid(row=0, column=1, padx=(0, 10))
        ttk.Button(button_frame, text="Alle Darwin64 Plattformen entfernen", 
                  command=self.remove_all_darwin64, style="Blue.TButton").grid(row=0, column=2, padx=(0, 10))
        ttk.Button(button_frame, text="Aktualisieren", 
                  command=self.refresh_packages, style="Blue.TButton").grid(row=0, column=3)
        
        # Status Frame
        status_frame = ttk.Frame(main_frame)
        status_frame.grid(row=3, column=0, columnspan=2, sticky="ew", pady=(10, 0))
        
        self.status_label = ttk.Label(status_frame, text="Bereit")
        self.status_label.grid(row=0, column=0, sticky=tk.W)
        
        # Grid-Gewichtung für Responsive Design
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(1, weight=1)
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
    
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
                        if detail_key == "hash":
                            info["platform_details"][current_platform]["hash"] = detail_child.text
                        elif detail_key == "archive":
                            info["platform_details"][current_platform]["archive_path"] = detail_child.text
                        elif detail_key == "url":
                            info["platform_details"][current_platform]["url"] = detail_child.text
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
            status_text = f"Keine Pakete ausgewählt ({total_count} verfügbar)"
        elif selected_count == total_count:
            status_text = f"Alle {total_count} Pakete ausgewählt"
        else:
            status_text = f"{selected_count} von {total_count} Paketen ausgewählt"
        
        self.status_label.config(text=status_text)
    
    def remove_selected_package(self):
        """Ausgewähltes Paket entfernen"""
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Warnung", "Bitte wählen Sie ein Paket zum Entfernen aus.")
            return
        
        package_id = selection[0]
        
        # Bestätigung
        result = messagebox.askyesno(
            "Paket entfernen", 
            f"Möchten Sie das Paket '{package_id}' wirklich entfernen?\n\n"
            f"Diese Aktion kann nicht rückgängig gemacht werden."
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
        """Alle Darwin64-Plattformen aus allen Paketen entfernen"""
        result = messagebox.askyesno(
            "Darwin64 Plattformen entfernen",
            "Möchten Sie alle Darwin64-Plattformen aus allen Paketen entfernen?\n\n"
            "Diese Aktion kann nicht rückgängig gemacht werden."
        )
        
        if not result:
            return
        
        try:
            removed_count = 0
            
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
                    # Finde und entferne Darwin64-Einträge
                    to_remove = []
                    current_key = None
                    
                    for child in platforms_map:
                        if child.tag == "key":
                            current_key = child
                        elif child.tag == "map" and current_key is not None and current_key.text == "darwin64":
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
                self.status_label.config(text=f"{removed_count} Darwin64-Plattformen entfernt")
                messagebox.showinfo("Erfolg", f"{removed_count} Darwin64-Plattformen erfolgreich entfernt!")
            else:
                self.status_label.config(text="Keine Darwin64-Plattformen gefunden")
                messagebox.showinfo("Information", "Keine Darwin64-Plattformen zum Entfernen gefunden.")
            
        except Exception as e:
            messagebox.showerror("Fehler", f"Fehler beim Entfernen der Darwin64-Plattformen:\n{str(e)}")
    
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
                                f.write(f"    Archive-Pfad: {details['archive_path']}\n")
                                f.write(f"    Hash: {details['hash']}\n")
                                f.write(f"    URL: {details['url']}\n")
                        
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