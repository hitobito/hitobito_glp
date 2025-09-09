# Externes Formular

Benutzer können sich via einem externen Formular registrieren. Dabei werden sie
abhängig von der angegeben PLZ und dem Geburtsdatum bzw. dem `jglp` Flag
bestimmten Gruppen zugeordnet, siehe dazu  `ExternalFormsController`,
`ExternallySubmittedPeopleController` und `SortingHat`


### Testing

Die Funktionalität kann innerhalb von hitobito via `/external_forms` getestet werden, z.b.

    https://glp.puzzle.ch/de/external_forms

dazu den Test Button klicken und anschliessend die Seite new laden (F5 drücken).

Dabei sollte darauf geachtet werden, dass auf INT nur zips verwendet werden, für
welche Gruppen existieren, ansonsten führt das zu 500er in der Applikation

    (`NoMethodErrorExternallySubmittedPeopleController#create`)



