import 'action_encoder_test.dart' as actionEncoder;
import 'state_encoder_test.dart' as stateEncoder;

/// Script for running all tests on Travis CI
/// Allows us to generate code coverage
void main() {
  actionEncoder.main();
  stateEncoder.main();
}
