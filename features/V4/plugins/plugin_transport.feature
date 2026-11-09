@plugin @message @SynchronousMessage
Feature: Synchronous messages over a plugin transport
  Supports V4 synchronous message interactions whose transport is provided by a plugin, not HTTP. The consumer calls a
  mock server started for that transport, and the provider is verified over it.

  @plugin:matt @transport:matt
  Scenario: The matt TCP mock server matches a request
    Given the "matt" plugin version "0.1.1" is installed
    And a synchronous message interaction is being defined for a consumer test
    And the synchronous message contents are set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}}
      """
    When a mock server is started for the "matt" transport
    And the line "MATThellotcpMATT" is sent to the mock server over TCP
    Then the line "MATTtcpworldMATT" will be received from the mock server
    When the pact test is done
    Then the mock server status will be OK

  @plugin:matt @transport:matt
  Scenario: The matt TCP mock server reports a mismatch
    Given the "matt" plugin version "0.1.1" is installed
    And a synchronous message interaction is being defined for a consumer test
    And the synchronous message contents are set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}}
      """
    When a mock server is started for the "matt" transport
    And the line "MATTnopeMATT" is sent to the mock server over TCP
    And the pact test is done
    Then the mock server status will be mismatches
    And the mismatches will contain a mismatch with error "Expected 'hellotcp', but received 'nope'"

  @plugin:matt @transport:matt
  Scenario: The Pact file written for the matt transport records the transport
    Given the "matt" plugin version "0.1.1" is installed
    And a synchronous message interaction is being defined for a consumer test
    And the synchronous message contents are set with the "matt" plugin for "application/matt" with:
      """
      {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}}
      """
    When a mock server is started for the "matt" transport
    And the line "MATThellotcpMATT" is sent to the mock server over TCP
    And the pact test is done
    Then the mock server will write out a Pact file for the interaction when done
    And the first interaction in the Pact file will have "transport" = '"matt"'
    And the Pact file metadata will list the "matt" plugin with version "0.1.1"

  @plugin:matt @transport:matt
  Scenario: Verifies a provider over the matt transport
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" synchronous message interaction over the "matt" transport with plugin contents:
      | plugin | content type     | contents                                                            |
      | matt   | application/matt | {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}} |
    And a TCP provider is started that replies to "MATThellotcpMATT" with "MATTtcpworldMATT"
    When the verification is run with the "matt" transport
    Then the verification will be successful

  @plugin:matt @transport:matt
  Scenario: Verifying a provider over the matt transport reports the plugin's mismatch
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" synchronous message interaction over the "matt" transport with plugin contents:
      | plugin | content type     | contents                                                            |
      | matt   | application/matt | {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}} |
    And a TCP provider is started that replies to "MATThellotcpMATT" with "MATTnopeMATT"
    When the verification is run with the "matt" transport
    Then the verification will NOT be successful
    And the verification output will contain "Expected 'tcpworld' but got 'nope'"

  @plugin:matt @transport:matt
  Scenario: Verifying over the matt transport with no provider listening
    Given the "matt" plugin version "0.1.1" is installed
    And a Pact file with a "matt" synchronous message interaction over the "matt" transport with plugin contents:
      | plugin | content type     | contents                                                            |
      | matt   | application/matt | {"request": {"body": "hellotcp"}, "response": {"body": "tcpworld"}} |
    And no provider is listening
    When the verification is run with the "matt" transport
    Then the verification will NOT be successful

  @plugin:protobuf @transport:grpc
  Scenario: The gRPC mock server matches a request
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
    When a mock server is started for the "grpc" transport
    And the gRPC method "/compat.Users/GetUser" is called on the mock server with "file: plugins/user-request.pb"
    Then the gRPC call will return "file: plugins/user.pb"
    When the pact test is done
    Then the mock server status will be OK

  @plugin:protobuf @transport:grpc
  Scenario: The gRPC mock server reports a mismatch
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
    When a mock server is started for the "grpc" transport
    And the gRPC method "/compat.Users/GetUser" is called on the mock server with an empty message
    Then the gRPC call will fail with status "FAILED_PRECONDITION"
    When the pact test is done
    Then the mock server status will be mismatches
    And the mismatches will contain a mismatch with error "Expected  to not be empty"

  @plugin:protobuf @transport:grpc
  Scenario: The gRPC mock server reports a request that was not received
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
    When a mock server is started for the "grpc" transport
    And the pact test is done
    Then the mock server status will be mismatches
    And the mismatches will contain a mismatch with error "Did not receive any requests for path '/compat.Users/GetUser'"

  @plugin:protobuf @transport:grpc
  Scenario: The Pact file written for the gRPC transport records the transport
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
    When a mock server is started for the "grpc" transport
    And the gRPC method "/compat.Users/GetUser" is called on the mock server with "file: plugins/user-request.pb"
    And the pact test is done
    Then the mock server will write out a Pact file for the interaction when done
    And the first interaction in the Pact file will have "transport" = '"grpc"'
    And the first interaction in the pact file will have plugin configuration for "protobuf"

  @plugin:protobuf @transport:grpc
  Scenario: Verifies a provider over gRPC
    Given the "protobuf" plugin version "0.8.0" is installed
    And a Pact file with a "user" synchronous message interaction over the "grpc" transport with plugin contents:
      | plugin   | content type         | contents                                                                                                                                                                                                                     |
      | protobuf | application/protobuf | {"pact:proto": "fixture:plugins/user.proto", "pact:proto-service": "Users/GetUser", "pact:content-type": "application/protobuf", "request": {"name": "notEmpty('bob')"}, "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}} |
    And a gRPC provider is started that answers "/compat.Users/GetUser" with "file: plugins/user.pb"
    When the verification is run with the "grpc" transport
    Then the verification will be successful

  @plugin:protobuf @transport:grpc
  Scenario: Verifying a provider over gRPC reports the plugin's mismatch
    Given the "protobuf" plugin version "0.8.0" is installed
    And a Pact file with a "user" synchronous message interaction over the "grpc" transport with plugin contents:
      | plugin   | content type         | contents                                                                                                                                                                                                                     |
      | protobuf | application/protobuf | {"pact:proto": "fixture:plugins/user.proto", "pact:proto-service": "Users/GetUser", "pact:content-type": "application/protobuf", "request": {"name": "notEmpty('bob')"}, "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}} |
    And a gRPC provider is started that answers "/compat.Users/GetUser" with "file: plugins/user-empty-name.pb"
    When the verification is run with the "grpc" transport
    Then the verification will NOT be successful
    And the verification output will contain "$.name -> Expected  to not be empty"

  @plugin:protobuf @transport:grpc
  Scenario: Verifying over gRPC with no provider listening
    Given the "protobuf" plugin version "0.8.0" is installed
    And a Pact file with a "user" synchronous message interaction over the "grpc" transport with plugin contents:
      | plugin   | content type         | contents                                                                                                                                                                                                                     |
      | protobuf | application/protobuf | {"pact:proto": "fixture:plugins/user.proto", "pact:proto-service": "Users/GetUser", "pact:content-type": "application/protobuf", "request": {"name": "notEmpty('bob')"}, "response": {"id": "matching(integer, 1)", "name": "notEmpty('bob')"}} |
    And no provider is listening
    When the verification is run with the "grpc" transport
    Then the verification will NOT be successful
    And the verification output will contain "transport error"
