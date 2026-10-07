@usuarios @eliminar
Feature: DELETE /usuarios/{_id} - Eliminar usuario

  Como administrador del sistema
  Quiero eliminar usuarios
  Para mantener depurada la base de datos

  Background:
    * url baseUrl

  @smoke @positivo
  Scenario: Eliminar un usuario existente
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }
    # El usuario ya no existe
    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @negativo
  Scenario: Eliminar un ID inexistente no elimina ningún registro
    Given path 'usuarios', DataGenerator.idInexistente()
    When method delete
    Then status 200
    And match response == { message: 'Nenhum registro excluído' }

  @negativo
  Scenario: Eliminar dos veces el mismo usuario solo lo elimina la primera vez
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == 'Nenhum registro excluído'

  @negativo
  Scenario: No se puede eliminar un usuario que tiene un carrito registrado
    # Preparación: usuario + login + carrito con un producto con stock
    * def creado = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'login'
    And request { email: '#(creado.usuario.email)', password: '#(creado.usuario.password)' }
    When method post
    Then status 200
    * def token = response.authorization

    Given path 'produtos'
    When method get
    Then status 200
    * def conStock = karate.filter(response.produtos, function(p){ return p.quantidade > 0 })
    * if (conStock.length == 0) karate.fail('No hay productos con stock para preparar el carrito')
    * def idProducto = conStock[0]._id

    Given path 'carrinhos'
    And header Authorization = token
    And request { produtos: [{ idProduto: '#(idProducto)', quantidade: 1 }] }
    When method post
    Then status 201

    # Prueba
    Given path 'usuarios', creado.id
    When method delete
    Then status 400
    And match response == { message: 'Não é permitido excluir usuário com carrinho cadastrado', idCarrinho: '#string' }

    # Limpieza: cancelar compra (devuelve el stock) y eliminar el usuario
    Given path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    Then status 200
    * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }
