@ignore
Feature: Helper - Crear un usuario por API

  # Uso: * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
  #      * def creado = call read('...') { usuario: { nome: 'x', ... } }
  # Devuelve: usuario (body enviado) e id (_id generado)

  Scenario: Crear usuario
    * def usuario = __arg && __arg.usuario ? __arg.usuario : DataGenerator.usuario()
    Given url baseUrl
    And path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == read('classpath:serverest/common/schemas/registro-exitoso.json')
    * def id = response._id
