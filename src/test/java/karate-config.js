function fn() {
  var env = karate.env || 'prod';
  karate.log('karate.env =', env);

  var urls = {
    prod: 'https://serverest.dev',
    local: 'http://localhost:3000'
  };

  var config = {
    env: env,
    baseUrl: urls[env] || urls.prod,
    DataGenerator: Java.type('serverest.common.utils.DataGenerator')
  };

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('headers', { Accept: 'application/json' });

  return config;
}
