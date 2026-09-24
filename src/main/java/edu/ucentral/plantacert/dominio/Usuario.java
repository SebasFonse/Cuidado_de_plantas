package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
public class Usuario extends PanacheEntity {

    @Column(nullable = false, length = 100)
    public String nombre;

    @Column(nullable = false, unique = true, length = 150)
    public String correo;

    /** Nunca se guarda la contraseña en texto plano, solo su hash BCrypt. */
    @Column(name = "contrasena_hash", nullable = false)
    public String contrasenaHash;

    @Column(name = "fecha_registro", nullable = false)
    public LocalDateTime fechaRegistro;

    public Usuario() {
    }

    public Usuario(String nombre, String correo, String contrasenaHash, LocalDateTime fechaRegistro) {
        this.nombre = nombre;
        this.correo = correo;
        this.contrasenaHash = contrasenaHash;
        this.fechaRegistro = fechaRegistro;
    }
}
