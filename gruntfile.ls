module.exports = (grunt) ->
  grunt.initConfig do
    mochacov:
      coverage:
        options:
          coveralls:
            serviceName: \travis-ci
      test:
        options:
          reporter: \spec
      options:
        files: \test/**/*.ls

  grunt.loadNpmTasks \grunt-mocha-cov

  grunt.registerTask 'travis', ['mochacov:coverage']
  grunt.registerTask 'test', ['mochacov']
