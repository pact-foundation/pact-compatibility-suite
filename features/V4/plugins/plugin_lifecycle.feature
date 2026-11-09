@plugin
Feature: Plugin lifecycle
  Loading, mixing and shutting down plugins, independent of the interaction type

  Scenario: Using a plugin that is not installed
    Given the "not-a-plugin" plugin is not installed
    And an HTTP interaction is being defined for a consumer test
    When the "not-a-plugin" plugin is loaded for the test
    Then loading the plugin will fail with an error that mentions "not-a-plugin"
    And the test will not have panicked

  @plugin:matt
  Scenario: Asking for a newer version of a plugin than is installed
    Given the "matt" plugin version "0.1.1" is installed
    And an HTTP interaction is being defined for a consumer test
    When the "matt" plugin version "99.0.0" is loaded for the test
    Then loading the plugin will fail with an error that mentions "99.0.0"
    And the test will not have panicked

  @plugin:matt
  Scenario: A pact with a plugin interaction and a plain JSON interaction
    Given the "matt" plugin version "0.1.1" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "POST" "/matt"
    And the HTTP request body is set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hello"}}
      """
    And the HTTP response body is set with the "matt" plugin for "application/matt" with:
      """
      {"response": {"body": "world"}}
      """
    And another HTTP interaction is being defined for the same consumer test
    And the HTTP request is "GET" "/basic"
    And the HTTP response body is "file: basic.json" with content type "application/json"
    When the mock server is started with all the interactions
    And a "POST" request is made to "/matt" with content type "application/matt" and body "MATThelloMATT"
    And a "GET" request is made to "/basic"
    Then the response body will be "file: basic.json"
    When the pact test is done
    Then the mock server status will be OK
    And the pact file will contain 2 interactions
    And the second interaction in the pact file will not have plugin configuration

  @plugin:matt @plugin:csv
  Scenario: A pact with interactions from two plugins
    Given the "matt" plugin version "0.1.1" is installed
    And the "csv" plugin version "0.0.6" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "POST" "/matt"
    And the HTTP request body is set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hello"}}
      """
    And the HTTP response body is set with the "matt" plugin for "application/matt" with:
      """
      {"response": {"body": "world"}}
      """
    And another HTTP interaction is being defined for the same consumer test
    And the HTTP request is "GET" "/reports/report.csv"
    And the HTTP response body is set with the "csv" plugin for "text/csv" with:
      """
      {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"}
      """
    When the mock server is started with all the interactions
    And a "POST" request is made to "/matt" with content type "application/matt" and body "MATThelloMATT"
    And a "GET" request is made to "/reports/report.csv"
    And the pact test is done
    Then the mock server status will be OK
    And the Pact file metadata will list the "matt" plugin with version "0.1.1"
    And the Pact file metadata will list the "csv" plugin with version "0.0.6"

  @plugin:matt
  Scenario: Plugins are shut down when the test is done
    Given the "matt" plugin version "0.1.1" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request body is set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hello"}}
      """
    When the Pact file for the test is generated
    And the plugins are cleaned up
    Then no "matt" plugin process will still be running
