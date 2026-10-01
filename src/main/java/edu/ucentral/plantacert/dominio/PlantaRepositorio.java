package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class PlantaRepositorio implements PanacheRepository<Planta> {

    /** Plantas de un usuario, de la más reciente a la más antigua. */
    public List<Planta> listarPorUsuario(Long usuarioId) {
        return list("usuario.id", Sort.descending("fechaRegistro"), usuarioId);
    }
}
