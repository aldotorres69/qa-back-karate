@ignore
Feature: Helper - Eliminar un usuario por API (limpieza de datos)

  # Uso: * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(id)' }

  Scenario: Eliminar usuario
    Given url baseUrl
    And path 'usuarios', id
    When method delete
    Then status 200
