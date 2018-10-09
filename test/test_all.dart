import 'action_encoder_test.dart' as actionEncoder;
import 'state_encoder_test.dart' as stateEncoder;
import 'remote_devtools_middleware_test.dart' as devtools;

/// Script for running all tests on Travis CI
/// Allows us to generate code coverage
void main() {
  actionEncoder.main();
  stateEncoder.main();
  devtools.main();
}
