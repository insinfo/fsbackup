import 'package:f_logs/f_logs.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class TelegramService {
  final tokenBot = '2040697629:AAGEQaSvygtfaNu7GjwNP2XKU8VR62mb2gs';
  var chatId = '971419711'; //isaque
  var groupId = '-577665445'; //id do grupo Fsbackup
  //para obter o id do grupo https://api.telegram.org/bot2040697629:AAGEQaSvygtfaNu7GjwNP2XKU8VR62mb2gs/getUpdates
  TeleDart teledart;
  TelegramService();
  bool isFailed = false;

  Future<void> init() async {
    try {
      var telegram = Telegram(tokenBot);
      var user = await telegram.getMe();
      //print('user $user');
      var username = user.username;
      //print('username $username');
      var event = Event(username);
      //print('event $event');
      teledart = TeleDart(telegram, event);
      // print('teledart $teledart');
      // teledart.start();
    } catch (e) {
      FLog.info(className: 'TelegramService', methodName: 'init', text: 'TelegramService: Telegram failed $e');
      isFailed = true;
    }
  }

  Future<void> sendMessage(String msg) async {
    /* teledart.onMessage().listen((message) {
    print('message $message');
    teledart.telegram.sendMessage(message.chat.id, message.chat.id.toString());
  });*/
    try {
      if (isFailed == false) {
        teledart.telegram.sendMessage(groupId, msg);
      }
    } catch (e) {
      FLog.info(className: 'TelegramService', methodName: 'sendMessage', text: 'TelegramService: Telegram failed $e');
      isFailed = true;
    }
  }

  void stop() {
    teledart.stop();
  }
}
