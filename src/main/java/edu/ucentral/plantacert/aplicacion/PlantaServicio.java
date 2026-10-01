package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Planta;
import edu.ucentral.plantacert.dominio.PlantaRepositorio;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import edu.ucentral.plantacert.infraestructura.dto.PlantaPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.PlantaRespuesta;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.jboss.logging.Logger;

import java.time.LocalDateTime;
import java.util.List;

@ApplicationScoped
public class PlantaServicio {

    private static final Logger LOG = Logger.getLogger(PlantaServicio.class);

    @Inject
    PlantaRepositorio plantaRepositorio;

    @Inject
    UsuarioRepositorio usuarioRepositorio;

    /**
     * RQ4-HU01: agrega una planta al catálogo del usuario.
     * La planta queda asociada únicamente a ese usuario.
     */
    @Transactional
    public PlantaRespuesta registrar(Long usuarioId, PlantaPayLoad payLoad) {
        Usuario usuario = buscarUsuario(usuarioId);

        Planta planta = new Planta();
        planta.nombre = payLoad.nombre().trim();
        planta.especie = payLoad.especie().trim();
        planta.ubicacion = payLoad.ubicacion().trim();
        planta.descripcion = limpiar(payLoad.descripcion());
        planta.imagenUrl = limpiar(payLoad.imagenUrl());
        planta.fechaRegistro = LocalDateTime.now();
        planta.usuario = usuario;

        plantaRepositorio.persist(planta);
        LOG.infof("Planta '%s' registrada para el usuario %d", planta.nombre, usuarioId);

        return PlantaRespuesta.desde(planta);
    }

    /** Catálogo del usuario (permite verificar que la planta quedó registrada). */
    public List<PlantaRespuesta> listarPorUsuario(Long usuarioId) {
        buscarUsuario(usuarioId);
        return plantaRepositorio.listarPorUsuario(usuarioId)
                .stream()
                .map(PlantaRespuesta::desde)
                .toList();
    }

    private Usuario buscarUsuario(Long usuarioId) {
        return usuarioRepositorio.findByIdOptional(usuarioId)
                .orElseThrow(() -> new NegocioException(404, "CERT-ERR-P1",
                        "El usuario indicado no existe"));
    }

    private static String limpiar(String valor) {
        return (valor == null || valor.isBlank()) ? null : valor.trim();
    }
}
