import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

import '../../auth/controller/auth_controller.dart';

class VideoConferencePage extends ConsumerWidget {
  final String conferenceID;
  final String userID;

  final String userName;

  const VideoConferencePage({
    super.key,
    required this.conferenceID,
    required this.userID,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: int.parse(dotenv.env['APP_ID']!),
        appSign: dotenv.env['APP_SIGNING_ID']!,
        userID: userID,
        userName: userName,
        conferenceID: conferenceID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          topMenuBarConfig: ZegoTopMenuBarConfig(
            title: conferenceID,
            hideAutomatically: false,
          ),
          // audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
          //   foregroundBuilder: (BuildContext context, Size size,
          //       ZegoUIKitUser? user, Map extraInfo) {
          //     return user != null
          //         ? Positioned(
          //             bottom: 5,
          //             left: 5,
          //             child: CircleAvatar(
          //               radius: 50,
          //               backgroundImage: NetworkImage(
          //                 users!.photoUrl,
          //               ),
          //             ),
          //           )
          //         : const SizedBox();
          //   },
          // ),
          onLeaveConfirmation: (BuildContext context) async {
            return await showCupertinoDialog<bool>(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text('Leave the conference?'),
                  content: const Text(
                      'Are you sure you want to leave the conference?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Leave'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
