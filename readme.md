# PCKManager

EditorPlugin for managing PCK files. Adds an ExportPlugin to split the main PCK into smaller ones, e.g., to create DLCs.

**Imprtant:** _You cannot have any dependencies from your main scene split into another PCK. All resources loaded on startup (e.g. translation files, autoload scripts, etc.) must be present in the main PCK and cannot be split._

![screenshot](https://github.com/MrJustreborn/godot_PCKManager/blob/master/screenshot_1.png?raw=true)

![screenshot](https://github.com/MrJustreborn/godot_PCKManager/blob/master/screenshot_3.png?raw=true)

![screenshot](https://github.com/MrJustreborn/godot_PCKManager/blob/master/screenshot_2.png?raw=true)