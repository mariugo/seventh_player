import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:seventh_player/app/pages/login/widgets/login_page.dart';
import 'package:seventh_player/core/data/stores/helper_store.dart';
import 'package:seventh_player/core/data/stores/login_store.dart';
import 'package:seventh_player/core/errors/exceptions.dart';
import 'package:seventh_player/core/repositories/video_repository_impl.dart';
import 'package:seventh_player/core/server/http_client_adapter.dart';
import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'video_store.g.dart';

class VideoStore = VideoStoreBase with _$VideoStore;

abstract class VideoStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  String url = '';

  @observable
  dynamic errorMessage;

  @observable
  VideoPlayerController? videoPlayerController;

  @observable
  ChewieController? chewieController;

  @action
  void setLoading(bool value) => isLoading = value;

  @action
  void setError(dynamic value) => errorMessage = value;

  @action
  void setUrl(String value) => url = value;

  @action
  void setVideoPlayerController(VideoPlayerController value) =>
      videoPlayerController = value;

  @action
  Future<void> playVideo() async {
    setLoading(true);
    setError(null);
    const String fileName = 'bunny.mp4';
    try {
      final String token =
          GetIt.instance.get<HelperStore>().tokenAccess.toString();
      final response = await VideoRepositoryImpl(
              httpClient: GetIt.instance<HttpClientAdapter>())
          .getVideoUrl(token, fileName);
      setUrl(response);
      chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(response),
        aspectRatio: 16 / 9,
        autoPlay: true,
        allowMuting: false,
      );
    } on AppException catch (error) {
      setError(error.message);
      if (error.message == 'Invalid token') {
        GetIt.instance.get<LoginStore>().logout();
      }
    }
    setLoading(false);
  }

  Future<void> showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'Log out of Seventh Player?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              GetIt.instance.get<LoginStore>().logout();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginPage()));
            },
            child: const Text(
              'Log out',
            ),
          ),
        ],
      ),
    );
  }
}
