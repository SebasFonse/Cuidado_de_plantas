package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Cuidado;
import edu.ucentral.plantacert.dominio.CuidadoRepositorio;
import edu.ucentral.plantacert.dominio.Planta;
import edu.ucentral.plantacert.dominio.PlantaRepositorio;
import edu.ucentral.plantacert.dominio.TipoCuidado;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoRespuesta;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@QuarkusTest
public class CuidadoServicioTest {

    @Inject
    CuidadoServicio cuidadoServicio;

    @InjectMock
    CuidadoRepositorio cuidadoRepositorio;

    @InjectMock
    PlantaRepositorio plantaRepositorio;

    private Planta plantaDelUsuario(Long usuarioId) {
        Usuario usuario = new Usuario("Valeria", "valeria@correo.com", "hash", LocalDateTime.now());
        usuario.id = usuarioId;
        Planta planta = new Planta();
        planta.id = 10L;
        planta.nombre = "Monstera";
        planta.usuario = usuario;
        return planta;
    }

    private CuidadoPayLoad payLoad(String notas) {
        return new CuidadoPayLoad("RIEGO", 3, LocalDate.now().minusDays(1), null, null, notas);
    }

    private CuidadoPayLoad payLoadConPeriodo(LocalDate inicio, LocalDate fin) {
        return new CuidadoPayLoad("RIEGO", 3, LocalDate.now().minusDays(1), inicio, fin, null);
    }

    @Test
    public void testRegistrarCuidadoGuardaUnaVez() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(1L)));

        CuidadoRespuesta respuesta = cuidadoServicio.registrar(1L, 10L, payLoad("Agua reposada"));

        verify(cuidadoRepositorio, times(1)).persist(any(Cuidado.class));
        assertEquals("RIEGO", respuesta.tipo());
        assertEquals(3, respuesta.frecuenciaDias());
        assertEquals(10L, respuesta.plantaId());
    }

    @Test
    public void testRegistrarCuidadoQuedaAsociadoALaPlanta() {
        Planta planta = plantaDelUsuario(1L);
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(planta));

        cuidadoServicio.registrar(1L, 10L, payLoad(null));

        ArgumentCaptor<Cuidado> captor = ArgumentCaptor.forClass(Cuidado.class);
        verify(cuidadoRepositorio).persist(captor.capture());
        assertSame(planta, captor.getValue().planta);
        assertEquals(TipoCuidado.RIEGO, captor.getValue().tipo);
        assertNotNull(captor.getValue().fechaRegistro);
    }

    @Test
    public void testRegistrarCuidadoNotasVaciasQuedanNulas() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(1L)));

        CuidadoRespuesta respuesta = cuidadoServicio.registrar(1L, 10L, payLoad("   "));

        assertNull(respuesta.notas());
    }

    @Test
    public void testRegistrarCuidadoEnPlantaDeOtroUsuario() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(2L)));

        NegocioException error = assertThrows(NegocioException.class,
                () -> cuidadoServicio.registrar(1L, 10L, payLoad(null)));

        assertEquals(404, error.getStatus());
        assertEquals("CERT-ERR-C1", error.getCodigo());
        verify(cuidadoRepositorio, never()).persist(any(Cuidado.class));
    }

    @Test
    public void testRegistrarCuidadoPlantaInexistente() {
        when(plantaRepositorio.findByIdOptional(99L)).thenReturn(Optional.empty());

        assertThrows(NegocioException.class,
                () -> cuidadoServicio.registrar(1L, 99L, payLoad(null)));
        verify(cuidadoRepositorio, never()).persist(any(Cuidado.class));
    }

    @Test
    public void testRegistrarCuidadoGuardaPrimerYUltimoDia() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(1L)));
        LocalDate inicio = LocalDate.now();
        LocalDate fin = inicio.plusDays(30);

        CuidadoRespuesta respuesta = cuidadoServicio.registrar(1L, 10L, payLoadConPeriodo(inicio, fin));

        assertEquals(inicio, respuesta.fechaInicio());
        assertEquals(fin, respuesta.fechaFin());
    }

    @Test
    public void testRegistrarCuidadoSinPrimerDiaUsaElUltimoCuidado() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(1L)));

        CuidadoRespuesta respuesta = cuidadoServicio.registrar(1L, 10L, payLoad(null));

        assertEquals(LocalDate.now().minusDays(1), respuesta.fechaInicio());
        assertNull(respuesta.fechaFin());
    }

    @Test
    public void testRegistrarCuidadoUltimoDiaAntesDelPrimero() {
        when(plantaRepositorio.findByIdOptional(10L)).thenReturn(Optional.of(plantaDelUsuario(1L)));
        LocalDate inicio = LocalDate.now();

        NegocioException error = assertThrows(NegocioException.class,
                () -> cuidadoServicio.registrar(1L, 10L, payLoadConPeriodo(inicio, inicio.minusDays(1))));

        assertEquals(400, error.getStatus());
        assertEquals("CERT-ERR-C2", error.getCodigo());
        verify(cuidadoRepositorio, never()).persist(any(Cuidado.class));
    }
}
