@plugin
Feature: HTTP interactions with plugin contents
  Supports V4 HTTP interactions whose request and response bodies are handled by a content-type plugin

  @plugin:matt
  Scenario: Builds an HTTP interaction with the matt plugin
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
    When the Pact file for the test is generated
    Then the Pact file metadata will list the "matt" plugin with version "0.1.1"
    And the first interaction in the pact file request content type will be "application/matt"
    And the first interaction in the pact file response content type will be "application/matt"

  @plugin:matt
  Scenario: The mock server matches a request using the matt plugin
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
    When the mock server is started with the plugin interaction
    And a "POST" request is made to "/matt" with content type "application/matt" and body "MATThelloMATT"
    Then a 200 success response is returned
    And the response body will be "MATTworldMATT"
    When the pact test is done
    Then the mock server status will be OK

  @plugin:matt
  Scenario: The mock server reports the matt plugin's mismatch
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
    When the mock server is started with the plugin interaction
    And a "POST" request is made to "/matt" with content type "application/matt" and body "MATTnopeMATT"
    And the pact test is done
    Then the mock server status will be mismatches
    And the mismatches will contain a mismatch with error "expected body 'hello' is not equal to actual body 'nope'"

  @plugin:matt
  Scenario: Verifies a provider using the matt plugin
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with an HTTP "POST" "/matt" interaction with plugin contents:
      | plugin | content type     | request                        | response                        |
      | matt   | application/matt | {"request": {"body": "hello"}} | {"response": {"body": "world"}} |
    And a provider is started that returns "MATTworldMATT" with content type "application/matt"
    When the verification is run
    Then the verification will be successful

  @plugin:matt
  Scenario: Verifying a provider using the matt plugin reports the plugin's mismatch
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with an HTTP "POST" "/matt" interaction with plugin contents:
      | plugin | content type     | request                        | response                        |
      | matt   | application/matt | {"request": {"body": "hello"}} | {"response": {"body": "world"}} |
    And a provider is started that returns "MATTnopeMATT" with content type "application/matt"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "expected body 'world' is not equal to actual body 'nope'"

  @plugin:csv
  Scenario: Builds an HTTP interaction with the csv plugin
    Given the "csv" plugin version "0.0.6" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "GET" "/reports/report.csv"
    And the HTTP response body is set with the "csv" plugin for "text/csv" with:
      """
      {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"}
      """
    When the Pact file for the test is generated
    Then the Pact file metadata will list the "csv" plugin with version "0.0.6"
    And the first interaction in the pact file response content type will be "text/csv;charset=utf-8"
    And the first interaction in the pact file will have plugin configuration for "csv"
    And the first interaction response in the pact file will have a matching rule for "column:1" of type "type"
    And the first interaction response in the pact file will have a matching rule for "column:2" of type "number"

  @plugin:csv
  Scenario: The mock server serves the body built by the csv plugin
    Given the "csv" plugin version "0.0.6" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "GET" "/reports/report.csv"
    And the HTTP response body is set with the "csv" plugin for "text/csv" with:
      """
      {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"}
      """
    When the mock server is started with the plugin interaction
    And a "GET" request is made to "/reports/report.csv"
    Then a 200 success response is returned
    And the response body will be "file: plugins/row.csv"
    When the pact test is done
    Then the mock server status will be OK

  @plugin:csv
  Scenario: Verifies a provider using the csv plugin
    Given the "csv" plugin version "0.0.6" is installed
    And a Pact file with an HTTP "GET" "/reports/report.csv" interaction with plugin contents:
      | plugin | content type | response                                                                                       |
      | csv    | text/csv     | {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"} |
    And a provider is started that returns "file: plugins/row.csv" with content type "text/csv;charset=utf-8"
    When the verification is run
    Then the verification will be successful

  @plugin:csv
  Scenario: Verifying a provider using the csv plugin reports the plugin's mismatch
    Given the "csv" plugin version "0.0.6" is installed
    And a Pact file with an HTTP "GET" "/reports/report.csv" interaction with plugin contents:
      | plugin | content type | response                                                                                       |
      | csv    | text/csv     | {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"} |
    And a provider is started that returns "file: plugins/row-bad-number.csv" with content type "text/csv;charset=utf-8"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "Expected 'abc' to match a number"

  @plugin:avro
  Scenario: Builds an HTTP interaction with the avro plugin
    Given the "avro" plugin version "0.1.3" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "GET" "/avro"
    And the HTTP response body is set with the "avro" plugin for "avro/binary" with:
      """
      {
        "pact:avro": "fixture:plugins/user.avsc",
        "pact:record-name": "User",
        "pact:content-type": "avro/binary",
        "id": "matching(number, 1)",
        "username": "notEmpty('matt')"
      }
      """
    When the Pact file for the test is generated
    Then the Pact file metadata will list the "avro" plugin with version "0.1.3"
    And the first interaction in the pact file response content type will be "avro/binary;record=User"
    And the first interaction in the pact file will have plugin configuration for "avro"
    And the first interaction response in the pact file will have a matching rule for "$.id" of type "number"
    And the first interaction response in the pact file will have a matching rule for "$.username" of type "notEmpty"

  @plugin:avro
  Scenario: The mock server serves the body built by the avro plugin
    Given the "avro" plugin version "0.1.3" is installed
    And an HTTP interaction is being defined for a consumer test
    And the HTTP request is "GET" "/avro"
    And the HTTP response body is set with the "avro" plugin for "avro/binary" with:
      """
      {
        "pact:avro": "fixture:plugins/user.avsc",
        "pact:record-name": "User",
        "pact:content-type": "avro/binary",
        "id": "matching(number, 1)",
        "username": "notEmpty('matt')"
      }
      """
    When the mock server is started with the plugin interaction
    And a "GET" request is made to "/avro"
    Then a 200 success response is returned
    And the response body will be "file: plugins/user.avro"
    When the pact test is done
    Then the mock server status will be OK

  @plugin:avro
  Scenario: Verifies a provider using the avro plugin
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with an HTTP "GET" "/avro" interaction with plugin contents:
      | plugin | content type | response                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that returns "file: plugins/user.avro" with content type "avro/binary;record=User"
    When the verification is run
    Then the verification will be successful

  @plugin:avro
  Scenario: Verifying a provider using the avro plugin reports the plugin's mismatch
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with an HTTP "GET" "/avro" interaction with plugin contents:
      | plugin | content type | response                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that returns "file: plugins/user-empty-username.avro" with content type "avro/binary;record=User"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "$.username -> Expected  to not be empty"

  @plugin:avro
  Scenario: Verifying a provider that leaves the parameter off the plugin's content type
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with an HTTP "GET" "/avro" interaction with plugin contents:
      | plugin | content type | response                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that returns "file: plugins/user.avro" with content type "avro/binary"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
