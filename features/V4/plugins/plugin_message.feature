@plugin @message
Feature: Asynchronous message interactions with plugin contents
  Supports V4 asynchronous message interactions whose contents are handled by a content-type plugin

  @plugin:matt
  Scenario: Builds a message interaction with the matt plugin
    Given the "matt" plugin version "0.1.1" is installed
    And a message interaction is being defined for a consumer test
    And the message contents are set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hello"}}
      """
    When the Pact file for the test is generated
    Then the first interaction in the Pact file will have a type of "Asynchronous/Messages"
    And the Pact file metadata will list the "matt" plugin with version "0.1.1"
    And the first interaction in the pact file contents content type will be "application/matt"
    And the first interaction in the pact file contents will be "MATThelloMATT"

  @plugin:matt
  Scenario: Verifies a message provider using the matt plugin
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" message interaction with plugin contents:
      | plugin | content type     | contents                       |
      | matt   | application/matt | {"request": {"body": "hello"}} |
    And a provider is started that can generate the "matt" message with "MATThelloMATT" and content type "application/matt"
    When the verification is run
    Then the verification will be successful

  @plugin:matt
  Scenario: Verifying a message provider using the matt plugin reports the plugin's mismatch
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" message interaction with plugin contents:
      | plugin | content type     | contents                       |
      | matt   | application/matt | {"request": {"body": "hello"}} |
    And a provider is started that can generate the "matt" message with "MATTnopeMATT" and content type "application/matt"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "expected body 'hello' is not equal to actual body 'nope'"

  @plugin:csv
  Scenario: Builds a message interaction with the csv plugin
    Given the "csv" plugin version "0.0.6" is installed
    And a message interaction is being defined for a consumer test
    And the message contents are set with the "csv" plugin for "text/csv" with:
      """
      {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"}
      """
    When the Pact file for the test is generated
    Then the Pact file metadata will list the "csv" plugin with version "0.0.6"
    And the first interaction in the pact file contents content type will be "text/csv;charset=utf-8"
    And the first interaction in the pact file will have plugin configuration for "csv"
    And the first interaction contents in the pact file will have a matching rule for "column:1" of type "type"
    And the first interaction contents in the pact file will have a matching rule for "column:2" of type "number"

  @plugin:csv
  Scenario: Verifies a message provider using the csv plugin
    Given the "csv" plugin version "0.0.6" is installed
    And a Pact file with a "report" message interaction with plugin contents:
      | plugin | content type | contents                                                                                       |
      | csv    | text/csv     | {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"} |
    And a provider is started that can generate the "report" message with "file: plugins/row.csv" and content type "text/csv;charset=utf-8"
    When the verification is run
    Then the verification will be successful

  @plugin:csv
  Scenario: Verifying a message provider using the csv plugin reports the plugin's mismatch
    Given the "csv" plugin version "0.0.6" is installed
    And a Pact file with a "report" message interaction with plugin contents:
      | plugin | content type | contents                                                                                       |
      | csv    | text/csv     | {"csvHeaders": false, "column:1": "matching(type,'Name')", "column:2": "matching(number,100)"} |
    And a provider is started that can generate the "report" message with "file: plugins/row-bad-number.csv" and content type "text/csv;charset=utf-8"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "column: 1 -> Expected 'abc' to match a number"

  @plugin:avro
  Scenario: Builds a message interaction with the avro plugin
    Given the "avro" plugin version "0.1.3" is installed
    And a message interaction is being defined for a consumer test
    And the message contents are set with the "avro" plugin for "avro/binary" with:
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
    And the first interaction in the pact file contents content type will be "avro/binary;record=User"
    And the first interaction in the pact file will have plugin configuration for "avro"
    And the first interaction contents in the pact file will have a matching rule for "$.id" of type "number"
    And the first interaction contents in the pact file will have a matching rule for "$.username" of type "notEmpty"

  @plugin:avro
  Scenario: Verifies a message provider using the avro plugin
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with a "user" message interaction with plugin contents:
      | plugin | content type | contents                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that can generate the "user" message with "file: plugins/user.avro" and content type "avro/binary;record=User"
    When the verification is run
    Then the verification will be successful

  @plugin:avro
  Scenario: Verifying a message provider using the avro plugin reports the plugin's mismatch
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with a "user" message interaction with plugin contents:
      | plugin | content type | contents                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that can generate the "user" message with "file: plugins/user-empty-username.avro" and content type "avro/binary;record=User"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "$.username -> Expected  to not be empty"

  @plugin:avro
  Scenario: Verifying a message provider that leaves the parameter off the plugin's content type
    Given the "avro" plugin version "0.1.3" is installed
    And a Pact file with a "user" message interaction with plugin contents:
      | plugin | content type | contents                                                                                                                                                         |
      | avro   | avro/binary  | {"pact:avro": "fixture:plugins/user.avsc", "pact:record-name": "User", "pact:content-type": "avro/binary", "id": "matching(number, 1)", "username": "notEmpty('matt')"} |
    And a provider is started that can generate the "user" message with "file: plugins/user.avro" and content type "avro/binary"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Metadata had differences" error
