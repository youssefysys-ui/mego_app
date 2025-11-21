

import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

void openWhatsApp() async {
  const link = WhatsAppUnilink(
    phoneNumber: '+201092001924',  // Use full international format without spaces
    text: "اهلا بك كيف يمكنني مساعدتك ؟! ",
  );

  final url = link.toString();

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    await launchUrl(Uri.parse(url));
    // Handle the error, e.g. show a message that WhatsApp is not installed
    print('Could not launch $url');
  }
}
Future<void> openInstagram() async {
  final Uri url = Uri.parse('https://www.instagram.com/the.hatch.studio/');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }else{
 await launchUrl(url);
  }
}