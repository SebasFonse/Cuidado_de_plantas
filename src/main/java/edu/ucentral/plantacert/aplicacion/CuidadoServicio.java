package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Cuidado;
import edu.ucentral.plantacert.dominio.CuidadoRepositorio;
import edu.ucentral.plantacert.dominio.Planta;
import edu.ucentral.plantacert.dominio.PlantaRepositorio;
import edu.ucentral.plantacert.dominio.TipoCuidado;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoRespuesta;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.jboss.logging.Logger;

import java.time.LocalDateTime;
import java.util.List;

@ApplicationScoped
public class CuidadoServicio {

    private static final Logger LOG = Logger.getLogger(CuidadoServicio.class);

    @Inject
    CuidadoRepositorio cuidadoRepositorio;

    @Inject
    PlantaRepositorio plantaRepositorio;

    /**
     * HU08: agrega un cuidado periódico a una planta del usuario.
     * Solo se permite si la planta existe y pertenece a ese usuario.
     */
    @Transactional
    public CuidadoRespuesta registrar(Long usuarioId, Long plantaId, CuidadoPayLoad payLoad) {
        Planta planta = buscarPlantaDelUsuario(usuarioId, plantaId);

        Cuidado cuidado = new Cuidado();
        cuidado.tipo = TipoCuidado.valueOf(payLoad.tipo().trim());
        cuidado.frecuenciaDias = payLoad.frecuenciaDias();
        cuidado.fechaUltimoCuidado = payLoad.fechaUltimoCuidado();
        cuidado.notas = limpiar(payLoad.notas());
        cuidado.fechaRegistro = LocalDateTime.now();
        cuidado.planta = planta;

        cuidadoRepositorio.persist(cuidado);
        LOG.infof("Cuidado %s registrado en la planta %d del usuario %d",
                cuidado.tipo, plantaId, usuarioId);

        return CuidadoRespuesta.desde(cuidado);
    }

    /** Cuidados de la planta, para mostrarlos en su información. */
    public List<CuidadoRespuesta> listarPorPlanta(Long usuarioId, Long plantaId) {
        buscarPlantaDelUsuario(usuarioId, plantaId);
        return cuidadoRepositorio.listarPorPlanta(plantaId)
                .stream()
                .map(CuidadoRespuesta::desde)
                .toList();
    }

    /**
     * Si la planta no existe o es de otro usuario se responde igual (404),
     * para no revelar plantas ajenas.
     */
    private Planta buscarPlantaDelUsuario(Long usuarioId, Long plantaId) {
        return plantaRepositorio.findByIdOptional(plantaId)
                .filter(p -> p.usuario != null && p.usuario.id.equals(usuarioId))
                .orElseThrow(() -> new NegocioException(404, "CERT-ERR-C1",
                        "La planta no existe o no pertenece al usuario"));
    }

    private static String limpiar(String valor) {
        return (valor == null || valor.isBlank()) ? null : valor.trim();
    }
}
