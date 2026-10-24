package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * HU08: cuidado periódico de una planta (riego, fertilización, poda, etc.).
 * Cada cuidado pertenece a una sola planta, y la planta a un solo usuario.
 */
@Entity
@Table(name = "cuidados")
public class Cuidado extends PanacheEntity {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    public TipoCuidado tipo;

    /** Cada cuántos días se debe repetir el cuidado (1 a 365). */
    @Column(name = "frecuencia_dias", nullable = false)
    public Integer frecuenciaDias;

    /** Última vez que se realizó el cuidado (no puede ser futura). */
    @Column(name = "fecha_ultimo_cuidado", nullable = false)
    public LocalDate fechaUltimoCuidado;

    @Column(length = 500)
    public String notas;

    @Column(name = "fecha_registro", nullable = false)
    public LocalDateTime fechaRegistro;

    @ManyToOne(optional = false)
    @JoinColumn(name = "planta_id", nullable = false)
    public Planta planta;
}
