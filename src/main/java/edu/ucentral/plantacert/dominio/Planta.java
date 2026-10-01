package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "plantas")
public class Planta extends PanacheEntity {

    @Column(nullable = false, length = 100)
    public String nombre;

    @Column(nullable = false, length = 100)
    public String especie;

    @Column(nullable = false, length = 100)
    public String ubicacion;

    @Column(length = 1000)
    public String descripcion;

    @Column(name = "imagen_url", length = 500)
    public String imagenUrl;

    @Column(name = "fecha_registro", nullable = false)
    public LocalDateTime fechaRegistro;

    /** Cada planta pertenece únicamente a un usuario (RQ-04). */
    @ManyToOne(optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    public Usuario usuario;
}
