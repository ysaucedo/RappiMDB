# RappiMDB
Prueba Técnica iOS

El proyecto consta de las siguientes capas

View 
  Conformado por los elementos de la interfase (Stooryboard) y las clases UIViewController
  -Main.storyboard
  -ShowsVC
  -ShowDetailVC
  -SerieDetailVC
  -SerieVC
  -VideoCollectionViewCell
  
Model
  -Show
  -Serie
  -ShowTheMovie
  -SerieTheMovie
  -Video
  
ViewModel
  -ViewModelShowList
  -ViewModelSerieList
  -ViewModelDetail
  -ViewModelDetail
  
Network
  -TheMovieDB
  -SerieDB
  -VideoDB
  
Persist
  -Model.xcdatamodeld
  
Responsabilidad de las capas:
View: Encargada de mostrar los elementos visuales de la App
Model: Representan las entidades de nuestro modelo
ViewModel: Capa que conecta la vista con los provider de datos, em este caso tenemos proveedoores de red y de base de datos loca para modo fuera de línea.
Network: Consume la API Rest para traernos la informaión.
Persist: Consiste en la base de datos local.

En qué consiste el principio de responsabilidad única? Cuál es su propósito?
El principio de responsabilodad única significa que cada compomente o clase deberá tener una sola responsabilidad que nos ayuda a tener un bajo acooplamiento y mayor 
cohesión en nuestras clases.

Un buen código es aquel que es más facil de entender, construir y dar mantenimiento.


