package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.dominio.Planta;
import edu.ucentral.plantacert.dominio.PlantaRepositorio;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import io.quarkus.narayana.jta.QuarkusTransaction;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class CuidadoRecursosTest {

    @Inject
    UsuarioRepositorio usuarioRepositorio;

    @Inject
    PlantaRepositorio plantaRepositorio;

    /** Crea un usuario con una planta directamente en BD. Devuelve {usuarioId, plantaId}. */
    private Long[] crearUsuarioConPlanta() {
        return QuarkusTransaction.requiringNew().call(() -> {
            Usuario usuario = new Usuario("Valeria Prueba",
                    "valeria" + System.nanoTime() + "@correo.com",
                    "hash-de-prueba", LocalDateTime.now());
            usuarioRepositorio.persist(usuario);

            Planta planta = new Planta();
            planta.nombre = "Monstera";
            planta.especie = "Monstera deliciosa";
            planta.ubicacion = "Sala";
            planta.fechaRegistro = LocalDateTime.now();
            planta.usuario = usuario;
            plantaRepositorio.persist(planta);

            return new Long[]{usuario.id, planta.id};
        });
    }

    private String json(String tipo, Integer frecuencia, String fecha, String notas) {
        return """
               {
                 "tipo": "%s",
                 "frecuenciaDias": %s,
                 "fechaUltimoCuidado": "%s",
                 "notas": "%s"
               }
               """.formatted(tipo, frecuencia, fecha, notas);
    }

    private String url(Long usuarioId, Long plantaId) {
        return "/cuidados/usuario/" + usuarioId + "/planta/" + plantaId;
    }

    @Test
    public void testRegistrarCuidadoExitoso() {
        Long[] ids = crearUsuarioConPlanta();
        String ayer = LocalDate.now().minusDays(1).toString();

        given()
                .contentType(ContentType.JSON)
                .body(json("RIEGO", 3, ayer, "Regar con agua reposada"))
        .when()
                .post(url(ids[0], ids[1]))
        .then()
                .statusCode(201)
                .body("id", notNullValue())
                .body("tipo", is("RIEGO"))
                .body("frecuenciaDias", is(3))
                .body("fechaUltimoCuidado", is(ayer))
                .body("plantaId", equalTo(ids[1].intValue()));
    }

    @Test
    public void testRegistrarCuidadoTipoInvalido() {
        Long[] ids = crearUsuarioConPlanta();
        given()
                .contentType(ContentType.JSON)
                .body(json("BAILAR", 3, LocalDate.now().toString(), ""))
        .when()
                .post(url(ids[0], ids[1]))
        .then()
                .statusCode(400)
                .body("error.detalles", hasItem(containsString("tipo de cuidado")));
    }

    @Test
    public void testRegistrarCuidadoFrecuenciaFueraDeRango() {
        Long[] ids = crearUsuarioConPlanta();
        for (int frecuencia : new int[]{0, 366}) {
            given()
                    .contentType(ContentType.JSON)
                    .body(json("PODA", frecuencia, LocalDate.now().toString(), ""))
            .when()
                    .post(url(ids[0], ids[1]))
            .then()
                    .statusCode(400)
                    .body("error.detalles", hasItem(containsString("frecuencia")));
        }
    }

    @Test
    public void testRegistrarCuidadoFechaFutura() {
        Long[] ids = crearUsuarioConPlanta();
        String manana = LocalDate.now().plusDays(2).toString();
        given()
                .contentType(ContentType.JSON)
                .body(json("FERTILIZACION", 15, manana, ""))
        .when()
                .post(url(ids[0], ids[1]))
        .then()
                .statusCode(400)
                .body("error.detalles", hasItem(containsString("fecha futura")));
    }

    @Test
    public void testRegistrarCuidadoNotasMuyLargas() {
        Long[] ids = crearUsuarioConPlanta();
        given()
                .contentType(ContentType.JSON)
                .body(json("OTRO", 7, LocalDate.now().toString(), "a".repeat(501)))
        .when()
                .post(url(ids[0], ids[1]))
        .then()
                .statusCode(400)
                .body("error.detalles", hasItem(containsString("500 caracteres")));
    }

    @Test
    public void testRegistrarCuidadoPlantaDeOtroUsuario() {
        Long[] valeria = crearUsuarioConPlanta();
        Long[] otro = crearUsuarioConPlanta();
        given()
                .contentType(ContentType.JSON)
                .body(json("RIEGO", 3, LocalDate.now().toString(), ""))
        .when()
                .post(url(valeria[0], otro[1]))
        .then()
                .statusCode(404)
                .body("error.codigo", is("CERT-ERR-C1"));
    }

    @Test
    public void testRegistrarCuidadoPlantaInexistente() {
        Long[] ids = crearUsuarioConPlanta();
        given()
                .contentType(ContentType.JSON)
                .body(json("RIEGO", 3, LocalDate.now().toString(), ""))
        .when()
                .post(url(ids[0], 999999L))
        .then()
                .statusCode(404)
                .body("error.codigo", is("CERT-ERR-C1"));
    }

    @Test
    public void testListarCuidadosDeLaPlanta() {
        Long[] ids = crearUsuarioConPlanta();
        for (String tipo : new String[]{"RIEGO", "TRASPLANTE"}) {
            given().contentType(ContentType.JSON)
                    .body(json(tipo, 10, LocalDate.now().toString(), ""))
                    .when().post(url(ids[0], ids[1]))
                    .then().statusCode(201);
        }

        given()
        .when()
                .get(url(ids[0], ids[1]))
        .then()
                .statusCode(200)
                .body("$", hasSize(2))
                .body("tipo", hasItems("RIEGO", "TRASPLANTE"));
    }
}
