@usuarios @buscar
Feature: GET /usuarios/{_id} - Buscar usuario por ID

  Como administrador del sistema
  Quiero consultar un usuario específico por su ID
  Para revisar su información

  Background:
    * url baseUrl

  @smoke @positivo
  Scenario: Buscar un usuario existente por su ID
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == read('classpath:serverest/common/schemas/usuario.json')
    And match response == karate.merge(creado.usuario, { _id: creado.id })
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }

  @negativo
  Scenario: Buscar un ID con formato válido que no existe devuelve 400
    Given path 'usuarios', DataGenerator.idInexistente()
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @negativo
  Scenario Outline: Buscar con un ID de formato inválido (<descripcion>) devuelve 400
    Given path 'usuarios', id
    When method get
    Then status 400
    And match response == { id: 'id deve ter exatamente 16 caracteres alfanuméricos' }

    Examples:
      | descripcion           | id                   |
      | demasiado corto       | abc123               |
      | demasiado largo       | abcdefghij1234567890 |
      | caracteres especiales | abc_def-ghi.jklm     |

  @negativo
  Scenario: Un usuario eliminado ya no se puede encontrar
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }
    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
