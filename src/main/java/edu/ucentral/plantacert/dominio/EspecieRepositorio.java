package edu.ucentral.plantacert.dominio;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class EspecieRepositorio implements PanacheRepository<Especie> {

    /** Todas las especies ordenadas por nombre común. */
    public List<Especie> listarOrdenadas() {
        return listAll(Sort.ascending("nombreComun"));
    }

    /** Especies cuyo nombre común o científico contiene el texto (sin importar mayúsculas). */
    public List<Especie> buscar(String texto) {
        String patron = "%" + texto.trim().toLowerCase() + "%";
        return list("lower(nombreComun) like ?1 or lower(nombreCientifico) like ?1",
                Sort.ascending("nombreComun"), patron);
    }
}
