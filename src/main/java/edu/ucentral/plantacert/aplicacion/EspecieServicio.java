package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.dominio.Especie;
import edu.ucentral.plantacert.dominio.EspecieRepositorio;
import edu.ucentral.plantacert.infraestructura.dto.EspecieRespuesta;
import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.jboss.logging.Logger;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@ApplicationScoped
public class EspecieServicio {

    private static final Logger LOG = Logger.getLogger(EspecieServicio.class);

    /** Especies iniciales: {nombre científico, nombre común}. */
    static final String[][] ESPECIES_INICIALES = {
            {"Monstera deliciosa", "Costilla de Adán"},
            {"Epipremnum aureum", "Potus"},
            {"Dracaena trifasciata", "Lengua de suegra"},
            {"Nephrolepis exaltata", "Helecho de Boston"},
            {"Echeveria elegans", "Echeveria"},
            {"Aloe vera", "Sábila"},
            {"Opuntia ficus-indica", "Nopal"},
            {"Crassula ovata", "Árbol de jade"},
            {"Phalaenopsis amabilis", "Orquídea mariposa"},
            {"Anthurium andraeanum", "Anturio"},
            {"Spathiphyllum wallisii", "Cuna de Moisés"},
            {"Ficus lyrata", "Ficus lira"},
            {"Ficus benjamina", "Ficus benjamina"},
            {"Chlorophytum comosum", "Cinta"},
            {"Goeppertia orbifolia", "Calathea"},
            {"Zamioculcas zamiifolia", "Zamioculca"},
            {"Philodendron hederaceum", "Filodendro"},
            {"Dypsis lutescens", "Palma areca"},
            {"Guzmania lingulata", "Bromelia"},
            {"Saintpaulia ionantha", "Violeta africana"},
            {"Begonia rex", "Begonia"},
            {"Pelargonium hortorum", "Geranio"},
            {"Rosa chinensis", "Rosa"},
            {"Hydrangea macrophylla", "Hortensia"},
            {"Helianthus annuus", "Girasol"},
            {"Lavandula angustifolia", "Lavanda"},
            {"Salvia rosmarinus", "Romero"},
            {"Ocimum basilicum", "Albahaca"},
            {"Mentha spicata", "Hierbabuena"},
            {"Coriandrum sativum", "Cilantro"},
            {"Solanum lycopersicum", "Tomate"},
            {"Capsicum annuum", "Pimentón"},
            {"Fragaria x ananassa", "Fresa"},
            {"Citrus limon", "Limonero"},
            {"Coffea arabica", "Café"},
            {"Juniperus procumbens", "Bonsái de junípero"},
    };

    @Inject
    EspecieRepositorio especieRepositorio;

    /**
     * Al arrancar la API se cargan las especies que todavía no estén en la base de datos.
     * No borra ni duplica las que ya existen.
     */
    @Transactional
    void cargarEspecies(@Observes StartupEvent evento) {
        Set<String> existentes = especieRepositorio.listAll().stream()
                .map(especie -> especie.nombreCientifico)
                .collect(Collectors.toSet());
        int nuevas = 0;
        for (String[] datos : ESPECIES_INICIALES) {
            if (!existentes.contains(datos[0])) {
                especieRepositorio.persist(new Especie(datos[0], datos[1]));
                nuevas++;
            }
        }
        LOG.infof("Base de datos de especies: %d nuevas, %d en total", nuevas, existentes.size() + nuevas);
    }

    /** Lista de especies; si llega texto, filtra por nombre común o científico. */
    public List<EspecieRespuesta> listar(String texto) {
        List<Especie> especies = (texto == null || texto.isBlank())
                ? especieRepositorio.listarOrdenadas()
                : especieRepositorio.buscar(texto);
        return especies.stream().map(EspecieRespuesta::desde).toList();
    }
}
