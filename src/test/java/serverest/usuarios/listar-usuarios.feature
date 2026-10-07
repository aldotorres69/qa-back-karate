@usuarios @listar
Feature: GET /usuarios - Listar usuarios

  Como administrador del sistema
  Quiero obtener la lista de usuarios registrados
  Para conocer el estado de la base de datos de usuarios

  Background:
    * url baseUrl
    * def usuarioSchema = read('classpath:serverest/common/schemas/usuario.json')
    * def listaSchema = read('classpath:serverest/common/schemas/lista-usuarios.json')

  @smoke @positivo
  Scenario: Listar todos los usuarios devuelve 200 y cumple el esquema
    Given path 'usuarios'
    When method get
    Then status 200
    And match response == listaSchema
    And match each response.usuarios == usuarioSchema
    And match response.quantidade == karate.sizeOf(response.usuarios)

  @positivo
  Scenario: El usuario recién registrado aparece en la lista filtrando por _id
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios'
    And param _id = creado.id
    When method get
    Then status 200
    And match response.quantidade == 1
    And match response.usuarios[0] == usuarioSchema
    And match response.usuarios[0] contains creado.usuario
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }

  @positivo
  Scenario Outline: Filtrar la lista por <filtro>
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * def valor = creado.usuario[filtro]
    Given path 'usuarios'
    And param <filtro> = valor
    When method get
    Then status 200
    And match response.quantidade == '#? _ >= 1'
    And match each response.usuarios contains { <filtro>: '#(valor)' }
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }

    Examples:
      | filtro |
      | email  |
      | nome   |

  @positivo
  Scenario: Filtrar por un email inexistente devuelve una lista vacía
    Given path 'usuarios'
    And param email = DataGenerator.email()
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negativo
  Scenario: Filtrar por administrador con un valor no permitido devuelve 400
    Given path 'usuarios'
    And param administrador = 'talvez'
    When method get
    Then status 400
    And match response == { administrador: "administrador deve ser 'true' ou 'false'" }
