package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

/**
 * Base de datos de especies: lista de especies conocidas que el usuario
 * puede elegir al registrar una planta.
 */
@Entity
@Table(name = "especies")
public class Especie extends PanacheEntity {

    /** Nombre científico, por ejemplo "Monstera deliciosa". Es el que se guarda en la planta. */
    @Column(name = "nombre_cientifico", nullable = false, unique = true, length = 100)
    public String nombreCientifico;

    /** Nombre común, por ejemplo "Costilla de Adán". */
    @Column(name = "nombre_comun", nullable = false, length = 100)
    public String nombreComun;

    public Especie() {
    }

    public Especie(String nombreCientifico, String nombreComun) {
        this.nombreCientifico = nombreCientifico;
        this.nombreComun = nombreComun;
    }
}
