package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class PlantaRepositorio implements PanacheRepository<Planta> {

    /**
     * HU04: plantas de un usuario, de la más reciente a la más antigua.
     * Si dos plantas tienen la misma fecha, se desempata por id (la última creada primero).
     */
    public List<Planta> listarPorUsuario(Long usuarioId) {
        return list("usuario.id",
                Sort.descending("fechaRegistro").and("id", Sort.Direction.Descending),
                usuarioId);
    }
}
