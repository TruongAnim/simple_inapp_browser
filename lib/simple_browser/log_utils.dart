import 'package:logger/logger.dart';

var logger = Logger();

logd(dynamic msg, {dynamic tag}) {
  logger.d('TruongAnim: $msg--$tag');
}

loge(dynamic msg, {dynamic tag}) {
  logger.e('TruongAnim: $msg--$tag');
}
