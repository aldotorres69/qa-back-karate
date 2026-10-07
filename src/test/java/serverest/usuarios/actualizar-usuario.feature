@usuarios @actualizar
Feature: PUT /usuarios/{_id} - Actualizar usuario

  Como administrador del sistema
  Quiero actualizar la información de un usuario existente
  Para mantener los datos al día

  Background:
    * url baseUrl
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * def eliminar = read('classpath:serverest/common/helpers/eliminar-usuario.feature')

  @smoke @positivo
  Scenario: Actualizar todos los datos de un usuario existente
    * def nuevosDatos = DataGenerator.usuario()
    Given path 'usuarios', creado.id
    And request nuevosDatos
    When method put
    Then status 200
    And match response == { message: 'Registro alterado com sucesso' }
    # Verificamos que el cambio quedó persistido
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == karate.merge(nuevosDatos, { _id: creado.id })
    * call eliminar { id: '#(creado.id)' }

  @positivo
  Scenario: Cambiar solo el perfil de administrador manteniendo los demás datos
    * def nuevoPerfil = creado.usuario.administrador == 'true' ? 'false' : 'true'
    * def nuevosDatos = karate.merge(creado.usuario, { administrador: nuevoPerfil })
    Given path 'usuarios', creado.id
    And request nuevosDatos
    When method put
    Then status 200
    And match response.message == 'Registro alterado com sucesso'
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response.administrador == nuevoPerfil
    And match response.email == creado.usuario.email
    * call eliminar { id: '#(creado.id)' }

  @positivo
  Scenario: PUT con un ID inexistente crea un nuevo usuario (upsert documentado en ServeRest)
    * def nuevo = DataGenerator.usuario()
    Given path 'usuarios', DataGenerator.idInexistente()
    And request nuevo
    When method put
    Then status 201
    And match response == read('classpath:serverest/common/schemas/registro-exitoso.json')
    * call eliminar { id: '#(response._id)' }
    * call eliminar { id: '#(creado.id)' }

  @negativo
  Scenario: No se puede actualizar un usuario con el email de otro usuario
    * def otro = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * def nuevosDatos = karate.merge(creado.usuario, { email: otro.usuario.email })
    Given path 'usuarios', creado.id
    And request nuevosDatos
    When method put
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }
    * call eliminar { id: '#(otro.id)' }
    * call eliminar { id: '#(creado.id)' }

  @negativo
  Scenario Outline: No se puede actualizar con datos inválidos: <caso>
    Given path 'usuarios', creado.id
    And request body
    When method put
    Then status 400
    * def errorDelCampo = response[campo]
    And match errorDelCampo == mensaje
    # El usuario original no se modificó
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == karate.merge(creado.usuario, { _id: creado.id })
    * call eliminar { id: '#(creado.id)' }

    Examples:
      | read('classpath:serverest/common/data/usuarios-invalidos.json') |
