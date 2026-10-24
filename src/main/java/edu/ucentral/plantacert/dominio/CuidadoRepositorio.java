package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class CuidadoRepositorio implements PanacheRepository<Cuidado> {

    /** Cuidados de una planta, del más reciente al más antiguo. */
    public List<Cuidado> listarPorPlanta(Long plantaId) {
        return list("planta.id", Sort.descending("fechaRegistro"), plantaId);
    }
}
