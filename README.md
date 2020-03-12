# Hitobito GLP

This hitobito wagon defines the organization hierarchy with groups and roles of GLP Schweiz.

[![Build
Status](https://travis-ci.org/hitobito/hitobito_glp.svg)](https://travis-ci.org/hitobito/hitobito_glp)

# GLP Organization Hierarchy

    * Schweiz
      * Schweiz
        * Administrator: [:layer_and_below_full, :admin, :impersonation, :contact_data]
      * Geschäftsstelle
        * Leitung: [:layer_and_below_full, :admin, :contact_data]
        * Mitarbeiter(in): [:layer_and_below_full, :contact_data]
        * Finanzen: [:layer_and_below_read, :layer_full, :finance, :contact_data]
      * Vorstand
        * PräsidentIn: [:layer_and_below_read, :group_and_below_full, :contact_data]
        * Vizepräsidentln: [:group_and_below_full, :contact_data]
        * Geschäftsleitung: [:group_and_below_full, :contact_data]
        * Vorstandsmitglied: [:group_and_below_read, :contact_data]
      * Arbeitsgruppe
        * Leitung: [:group_and_below_read, :contact_data]
        * AG-Mitglied: [:group_and_below_read]
      * Zugeordnete
        * Mitglied: []
        * Sympathisant: []
        * Adressverwaltung: [:group_and_below_full]
      * Kontakte
        * Adressverwaltung: [:group_and_below_full]
        * Medien und Dritte: []
      * Gewählte
        * Bundesrat: []
        * Ständerat: []
        * Nationalrat: []
        * Bundesrichter (Vollamt): []
        * Bundesrichter (Nebenamt): []
        * Bundesverwaltungsrichter: []
        * Bundespatentrichter: []
        * Bundesstrafrichter: []
    * Kanton
      * Kanton
        * Administrator: [:layer_and_below_full, :contact_data]
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
      * Gewählte
        * Kantonale Exekutive: []
        * Kantonale Legislative: []
        * Mitglied kantonales Gericht obere Instanz: []
        * Mitglied kantonales Gericht erste Instanz: []
        * Staatsanwaltschaft: []
        * Parlamentarische Geschaeftsfuehrung: []
      * Geschäftsstelle
        * Leitung: [:layer_and_below_full, :contact_data, :finance]
        * Mitarbeiter(in): [:layer_and_below_read, :layer_full, :contact_data]
        * Finanzen: [:layer_and_below_read, :layer_full, :finance]
      * Vorstand
        * PräsidentIn: [:layer_and_below_read, :group_and_below_full, :contact_data]
        * Vizepräsidentln: [:group_and_below_full, :contact_data]
        * Geschäftsleitung: [:group_and_below_full, :contact_data]
        * Kassier: [:layer_and_below_read, :contact_data, :finance]
        * Mitglied: [:group_and_below_read, :contact_data]
      * Arbeitsgruppe
        * Leitung: [:group_and_below_read, :contact_data]
        * AG-Mitglied: [:group_and_below_read]
      * Zugeordnete
        * Mitglied: []
        * Sympathisant: []
        * Adressverwaltung: [:group_and_below_full]
      * Kontakte
        * Adressverwaltung: [:group_and_below_full]
        * Medien und Dritte: []
    * Bezirk
      * Bezirk
        * Administrator: [:layer_and_below_full, :contact_data]
      * Gewählte
        * Regierungsstatthalter/-in: []
      * Geschäftsstelle
        * Leitung: [:layer_and_below_full, :contact_data, :finance]
        * Mitarbeiter(in): [:layer_and_below_read, :layer_full, :contact_data]
        * Finanzen: [:layer_and_below_read, :layer_full, :finance]
      * Vorstand
        * PräsidentIn: [:layer_and_below_read, :group_and_below_full, :contact_data]
        * Vizepräsidentln: [:group_and_below_full, :contact_data]
        * Geschäftsleitung: [:group_and_below_full, :contact_data]
        * Kassier: [:layer_and_below_read, :contact_data, :finance]
        * Mitglied: [:group_and_below_read, :contact_data]
      * Arbeitsgruppe
        * Leitung: [:group_and_below_read, :contact_data]
        * AG-Mitglied: [:group_and_below_read]
      * Zugeordnete
        * Mitglied: []
        * Sympathisant: []
        * Adressverwaltung: [:group_and_below_full]
      * Kontakte
        * Adressverwaltung: [:group_and_below_full]
        * Medien und Dritte: []
    * Ortsektion
      * Ortsektion
        * Administrator: [:layer_and_below_full, :contact_data]
      * Gewählte
        * Kommunale Exekutive: []
        * Kommunale Legislative: []
        * Schulpflege/- kommission: []
        * Rechnungsprüfungskommission: []
        * Mitglied weitere Kommissionen: []
      * Geschäftsstelle
        * Leitung: [:layer_and_below_full, :contact_data, :finance]
        * Mitarbeiter(in): [:layer_and_below_read, :layer_full, :contact_data]
        * Finanzen: [:layer_and_below_read, :layer_full, :finance]
      * Vorstand
        * PräsidentIn: [:layer_and_below_read, :group_and_below_full, :contact_data]
        * Vizepräsidentln: [:group_and_below_full, :contact_data]
        * Geschäftsleitung: [:group_and_below_full, :contact_data]
        * Kassier: [:layer_and_below_read, :contact_data, :finance]
        * Mitglied: [:group_and_below_read, :contact_data]
      * Arbeitsgruppe
        * Leitung: [:group_and_below_read, :contact_data]
        * AG-Mitglied: [:group_and_below_read]
      * Zugeordnete
        * Mitglied: []
        * Sympathisant: []
        * Adressverwaltung: [:group_and_below_full]
      * Kontakte
        * Adressverwaltung: [:group_and_below_full]
        * Medien und Dritte: []

    (Output of rake app:hitobito:roles)
