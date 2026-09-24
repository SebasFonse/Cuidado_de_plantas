package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.Optional;

@ApplicationScoped
public class UsuarioRepositorio implements PanacheRepository<Usuario> {

    public boolean existePorCorreo(String correo) {
        return count("correo", correo) > 0;
    }

    public Optional<Usuario> buscarPorCorreo(String correo) {
        return find("correo", correo).firstResultOptional();
    }
}
