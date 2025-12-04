Le but du projet est de créer une API qui fera du crud sur une base de données. On utilisera ici une base de données Spotify sur PostGreSQL.

### Données Spotify 2025

Ce fichier contient des informations sur des morceaux récents et contemporains disponibles sur Spotify, principalement issus de l’année 2025.

Chaque ligne du fichier représente un morceau unique avec les attributs suivants par exemple:

- **Titre du morceau**
- **Artiste**
- **Album**
- **Popularité**

Voici le modèle de la base de données :

Un artiste peut avoir un ou plusieurs albums et appartenir à plusieurs genres.
Un titre peut appartenir à plusieurs albums et un album peut avoir plusieurs titres.
![alt text](modele.png)
