Multi-level Table of Content

Description: 
Simple project that parses data from a remote JSON source and displays it on two screens in a user-readable form. The first screen presents multi-level table of contents with editing features, while the second screen displays detais for selected entry from the first screen.

Features:
* Fetch and Display Data: The project fetches and displays list data and its details from provided remote sources. It's designed to parse and display list data of any number of levels, without being limited to only 4 levels.
* Interactive Data Handling: Users can interact with the data by removing and moving children (all levels except 0) within the list when edit mode is enabled. Editing for any level can be enabled/disabled using KHTreeGroupViewContentProvider's 'config' property.
* Theming Support: The project allows developers to create various color themes using KHTheme and KHPalette files. Whenever a theme is changed, the app automatically updates its colors accordingly.
* Multiple Data Sources: The project supports both local and remote data sources. To use a local source, update KHContentManager's property "local" to "true." In this case, JSON files from the folder multitoc/Other/Data will be used.
