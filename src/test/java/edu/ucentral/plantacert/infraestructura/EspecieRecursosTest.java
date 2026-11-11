package edu.ucentral.plantacert.infraestructura;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class EspecieRecursosTest {

    @Test
    public void testListarEspeciesCargadasAlIniciar() {
        given()
        .when()
                .get("/especies")
        .then()
                .statusCode(200)
                .body("size()", greaterThanOrEqualTo(30))
                .body("nombreCientifico", hasItem("Monstera deliciosa"))
                .body("nombreComun", hasItem("Costilla de Adán"));
    }

    @Test
    public void testBuscarEspeciePorNombreComunOCientifico() {
        given()
                .queryParam("q", "MONST")
        .when()
                .get("/especies")
        .then()
                .statusCode(200)
                .body("size()", is(1))
                .body("[0].nombreCientifico", is("Monstera deliciosa"));

        given()
                .queryParam("q", "potus")
        .when()
                .get("/especies")
        .then()
                .statusCode(200)
                .body("[0].nombreCientifico", is("Epipremnum aureum"));
    }

    @Test
    public void testBuscarEspecieSinResultados() {
        given()
                .queryParam("q", "planta-que-no-existe")
        .when()
                .get("/especies")
        .then()
                .statusCode(200)
                .body("size()", is(0));
    }
}
