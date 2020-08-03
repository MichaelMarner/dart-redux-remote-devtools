import 'action_decoder_test.dart' as action_decoder;
import 'action_encoder_test.dart' as action_encoder;
import 'socketcluster_wrapper_test.dart' as socket_wrapper;
import 'state_encoder_test.dart' as state_encoder;
import 'remote_devtools_middleware_test.dart' as devtools;

/// Script for running all tests on Travis CI
/// Allows us to generate code coverage
void main() {
  action_decoder.main();
  action_encoder.main();
  state_encoder.main();
  devtools.main();
  socket_wrapper.main();
}
