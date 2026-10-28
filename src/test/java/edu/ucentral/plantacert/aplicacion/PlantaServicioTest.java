package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Planta;
import edu.ucentral.plantacert.dominio.PlantaRepositorio;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import edu.ucentral.plantacert.infraestructura.dto.PlantaPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.PlantaRespuesta;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@QuarkusTest
public class PlantaServicioTest {

    @Inject
    PlantaServicio plantaServicio;

    @InjectMock
    PlantaRepositorio plantaRepositorio;

    @InjectMock
    UsuarioRepositorio usuarioRepositorio;

    private Usuario usuarioSimulado() {
        Usuario usuario = new Usuario("Valeria", "valeria@correo.com", "hash", LocalDateTime.now());
        usuario.id = 1L;
        return usuario;
    }

    @Test
    public void testRegistrarPlantaGuardaUnaVez() {
        when(usuarioRepositorio.findByIdOptional(1L)).thenReturn(Optional.of(usuarioSimulado()));
        var payLoad = new PlantaPayLoad("Monstera", "Monstera deliciosa", "Sala",
                "Hojas grandes", "https://ejemplo.com/monstera.jpg");

        PlantaRespuesta respuesta = plantaServicio.registrar(1L, payLoad);

        verify(plantaRepositorio, times(1)).persist(any(Planta.class));
        assertEquals("Monstera", respuesta.nombre());
        assertEquals(1L, respuesta.usuarioId());
    }

    @Test
    public void testRegistrarPlantaQuedaAsociadaAlUsuario() {
        Usuario usuario = usuarioSimulado();
        when(usuarioRepositorio.findByIdOptional(1L)).thenReturn(Optional.of(usuario));
        var payLoad = new PlantaPayLoad("Monstera", "Monstera deliciosa", "Sala", null, null);

        plantaServicio.registrar(1L, payLoad);

        ArgumentCaptor<Planta> captor = ArgumentCaptor.forClass(Planta.class);
        verify(plantaRepositorio).persist(captor.capture());
        assertSame(usuario, captor.getValue().usuario);
        assertNotNull(captor.getValue().fechaRegistro);
    }

    @Test
    public void testRegistrarPlantaCamposOpcionalesVaciosQuedanNulos() {
        when(usuarioRepositorio.findByIdOptional(1L)).thenReturn(Optional.of(usuarioSimulado()));
        var payLoad = new PlantaPayLoad("  Cactus ", "Cactaceae", "Balcón", "   ", "");

        PlantaRespuesta respuesta = plantaServicio.registrar(1L, payLoad);

        assertEquals("Cactus", respuesta.nombre());
        assertNull(respuesta.descripcion());
        assertNull(respuesta.imagenUrl());
    }

    @Test
    public void testRegistrarPlantaUsuarioInexistente() {
        when(usuarioRepositorio.findByIdOptional(99L)).thenReturn(Optional.empty());
        var payLoad = new PlantaPayLoad("Monstera", "Monstera deliciosa", "Sala", null, null);

        NegocioException error = assertThrows(NegocioException.class,
                () -> plantaServicio.registrar(99L, payLoad));

        assertEquals(404, error.getStatus());
        verify(plantaRepositorio, never()).persist(any(Planta.class));
    }

    // HU04: ver listado de plantas del catálogo

    private Planta plantaSimulada(Long id, String nombre, Usuario usuario) {
        Planta planta = new Planta();
        planta.id = id;
        planta.nombre = nombre;
        planta.especie = "Especie";
        planta.ubicacion = "Sala";
        planta.imagenUrl = "https://ejemplo.com/" + id + ".jpg";
        planta.fechaRegistro = LocalDateTime.now();
        planta.usuario = usuario;
        return planta;
    }

    @Test
    public void testListarPlantasConservaElOrdenDelRepositorio() {
        Usuario usuario = usuarioSimulado();
        when(usuarioRepositorio.findByIdOptional(1L)).thenReturn(Optional.of(usuario));
        when(plantaRepositorio.listarPorUsuario(1L)).thenReturn(List.of(
                plantaSimulada(2L, "Suculenta", usuario),
                plantaSimulada(1L, "Helecho", usuario)));

        List<PlantaRespuesta> plantas = plantaServicio.listarPorUsuario(1L);

        assertEquals(2, plantas.size());
        assertEquals("Suculenta", plantas.get(0).nombre());
        assertEquals("Helecho", plantas.get(1).nombre());
        assertEquals("https://ejemplo.com/2.jpg", plantas.get(0).imagenUrl());
        assertEquals(1L, plantas.get(0).usuarioId());
    }

    @Test
    public void testListarPlantasCatalogoVacio() {
        when(usuarioRepositorio.findByIdOptional(1L)).thenReturn(Optional.of(usuarioSimulado()));
        when(plantaRepositorio.listarPorUsuario(1L)).thenReturn(List.of());

        assertTrue(plantaServicio.listarPorUsuario(1L).isEmpty());
    }

    @Test
    public void testListarPlantasUsuarioInexistente() {
        when(usuarioRepositorio.findByIdOptional(99L)).thenReturn(Optional.empty());

        NegocioException error = assertThrows(NegocioException.class,
                () -> plantaServicio.listarPorUsuario(99L));

        assertEquals(404, error.getStatus());
        verify(plantaRepositorio, never()).listarPorUsuario(any());
    }
}
