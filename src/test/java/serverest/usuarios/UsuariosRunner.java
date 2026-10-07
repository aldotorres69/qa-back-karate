package serverest.usuarios;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Ejecuta en paralelo todos los features de la API de Usuarios.
 * Filtrar por tags: mvnw test -Dkarate.options="--tags @smoke"
 */
class UsuariosRunner {

    @Test
    void testUsuarios() {
        Results results = Runner.path("classpath:serverest/usuarios")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
