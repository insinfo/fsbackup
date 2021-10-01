import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class TelegramService {
  final tokenBot = '2040697629:AAGEQaSvygtfaNu7GjwNP2XKU8VR62mb2gs';
  var chatId = '971419711'; //isaque
  TeleDart teledart;
  TelegramService();

  Future<void> init() async {
    var telegram = Telegram(tokenBot);
    var user = await telegram.getMe();
    //print('user $user');
    var username = user.username;
    //print('username $username');
    var event = Event(username);
    //print('event $event');
    teledart = TeleDart(telegram, event);
    // print('teledart $teledart');
    teledart.start();
  }

  Future<void> sendMessage(String msg) async {
    /* teledart.onMessage().listen((message) {
    print('message $message');
    teledart.telegram.sendMessage(message.chat.id, message.chat.id.toString());
  });*/
    teledart.telegram.sendMessage(chatId, msg);
  }
}
