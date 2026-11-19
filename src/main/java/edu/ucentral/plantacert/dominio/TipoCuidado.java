package edu.ucentral.plantacert.dominio;

/**
 * HU08: tipos de cuidado periódico que se pueden registrar en una planta.
 * Se guarda en la base de datos como texto (RIEGO, PODA, ...).
 */
public enum TipoCuidado {
    RIEGO,
    FERTILIZACION,
    PODA,
    EXPOSICION_LUZ,
    TRASPLANTE,
    OTRO
}
