import 'package:mailer/smtp_server.dart';
import 'package:mailer/mailer.dart';

class EmailService {
  EmailService() {
    smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: 'desenv.pmro@gmail.com',
      password: 'S15tem@5PMR0',
      port: 587,
    );
    message = Message();
  }
  SmtpServer smtpServer;
  Message message;

  String deEmail = 'desenv.pmro@gmail.com';
  String deNome = 'fsbackup';
  String paraEmail = 'desenv.pmro@gmail.com';
  String assunto = 'fsbackup :: log';

  void addDestinoEmail(String email) {
    message.recipients.add(email);
  }

  Future<SendReport> sendLog(String msg) async {
    msg = msg.replaceAll('\r\n', '<br>');
    message.from = Address(deEmail, deNome);
    message.recipients.add(paraEmail);
    message.subject = assunto;
    message.html = '<p>$msg</p>';
    //message.headers['MIME-Version'] = '1.0';
    message.headers['Content-type'] = 'text/html; charset=utf-8';
    return send(message, smtpServer);
  }
}
