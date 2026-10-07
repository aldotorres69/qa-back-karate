@usuarios @registrar
Feature: POST /usuarios - Registrar usuario

  Como administrador del sistema
  Quiero registrar nuevos usuarios
  Para que puedan acceder a la plataforma

  Background:
    * url baseUrl

  @smoke @positivo
  Scenario Outline: Registrar un usuario válido con administrador = <admin>
    * def usuario = DataGenerator.usuario(<admin>)
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == read('classpath:serverest/common/schemas/registro-exitoso.json')
    # El usuario queda persistido con los mismos datos enviados
    * def id = response._id
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == read('classpath:serverest/common/schemas/usuario.json')
    And match response == karate.merge(usuario, { _id: id })
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(id)' }

    Examples:
      | admin |
      | true  |
      | false |

  @negativo
  Scenario: No se puede registrar un usuario con un email ya utilizado
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * def duplicado = DataGenerator.usuario()
    * set duplicado.email = creado.usuario.email
    Given path 'usuarios'
    And request duplicado
    When method post
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }

  @negativo
  Scenario Outline: No se puede registrar un usuario con datos inválidos: <caso>
    Given path 'usuarios'
    And request body
    When method post
    Then status 400
    * def errorDelCampo = response[campo]
    And match errorDelCampo == mensaje
    And match response !contains { _id: '#notnull' }

    Examples:
      | read('classpath:serverest/common/data/usuarios-invalidos.json') |

  @negativo
  Scenario: No se puede registrar un usuario con un body vacío
    Given path 'usuarios'
    And request {}
    When method post
    Then status 400
    And match response contains
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """
