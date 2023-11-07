import 'package:logger/logger.dart';

var logger = Logger();

logd(dynamic msg, {dynamic tag}) {
  if (tag != null) {
    logger.d('TruongAnim: $tag: $msg');
  } else {
    logger.d('TruongAnim: $msg');
  }
}

loge(dynamic msg, {dynamic tag}) {
  if (tag != null) {
    logger.e('TruongAnim: $tag: $msg');
  } else {
    logger.e('TruongAnim: $msg');
  }
}
