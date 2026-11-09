@plugin @message @SynchronousMessage
Feature: Synchronous message interactions with plugin contents
  Supports V4 synchronous message interactions whose request and response contents are handled by a content-type
  plugin. The plugin must return the "request" and "response" parts, so csv and avro are not used here.

  @plugin:matt
  Scenario: Builds a synchronous message interaction with the matt plugin
    Given the "matt" plugin version "0.1.1" is installed
    And a synchronous message interaction is being defined for a consumer test
    And the synchronous message contents are set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hello"}, "response": {"body": "world"}}
      """
    When the Pact file for the test is generated
    Then the first interaction in the Pact file will have a type of "Synchronous/Messages"
    And the Pact file metadata will list the "matt" plugin with version "0.1.1"
    And the first interaction in the pact file request content type will be "application/matt"
    And the first interaction in the pact file request contents will be "MATThelloMATT"
    And the first interaction in the pact file will contain 1 response message
    And the first interaction in the pact file response content type will be "application/matt"
    And the first interaction in the pact file response contents will be "MATTworldMATT"

  @plugin:matt
  Scenario: Verifies a synchronous message provider using the matt plugin
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" synchronous message interaction with plugin contents:
      | plugin | content type     | contents                                                      |
      | matt   | application/matt | {"request": {"body": "hello"}, "response": {"body": "world"}} |
    And a provider is started that can generate the "matt" message with "MATTworldMATT" and content type "application/matt"
    When the verification is run
    Then the verification will be successful

  @plugin:matt
  Scenario: Verifying a synchronous message provider using the matt plugin reports the plugin's mismatch
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" synchronous message interaction with plugin contents:
      | plugin | content type     | contents                                                      |
      | matt   | application/matt | {"request": {"body": "hello"}, "response": {"body": "world"}} |
    And a provider is started that can generate the "matt" message with "MATTnopeMATT" and content type "application/matt"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "expected body 'world' is not equal to actual body 'nope'"

  @plugin:protobuf
  Scenario: Builds a synchronous message interaction with the protobuf plugin
    Given the "protobuf" plugin version "0.8.0" is installed
    And a synchronous message interaction is being defined for a consumer test
    And the synchronous message contents are set with the "protobuf" plugin for "application/protobuf" with:
      """
      {
        "pact:proto": "fixture:plugins/user.proto",
        "pact:proto-service": "Users/GetUser",
        "pact:content-type": "application/protobuf",
        "request": {"name": "notEmpty('bob')"},
        "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}
      }
      """
    When the Pact file for the test is generated
    Then the Pact file metadata will list the "protobuf" plugin with version "0.8.0"
    And the first interaction in the pact file request content type will be "application/protobuf;message=.compat.UserRequest"
    And the first interaction in the pact file response content type will be "application/protobuf;message=.compat.User"
    And the first interaction in the pact file will have plugin configuration for "protobuf"
    And the first interaction request in the pact file will have a matching rule for "$.name" of type "notEmpty"
    And the first interaction response in the pact file will have a matching rule for "$.id" of type "integer"
    And the first interaction response in the pact file will have a matching rule for "$.name" of type "notEmpty"

  @plugin:protobuf
  Scenario: Verifies a synchronous message provider using the protobuf plugin
    Given the "protobuf" plugin version "0.8.0" is installed
    And a Pact file with a "user" synchronous message interaction with plugin contents:
      | plugin   | content type         | contents                                                                                                                                                                                                                     |
      | protobuf | application/protobuf | {"pact:proto": "fixture:plugins/user.proto", "pact:proto-service": "Users/GetUser", "pact:content-type": "application/protobuf", "request": {"name": "notEmpty('bob')"}, "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}} |
    And a provider is started that can generate the "user" message with "file: plugins/user.pb" and content type "application/protobuf;message=.compat.User"
    When the verification is run
    Then the verification will be successful

  @plugin:protobuf
  Scenario: Verifying a synchronous message provider using the protobuf plugin reports the plugin's mismatch
    Given the "protobuf" plugin version "0.8.0" is installed
    And a Pact file with a "user" synchronous message interaction with plugin contents:
      | plugin   | content type         | contents                                                                                                                                                                                                                     |
      | protobuf | application/protobuf | {"pact:proto": "fixture:plugins/user.proto", "pact:proto-service": "Users/GetUser", "pact:content-type": "application/protobuf", "request": {"name": "notEmpty('bob')"}, "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}} |
    And a provider is started that can generate the "user" message with "file: plugins/user-empty-name.pb" and content type "application/protobuf;message=.compat.User"
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error
    And the verification output will contain "$.name -> Expected  to not be empty"
